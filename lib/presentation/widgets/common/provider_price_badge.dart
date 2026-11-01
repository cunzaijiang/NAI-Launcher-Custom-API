import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/provider_pricing_service.dart';
import '../../../core/utils/localization_extension.dart';
import '../../providers/generation/image_workflow_controller.dart';
import '../../providers/image_generation_provider.dart';
import '../../providers/provider_pricing_provider.dart';

/// Click, keyboard activation, or touch refreshes public prices, never generates.
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
    final model = ref.watch(
      generationParamsNotifierProvider.select((p) => p.model),
    );
    final supported = ref.watch(providerPricingOriginSupportedProvider);
    final l10n = context.l10n;
    final label = estimate == null
        ? '--'
        : l10n.providerPrice_estimate(estimate.formatted);
    final tooltip = _tooltip(context, pricing.valueOrNull, model);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message:
            '$tooltip\n${pricing.isLoading ? l10n.providerPrice_refreshing : l10n.providerPrice_refresh}',
        child: Semantics(
          label: label,
          hint: tooltip,
          button: true,
          enabled: supported && !pricing.isLoading,
          child: Material(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: supported && !pricing.isLoading
                  ? () => ref
                        .read(providerPricingCatalogProvider.notifier)
                        .refresh()
                  : null,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 44,
                  minWidth: 44,
                  maxWidth: 140,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
