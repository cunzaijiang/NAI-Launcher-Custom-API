import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/generation/image_workflow_controller.dart';
import '../generation/provider_billing_summary.dart';
import 'provider_price_badge.dart';

/// Provider pricing is outside the generate button: refresh must not generate,
/// and large text must grow vertically rather than crowd its action label.
class ProviderPricingSummary extends ConsumerWidget {
  const ProviderPricingSummary({super.key, required this.isGenerating});

  final bool isGenerating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflow = ref.watch(imageWorkflowControllerProvider);
    if (workflow.isUpscale &&
        workflow.upscale.backend != UpscaleBackend.novelai) {
      return const SizedBox.shrink();
    }
    return ConstrainedBox(
      // The desktop footer first measures its action with unbounded width.
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isGenerating) const ProviderPriceBadge(),
          const ProviderBillingSummary(),
        ],
      ),
    );
  }
}
