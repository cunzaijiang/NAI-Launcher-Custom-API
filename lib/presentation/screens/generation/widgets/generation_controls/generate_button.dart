import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nai_launcher/core/utils/localization_extension.dart';
import 'package:nai_launcher/presentation/providers/generation/image_generation_selectors.dart';
import 'package:nai_launcher/presentation/widgets/common/themed_button.dart';
import 'package:nai_launcher/presentation/widgets/common/anlas_cost_badge.dart';
import 'package:nai_launcher/presentation/widgets/common/provider_pricing_summary.dart';
import 'package:nai_launcher/presentation/widgets/common/provider_price_badge.dart';
import 'package:nai_launcher/presentation/providers/provider_pricing_provider.dart';

/// 集成价格徽章的生成按钮
class GenerateButtonWithCost extends ConsumerWidget {
  final bool isGenerating;
  final bool showCancel;
  final GenerationButtonViewData batchStatus;
  final int cooldownRemainingSeconds;
  final VoidCallback onGenerate;
  final VoidCallback onCancel;
  final VoidCallback onSkipCurrent;
  final bool showCost;
  final bool requiresLogin;
  final bool compact;
  final bool isSaving;
  final bool isFinishing;

  /// Desktop places refresh/usage in the existing footer slots, outside primary.
  final bool showPricingActions;

  /// 按钮高度（紧凑布局可压低）
  final double height;

  const GenerateButtonWithCost({
    super.key,
    required this.isGenerating,
    required this.showCancel,
    required this.batchStatus,
    this.cooldownRemainingSeconds = 0,
    required this.onGenerate,
    required this.onCancel,
    required this.onSkipCurrent,
    this.showCost = true,
    this.requiresLogin = false,
    this.compact = false,
    this.isSaving = false,
    this.isFinishing = false,
    this.showPricingActions = true,
    this.height = 48,
  });

  bool get _canSkipCurrentBatch =>
      showCancel &&
      batchStatus.currentImage > 0 &&
      batchStatus.totalImages > batchStatus.currentImage;

  /// 已提交但还没开跑，此时按钮必须立刻反馈，否则点击会被静默吞掉。
  bool get _isPreparing => batchStatus.isPreparing;

  bool get _showCancelAction => showCancel || _isPreparing;

  String _progressText() =>
      '${batchStatus.currentImage}/${batchStatus.totalImages}';

  String _generateLabelText(BuildContext context) {
    if (isSaving) return context.l10n.common_saving;
    if (isFinishing) return context.l10n.comfyWorkflow_processing;
    if (requiresLogin && !isGenerating) {
      return context.l10n.auth_login;
    }
    if (isGenerating) {
      return batchStatus.totalImages > 1
          ? _progressText()
          : context.l10n.generation_generating;
    }
    if (cooldownRemainingSeconds > 0) {
      return context.l10n.generation_cooldownRemaining(
        cooldownRemainingSeconds,
      );
    }
    return context.l10n.generation_generate;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerPricing = ref.watch(customProviderPricingVisibleProvider);
    final button = _buildPrimaryButton(
      context,
      providerPricing: providerPricing,
    );
    final primaryButton =
        showPricingActions && providerPricing && showCost && !requiresLogin
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProviderPricedPrimaryAction(child: button),
              const SizedBox(height: 4),
              ProviderPricingSummary(isGenerating: isGenerating),
            ],
          )
        : button;

    final skipButton = ThemedButton(
      onPressed: onSkipCurrent,
      icon: const Icon(Icons.skip_next),
      label: Text(
        '${context.l10n.generation_skipCurrentBatch} ${_progressText()}',
        textAlign: TextAlign.center,
      ),
      style: ThemedButtonStyle.outlined,
    );
    final largeText = MediaQuery.textScalerOf(context).scale(14) > 18.2;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: !_canSkipCurrentBatch
          ? primaryButton
          : LayoutBuilder(
              builder: (context, constraints) {
                if (largeText ||
                    (providerPricing &&
                        constraints.hasBoundedWidth &&
                        constraints.maxWidth < 440)) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    // The footer measures with unbounded width first.
                    crossAxisAlignment: constraints.hasBoundedWidth
                        ? CrossAxisAlignment.stretch
                        : CrossAxisAlignment.center,
                    children: [
                      skipButton,
                      const SizedBox(height: 8),
                      primaryButton,
                    ],
                  );
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (providerPricing && constraints.hasBoundedWidth)
                      Flexible(child: skipButton)
                    else
                      skipButton,
                    const SizedBox(width: 8),
                    if (providerPricing && constraints.hasBoundedWidth)
                      Flexible(child: primaryButton)
                    else
                      primaryButton,
                  ],
                );
              },
            ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context, {
    required bool providerPricing,
  }) {
    final theme = Theme.of(context);
    final cancelTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: theme.colorScheme.errorContainer,
        onPrimary: theme.colorScheme.onErrorContainer,
        primaryContainer: theme.colorScheme.error,
        onPrimaryContainer: theme.colorScheme.onError,
      ),
    );
    // Krita 占用时启动器自身没有可取消的任务，只能转圈禁用等待。
    final isLoading = isGenerating && !_showCancelAction;

    final buttonTheme = _showCancelAction ? cancelTheme : theme;
    final effectiveTheme = compact
        ? buttonTheme.copyWith(
            filledButtonTheme: FilledButtonThemeData(
              style:
                  buttonTheme.filledButtonTheme.style?.copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ) ??
                  const ButtonStyle(
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
            ),
          )
        : buttonTheme;

    return AnimatedTheme(
      data: effectiveTheme,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: ThemedButton(
        onPressed: isSaving || isFinishing
            ? null
            : _showCancelAction
            ? onCancel
            : requiresLogin
            ? onGenerate
            : isGenerating || cooldownRemainingSeconds > 0
            ? null
            : onGenerate,
        isLoading: isLoading,
        label: IndexedStack(
          index: _showCancelAction ? 1 : 0,
          alignment: Alignment.center,
          children: [
            if (providerPricing)
              ProviderPricedButtonLabel(
                label: showCancel
                    ? context.l10n.generation_generate
                    : _generateLabelText(context),
                icon: isLoading
                    ? null
                    : Icon(
                        requiresLogin
                            ? Icons.login_rounded
                            : cooldownRemainingSeconds > 0
                            ? Icons.hourglass_bottom_outlined
                            : Icons.auto_awesome,
                      ),
                showCost: showCost && !requiresLogin,
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isLoading) ...[
                    Icon(
                      requiresLogin
                          ? Icons.login_rounded
                          : cooldownRemainingSeconds > 0
                          ? Icons.hourglass_bottom_outlined
                          : Icons.auto_awesome,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    showCancel
                        ? context.l10n.generation_generate
                        : _generateLabelText(context),
                  ),
                  if (showCost && !requiresLogin && !providerPricing)
                    AnlasCostBadge(isGenerating: isLoading),
                ],
              ),
            if (providerPricing)
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (_isPreparing)
                    const GenerateButtonSpinner()
                  else
                    const Icon(Icons.stop_circle_outlined),
                  Text(context.l10n.common_cancel, textAlign: TextAlign.center),
                ],
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isPreparing)
                    const GenerateButtonSpinner()
                  else
                    const Icon(Icons.stop_circle_outlined),
                  const SizedBox(width: 8),
                  Text(context.l10n.common_cancel),
                ],
              ),
          ],
        ),
        style: ThemedButtonStyle.filled,
      ),
    );
  }
}

/// 跟随按钮前景色的小转圈，供准备期的可取消态复用。
class GenerateButtonSpinner extends StatelessWidget {
  const GenerateButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: IconTheme.of(context).color,
      ),
    );
  }
}
