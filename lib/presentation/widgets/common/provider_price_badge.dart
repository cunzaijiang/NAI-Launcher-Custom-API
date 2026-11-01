import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/provider_pricing_service.dart';
import '../../../core/utils/localization_extension.dart';
import '../../providers/generation/image_workflow_controller.dart';
import '../../providers/image_generation_provider.dart';
import '../../providers/provider_pricing_provider.dart';

/// Non-interactive, unitless estimate: safe to use inside a generate button.
class ProviderPriceBadge extends ConsumerWidget {
  const ProviderPriceBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflow = ref.watch(imageWorkflowControllerProvider);
    if (workflow.isUpscale &&
        workflow.upscale.backend != UpscaleBackend.novelai) {
      return const SizedBox.shrink();
    }
    final pricing = ref.watch(providerPricingCatalogProvider);
    final estimate = ref.watch(providerPriceEstimateProvider);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        Text(
          context.l10n.providerPrice_estimate(estimate?.formatted ?? '--'),
          textAlign: TextAlign.center,
          // Inherit the button's foreground, including disabled/cancel states.
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.labelSmall?.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (pricing.isLoading)
          Semantics(
            label: context.l10n.providerPrice_refreshing,
            child: SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: DefaultTextStyle.of(context).style.color,
              ),
            ),
          ),
      ],
    );
  }
}

/// Shared responsive content; no nested tap, focus or refresh semantics.
class ProviderPricedButtonLabel extends StatelessWidget {
  const ProviderPricedButtonLabel({
    super.key,
    required this.label,
    this.icon,
    this.showCost = true,
  });

  final String label;
  final Widget? icon;
  final bool showCost;

  @override
  Widget build(BuildContext context) => Padding(
    // Wrapped, scaled text must not sit on the button's bottom edge, even
    // when its theme supplies only horizontal button padding.
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        if (icon != null) icon!,
        Text(label, textAlign: TextAlign.center),
        if (showCost) const ProviderPriceBadge(),
      ],
    ),
  );
}

/// A separate, keyboard/touch-accessible action; never submits generation.
class ProviderPriceRefreshButton extends ConsumerWidget {
  const ProviderPriceRefreshButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricing = ref.watch(providerPricingCatalogProvider);
    final supported = ref.watch(providerPricingOriginSupportedProvider);
    final model = ref.watch(
      generationParamsNotifierProvider.select((p) => p.model),
    );
    final l10n = context.l10n;
    final action = pricing.isLoading
        ? l10n.providerPrice_refreshing
        : l10n.providerPrice_refresh;
    return IconButton(
      key: const ValueKey('provider-price-refresh'),
      style: IconButton.styleFrom(
        minimumSize: const Size.square(44),
        maximumSize: const Size.square(44),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: supported && !pricing.isLoading
          ? () => ref.read(providerPricingCatalogProvider.notifier).refresh()
          : null,
      icon: const Icon(Icons.refresh_rounded),
      // Details are also available to screen readers, not only hover users.
      tooltip: '$action\n${_tooltip(context, pricing.valueOrNull, model)}',
    );
  }

  String _tooltip(
    BuildContext context,
    ProviderPricingResult? result,
    String model,
  ) {
    final l10n = context.l10n;
    final catalog = result?.catalog;
    final base = catalog?.evaluateAnlas(model, 0);
    final one = catalog?.evaluateAnlas(model, 1);
    final two = catalog?.evaluateAnlas(model, 2);
    if (catalog == null || base == null || one == null || two == null) {
      return '${l10n.providerPrice_unknown}\n${l10n.providerPrice_disclaimer}';
    }
    final local = catalog.fetchedAt.toLocal();
    final material = MaterialLocalizations.of(context);
    final updated =
        '${material.formatFullDate(local)} ${material.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
    final age = DateTime.now().toUtc().difference(catalog.fetchedAt);
    final stale =
        result!.isStale ||
        result.error != null ||
        age.isNegative ||
        age >= ProviderPricingService.cacheTtl;
    return '${l10n.providerPrice_details(formatProviderPriceMicros(base.amountMicros), formatProviderPriceMicros(two.amountMicros - one.amountMicros), catalog.pricingVersion, updated)}\n${stale ? l10n.providerPrice_stale : l10n.providerPrice_cached}\n${l10n.providerPrice_disclaimer}';
  }
}
