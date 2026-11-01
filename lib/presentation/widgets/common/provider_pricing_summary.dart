import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/generation/image_workflow_controller.dart';
import '../generation/provider_billing_summary.dart';
import 'provider_price_badge.dart';

/// Estimate stays inside the primary action; refresh is a sibling, never nested.
class ProviderPricedPrimaryAction extends StatelessWidget {
  const ProviderPricedPrimaryAction({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (constraints.hasBoundedWidth) Flexible(child: child) else child,
        const SizedBox(width: 4),
        const ProviderPriceRefreshButton(),
      ],
    ),
  );
}

/// Only the post-generation usage summary, not a second preflight price box.
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
      child: const ProviderBillingSummary(),
    );
  }
}
