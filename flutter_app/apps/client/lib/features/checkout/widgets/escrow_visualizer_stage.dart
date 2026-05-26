import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../checkout_notifier.dart';

class EscrowVisualizerStage extends ConsumerWidget {
  const EscrowVisualizerStage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);
    final milestones = state.milestones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3: Escrow Milestones 🛡',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: GomandapTokens.royalNavy,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your funds are protected. Milestone payments are released to the vendor only when pre-defined event milestones are met.',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: GomandapTokens.slateGray,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),

        // Vertical Milestone Timeline
        ...milestones.asMap().entries.map((entry) {
          final index = entry.key;
          final milestone = entry.value;
          final isLast = index == milestones.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline Connector Dot + Line
                Column(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: milestone.status == 'Released'
                            ? GomandapTokens.emeraldGreen
                            : milestone.status == 'Held'
                                ? GomandapTokens.champagneGoldEnd
                                : GomandapTokens.lightSlate,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          milestone.status == 'Released'
                              ? Icons.done_rounded
                              : milestone.status == 'Held'
                                  ? Icons.hourglass_empty_rounded
                                  : Icons.lock_outline_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: GomandapTokens.lightSlate,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Milestone Detail Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                milestone.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: GomandapTokens.royalNavy,
                                ),
                              ),
                            ),
                            Text(
                              '₹${milestone.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: GomandapTokens.royalNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${milestone.percentage}% · ${milestone.trigger}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: GomandapTokens.slateGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Platform Trust Badge Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GomandapTokens.emeraldGreen.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GomandapTokens.emeraldGreen.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: GomandapTokens.emeraldGreen, size: 24),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GoMandap Escrow Promise 🔒',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GomandapTokens.emeraldGreen),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'If the vendor fails to deliver specified amenities, dispute resolution ensures your held funds are safely returned.',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: GomandapTokens.slateGray, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

