import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers/provider_billing_provider.dart';

/// Latest successful compatible response, distinct from the preflight estimate.
class ProviderBillingSummary extends ConsumerWidget {
  const ProviderBillingSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(providerBillingSummaryProvider);
    if (summary == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final amount = summary.formattedAmount;
    final label = amount == null
        ? summary.usage.actualModel == null
              ? l10n.providerBillingModelMissing
              : l10n.providerBillingUnknown
        : '${l10n.providerBillingFromUsage} $amount';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        Text(
          l10n.providerBillingNotWallet,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (summary.hasEncodingMismatch)
          Text(
            l10n.providerBillingEncodingMismatch,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
      ],
    );
  }
}
