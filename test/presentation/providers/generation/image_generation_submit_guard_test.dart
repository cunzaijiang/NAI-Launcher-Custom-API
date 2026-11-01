import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:mocktail/mocktail.dart';
import 'package:nai_launcher/core/constants/storage_keys.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint_service.dart';
import 'package:nai_launcher/core/storage/local_storage_service.dart';
import 'package:nai_launcher/data/models/gallery/gallery_index_admission.dart';
import 'package:nai_launcher/data/datasources/remote/nai_generation_transport.dart';
import 'package:nai_launcher/data/datasources/remote/nai_image_generation_api_service.dart';
import 'package:nai_launcher/data/models/image/image_params.dart';
import 'package:nai_launcher/data/models/image/image_stream_chunk.dart';
import 'package:nai_launcher/data/services/auth_provider.dart';
import 'package:nai_launcher/presentation/providers/image_generation_provider.dart';
import 'package:nai_launcher/presentation/providers/image_save_settings_provider.dart';
import 'package:nai_launcher/presentation/providers/notification_settings_provider.dart';
import 'package:nai_launcher/presentation/providers/local_gallery_provider.dart';
import 'package:nai_launcher/presentation/providers/generation/image_generation_selectors.dart';

class _MockApiService extends Mock implements NAIImageGenerationApiService {}

class _AuthenticatedAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.authenticated);
}

void main() {
  late Directory hiveTempDir;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    registerFallbackValue(const ImageParams());
    registerFallbackValue(NaiGenerationCancellationLease());
    hiveTempDir = await Directory.systemTemp.createTemp('nai_launcher_hive_');
    Hive.init(hiveTempDir.path);
    await Hive.openBox(StorageKeys.settingsBox);
    await Hive.openBox(StorageKeys.historyBox);
    await Hive.openBox(StorageKeys.statisticsCacheBox);
  });

  setUp(() async {
    await Hive.box(
      StorageKeys.settingsBox,
    ).put(StorageKeys.imagesPerRequest, 1);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await hiveTempDir.exists()) {
      await hiveTempDir.delete(recursive: true);
    }
  });

  test('preparation is visible and a second tap cannot start a run', () async {
    // 用真实 controller：取消后要靠 close() 收掉订阅，否则 await 不回来。
    final stream = StreamController<ImageStreamChunk>();
    var streamCall = 0;
    final api = _stubApi(
      onStream: () {
        streamCall += 1;
        return stream.stream;
      },
    );
    final container = await _createContainer(api);

    final notifier = container.read(imageGenerationNotifierProvider.notifier);
    final params = container
        .read(generationParamsNotifierProvider)
        .copyWith(prompt: '1girl', width: 512, height: 768);

    final generation = notifier.generate(params);

    // 点击返回的同一时刻状态就必须对外可见，否则按钮会继续吞掉点击。
    final armed = container.read(imageGenerationNotifierProvider);
    expect(armed.isSubmitting, isTrue);
    expect(armed.isPreparing, isTrue);
    expect(armed.isGenerating, isFalse);
    expect(armed.isBusy, isTrue);

    await notifier.generate(params);
    await _pumpUntil(
      () => streamCall == 1,
      reason: 'the first submission never reached the API',
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(streamCall, 1);

    notifier.cancel();
    await stream.close();
    await generation;
    expect(
      container.read(imageGenerationNotifierProvider).isSubmitting,
      isFalse,
    );
  });

  test('cancel during preparation releases the guard synchronously', () async {
    final api = _stubApi(onStream: _neverEmits);
    final container = await _createContainer(api);

    final notifier = container.read(imageGenerationNotifierProvider.notifier);
    final params = container
        .read(generationParamsNotifierProvider)
        .copyWith(prompt: '1girl', width: 512, height: 768);

    final generation = notifier.generate(params);
    expect(container.read(imageGenerationNotifierProvider).isPreparing, isTrue);

    notifier.cancel();

    final released = container.read(imageGenerationNotifierProvider);
    expect(released.isSubmitting, isFalse);
    expect(released.isBusy, isFalse);

    await generation;
  });

  test('failed run releases the guard and keeps the error message', () async {
    final api = _stubApi(
      onStream: () =>
          Stream.value(ImageStreamChunk.error('API_ERROR_500|stream failed')),
    );
    final container = await _createContainer(api);

    final notifier = container.read(imageGenerationNotifierProvider.notifier);
    final params = container
        .read(generationParamsNotifierProvider)
        .copyWith(prompt: '1girl', width: 512, height: 768);

    await notifier.generate(params);

    final state = container.read(imageGenerationNotifierProvider);
    expect(state.isSubmitting, isFalse);
    expect(state.isBusy, isFalse);
    expect(state.status, GenerationStatus.error);
    // copyWith 省略 errorMessage 等于清空，释放守卫时不能顺手吞掉失败原因。
    expect(state.errorMessage, contains('stream failed'));
  });

  test('terminal states never become preparing while the lock settles', () {
    for (final status in [
      GenerationStatus.completed,
      GenerationStatus.error,
      GenerationStatus.cancelled,
    ]) {
      final state = ImageGenerationState(status: status, isSubmitting: true);
      expect(state.isBusy, isTrue);
      expect(state.isPreparing, isFalse);
      expect(selectGenerationButtonViewData(state).isPreparing, isFalse);
    }
  });

  test(
    'delayed saving shows completed images, holds lock and ignores cancel',
    () async {
      final gate = Completer<void>();
      final gallery = _DelayedGallery(gate.future);
      final saveDirectory = await Directory.systemTemp.createTemp('nai_save_');
      addTearDown(() async {
        if (!gate.isCompleted) gate.complete();
        if (await saveDirectory.exists()) {
          await saveDirectory.delete(recursive: true);
        }
      });
      final image = Uint8List.fromList(
        img.encodePng(img.Image(width: 64, height: 64)),
      );
      var requests = 0;
      final api = _stubApi(
        onStream: () {
          requests++;
          return Stream.value(ImageStreamChunk.complete(image));
        },
      );
      final container = await _createContainer(
        api,
        overrides: [localGalleryNotifierProvider.overrideWith(() => gallery)],
      );
      await container
          .read(localStorageServiceProvider)
          .setImageSavePath(saveDirectory.path);
      addTearDown(
        () =>
            Hive.box(StorageKeys.settingsBox).delete(StorageKeys.imageSavePath),
      );
      await container
          .read(imageSaveSettingsNotifierProvider.notifier)
          .setAutoSave(true);
      final notifier = container.read(imageGenerationNotifierProvider.notifier);
      const params = ImageParams(prompt: 'save', width: 512, height: 768);
      final generation = notifier.generate(params);
      await _pumpUntil(() => gallery.entered);
      final saving = container.read(imageGenerationNotifierProvider);
      expect(saving.status, GenerationStatus.completed);
      expect(saving.displayImages, hasLength(1));
      expect(saving.isGenerating, isFalse);
      expect(saving.isPreparing, isFalse);
      expect(saving.isSaving, isTrue);
      expect(saving.isBusy, isTrue);
      expect(selectGenerationButtonViewData(saving).isPreparing, isFalse);
      notifier.cancel();
      notifier.skipCurrentRequest();
      expect(container.read(imageGenerationNotifierProvider).isBusy, isTrue);
      expect(
        container.read(imageGenerationNotifierProvider).status,
        GenerationStatus.completed,
      );
      await notifier.generate(params);
      expect(requests, 1);
      verifyNever(() => api.cancelGeneration(any()));
      gate.complete();
      await generation;
      final completed = container.read(imageGenerationNotifierProvider);
      expect(completed.isBusy, isFalse);
      expect(completed.isSaving, isFalse);
      expect(completed.saveErrorMessage, isNull);
      expect(completed.displayImages.single.filePath, isNotNull);
      final next = notifier.generate(params);
      expect(
        container.read(imageGenerationNotifierProvider).isPreparing,
        isTrue,
      );
      await next;
      expect(requests, 2);
      expect(container.read(imageGenerationNotifierProvider).isBusy, isFalse);
    },
  );

  test(
    'failed auto save keeps completed images and exposes a save failure',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'nai_save_failure_',
      );
      final blocker = File('${directory.path}/not-a-directory');
      await blocker.writeAsString('block directory creation');
      addTearDown(() => directory.delete(recursive: true));
      final image = Uint8List.fromList(
        img.encodePng(img.Image(width: 64, height: 64)),
      );
      final container = await _createContainer(
        _stubApi(
          onStream: () => Stream.value(ImageStreamChunk.complete(image)),
        ),
      );
      await container
          .read(localStorageServiceProvider)
          .setImageSavePath(blocker.path);
      addTearDown(
        () =>
            Hive.box(StorageKeys.settingsBox).delete(StorageKeys.imageSavePath),
      );
      await container
          .read(imageSaveSettingsNotifierProvider.notifier)
          .setAutoSave(true);
      final notifier = container.read(imageGenerationNotifierProvider.notifier);
      await notifier.generate(
        const ImageParams(prompt: 'save', width: 512, height: 768),
      );
      final failed = container.read(imageGenerationNotifierProvider);
      expect(failed.status, GenerationStatus.completed);
      expect(failed.displayImages, hasLength(1));
      expect(failed.displayImages.single.filePath, isNull);
      expect(failed.saveErrorMessage, contains('could not be saved'));
      expect(failed.isSaving, isFalse);
      expect(failed.isPreparing, isFalse);
      expect(failed.isBusy, isFalse);
      // 保存失败不阻止下一次生成；新调用清除上一轮保存提示。
      await container
          .read(imageSaveSettingsNotifierProvider.notifier)
          .setAutoSave(false);
      final next = notifier.generate(
        const ImageParams(prompt: 'next', width: 512, height: 768),
      );
      expect(
        container.read(imageGenerationNotifierProvider).saveErrorMessage,
        isNull,
      );
      await next;
      expect(container.read(imageGenerationNotifierProvider).isBusy, isFalse);
    },
  );

  test(
    'ordinary prepare error is visible without an API call, then retry works',
    () async {
      var requests = 0;
      final image = Uint8List.fromList(
        img.encodePng(img.Image(width: 64, height: 64)),
      );
      final endpoints = NaiApiEndpointService()
        ..setCurrent(
          NaiApiEndpointConfig.fromInput(
            mainBaseUrl: 'https://compatible.invalid',
            protocol: NaiApiProtocol.openAiCompatible,
          ),
        );
      addTearDown(endpoints.dispose);
      final container = await _createContainer(
        _stubApi(
          onStream: () {
            requests++;
            return Stream.value(ImageStreamChunk.complete(image));
          },
        ),
        overrides: [naiApiEndpointServiceProvider.overrideWithValue(endpoints)],
      );
      final notifier = container.read(imageGenerationNotifierProvider.notifier);
      await notifier.generate(
        const ImageParams(
          prompt: 'unsupported',
          width: 512,
          height: 768,
          e2eUpscale: true,
        ),
      );
      final failed = container.read(imageGenerationNotifierProvider);
      expect(requests, 0);
      expect(failed.status, GenerationStatus.error);
      expect(
        failed.errorMessage,
        contains('does not support end-to-end upscale'),
      );
      expect(failed.isPreparing, isFalse);
      expect(failed.isBusy, isFalse);
      endpoints.resetToOfficial();
      await notifier.generate(
        const ImageParams(prompt: 'retry', width: 512, height: 768),
      );
      expect(requests, 1);
      expect(
        container.read(imageGenerationNotifierProvider).status,
        GenerationStatus.completed,
      );
    },
  );

  test(
    'late preparation error after cancel cannot fail the new session',
    () async {
      final gate = Completer<String>();
      addTearDown(() {
        if (!gate.isCompleted) gate.complete('');
      });
      final image = Uint8List.fromList(
        img.encodePng(img.Image(width: 64, height: 64)),
      );
      var requests = 0;
      final preparingNotifier = _DelayedPreparationNotifier(gate.future);
      final container = await _createContainer(
        _stubApi(
          onStream: () {
            requests++;
            return Stream.value(ImageStreamChunk.complete(image));
          },
        ),
        overrides: [
          imageGenerationNotifierProvider.overrideWith(() => preparingNotifier),
        ],
      );
      // Overrides are lazy: creating the fixture does not attach Riverpod's
      // element/ref. Read through the container before calling real methods.
      final notifier = container.read(imageGenerationNotifierProvider.notifier);
      expect(notifier, same(preparingNotifier));
      container.read(randomPromptModeProvider.notifier).set(true);
      addTearDown(
        () => Hive.box(
          StorageKeys.settingsBox,
        ).delete(StorageKeys.randomPromptMode),
      );
      const params = ImageParams(prompt: 'session', width: 512, height: 768);
      final old = notifier.generate(params);
      await _pumpUntil(() => preparingNotifier.entered);
      notifier.cancel();
      final next = notifier.generate(params, bypassRandomPrompt: true);
      await next;
      gate.completeError(UnsupportedError('stale preparation'));
      await old;
      final state = container.read(imageGenerationNotifierProvider);
      expect(requests, 1);
      expect(state.status, GenerationStatus.completed);
      expect(state.errorMessage, isNull);
      expect(state.isBusy, isFalse);
    },
  );

  test('completed run releases the guard for the next submission', () async {
    final image = Uint8List.fromList(
      img.encodePng(img.Image(width: 512, height: 768)),
    );
    var streamCall = 0;
    final api = _stubApi(
      onStream: () {
        streamCall += 1;
        return Stream.value(ImageStreamChunk.complete(image));
      },
    );
    final container = await _createContainer(api);

    final notifier = container.read(imageGenerationNotifierProvider.notifier);
    final params = container
        .read(generationParamsNotifierProvider)
        .copyWith(prompt: '1girl', width: 512, height: 768);

    await notifier.generate(params);

    final completed = container.read(imageGenerationNotifierProvider);
    expect(completed.status, GenerationStatus.completed);
    expect(completed.isSubmitting, isFalse);
    expect(completed.isPreparing, isFalse);
    expect(completed.isBusy, isFalse);

    await notifier.generate(params);
    expect(streamCall, 2);
  });
}

class _DelayedGallery extends LocalGalleryNotifier {
  _DelayedGallery(this.gate);
  final Future<void> gate;
  bool entered = false;

  @override
  LocalGalleryState build() => const LocalGalleryState(isInitialized: true);

  @override
  Future<GalleryIndexAdmission> addNewlySavedImages(List<String> paths) async {
    entered = true;
    await gate;
    return GalleryIndexAdmission.added;
  }
}

class _DelayedPreparationNotifier extends ImageGenerationNotifier {
  _DelayedPreparationNotifier(this.gate);
  final Future<String> gate;
  bool entered = false;

  @override
  Future<String> generateAndApplyRandomPrompt({int? seed, String? model}) {
    entered = true;
    return gate;
  }
}

/// 停在请求发出后永不返回，模拟服务端仍在跑的生成。
Stream<ImageStreamChunk> _neverEmits() =>
    Completer<ImageStreamChunk>().future.asStream();

Future<void> _pumpUntil(bool Function() condition, {String? reason}) async {
  for (var i = 0; i < 400; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail(reason ?? 'Condition not met within timeout');
}

_MockApiService _stubApi({
  required Stream<ImageStreamChunk> Function() onStream,
}) {
  final api = _MockApiService();
  when(
    () => api.generateImage(
      any(),
      onProgress: any(named: 'onProgress'),
      focusedInpaintEnabled: any(named: 'focusedInpaintEnabled'),
      minimumContextMegaPixels: any(named: 'minimumContextMegaPixels'),
      focusedSelectionRect: any(named: 'focusedSelectionRect'),
      cancellationLease: null,
    ),
  ).thenAnswer((_) async => (<Uint8List>[], <int, String>{}));
  when(
    () => api.generateImageStream(
      any(),
      focusedInpaintEnabled: any(named: 'focusedInpaintEnabled'),
      minimumContextMegaPixels: any(named: 'minimumContextMegaPixels'),
      focusedSelectionRect: any(named: 'focusedSelectionRect'),
      cancellationLease: null,
    ),
  ).thenAnswer((_) => onStream());
  when(() => api.cancelGeneration(any())).thenReturn(null);
  return api;
}

Future<ProviderContainer> _createContainer(
  _MockApiService api, {
  List<Override> overrides = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      authNotifierProvider.overrideWith(_AuthenticatedAuthNotifier.new),
      naiImageGenerationApiServiceProvider.overrideWithValue(api),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  await container
      .read(notificationSettingsNotifierProvider.notifier)
      .setSoundEnabled(false);
  await container
      .read(imageSaveSettingsNotifierProvider.notifier)
      .setAutoSave(false);
  return container;
}
