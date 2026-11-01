import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint_service.dart';
import 'package:nai_launcher/data/models/character/character_prompt.dart';
import 'package:nai_launcher/data/repositories/character_prompt_repository.dart';
import 'package:nai_launcher/l10n/app_localizations.dart';
import 'package:nai_launcher/presentation/providers/character_prompt_provider.dart';
import 'package:nai_launcher/presentation/providers/character_position_canvas_provider.dart';
import 'package:nai_launcher/presentation/widgets/character/character_position_canvas.dart';
import 'package:nai_launcher/presentation/widgets/character/chat_character_position_picker.dart';

class _Repository extends CharacterPromptRepository {
  CharacterPromptConfig config = const CharacterPromptConfig(
    characters: [
      CharacterPrompt(id: 'a', name: 'Alice', prompt: 'girl'),
      CharacterPrompt(id: 'b', name: 'Bob', prompt: 'boy'),
    ],
  );
  @override
  CharacterPromptConfig load() => config;
  @override
  Future<bool> save(CharacterPromptConfig config) async {
    this.config = config;
    return true;
  }
}

void main() {
  test(
    'Chat profile makes continuous canvas unavailable before reading image state',
    () {
      final endpoints = NaiApiEndpointService()
        ..setCurrent(
          NaiApiEndpointConfig.fromInput(
            mainBaseUrl: 'https://example.invalid',
            protocol: NaiApiProtocol.openAiCompatible,
          ),
        );
      final container = ProviderContainer(
        overrides: [naiApiEndpointServiceProvider.overrideWithValue(endpoints)],
      );
      addTearDown(container.dispose);
      addTearDown(endpoints.dispose);
      expect(container.read(characterPositionCanvasAvailableProvider), false);
      container.read(characterPositionCanvasProvider.notifier).open();
      expect(container.read(characterPositionCanvasProvider), false);
    },
  );
  for (final width in [320.0, 600.0, 840.0, 1180.0, 1600.0]) {
    for (final scale in [1.0, 3.0]) {
      testWidgets('grid all cells reachable width=$width scale=$scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        CharacterPosition? selected;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: SingleChildScrollView(
                  child: ChatCharacterPositionGrid(
                    selected: 'C3',
                    onSelected: (value) => selected = value,
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.byType(TextButton), findsNWidgets(25));
        for (final label in ['A1', 'C3', 'E5']) {
          final cell = find.byKey(ValueKey('character-position-cell-$label'));
          await tester.ensureVisible(cell);
          await tester.tap(cell);
          expect(selected, isNotNull);
        }
        expect(selected!.column, 0.9);
        expect(selected!.row, 0.9);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final chat in [false, true]) {
    testWidgets('per-role selection and native AI parity chat=$chat', (
      tester,
    ) async {
      final repository = _Repository();
      final endpoints = NaiApiEndpointService();
      addTearDown(endpoints.dispose);
      if (chat) {
        endpoints.setCurrent(
          NaiApiEndpointConfig.fromInput(
            mainBaseUrl: 'https://example.invalid',
            protocol: NaiApiProtocol.openAiCompatible,
          ),
        );
      }
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            naiApiEndpointServiceProvider.overrideWithValue(endpoints),
            characterPromptRepositoryProvider.overrideWith((ref) => repository),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Column(
                children: [
                  CharacterPositionModeSegments(),
                  ChatCharacterPositionButton(characterId: 'a'),
                  ChatCharacterPositionButton(characterId: 'b'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final context = tester.element(find.byType(Scaffold).first);
      final container = ProviderScope.containerOf(context);
      final l10n = AppLocalizations.of(context)!;
      expect(
        find.text(l10n.characterCanvas_aiChoice),
        chat ? findsNothing : findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('character-position-a')),
        chat ? findsOneWidget : findsNothing,
      );
      if (!chat) {
        endpoints.setCurrent(
          NaiApiEndpointConfig.fromInput(
            mainBaseUrl: 'https://example.invalid',
            protocol: NaiApiProtocol.openAiCompatible,
          ),
        );
        // Endpoint invalidation propagates through the config projection before
        // the consumer rebuilds; wait for both frames, not just the first one.
        await tester.pumpAndSettle();
        expect(find.text(l10n.characterCanvas_aiChoice), findsNothing);
        expect(
          find.byKey(const ValueKey('character-position-a')),
          findsOneWidget,
        );
        expect(
          container.read(effectiveCharacterPromptConfigProvider).globalAiChoice,
          false,
        );
        endpoints.resetToOfficial();
        await tester.pumpAndSettle();
        expect(find.text(l10n.characterCanvas_aiChoice), findsOneWidget);
        expect(
          find.byKey(const ValueKey('character-position-a')),
          findsNothing,
        );
        expect(repository.config.globalAiChoice, true);
        return;
      }
      final before = container
          .read(characterPromptNotifierProvider)
          .characters
          .last;
      await tester.tap(find.byKey(const ValueKey('character-position-a')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatCharacterPositionGrid), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('character-position-cell-E1')),
      );
      await tester.pumpAndSettle();
      final saved = container.read(characterPromptNotifierProvider);
      expect(
        saved.globalAiChoice,
        true,
        reason: 'Native preference is not overwritten',
      );
      expect(saved.characters.first.customPosition?.column, 0.9);
      expect(saved.characters.first.customPosition?.row, 0.1);
      expect(saved.characters.last, before);
      expect(find.textContaining('E1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
