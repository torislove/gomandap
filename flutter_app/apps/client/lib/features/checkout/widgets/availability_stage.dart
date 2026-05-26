import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../../venue/widgets/availability_calendar.dart';
import '../checkout_notifier.dart';

class AvailabilityStage extends ConsumerWidget {
  const AvailabilityStage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutNotifierProvider);
    final notifier = ref.read(checkoutNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1: Event Schedule 🗓',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: GomandapTokens.royalNavy,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Please select the proposed date for your event celebration. High-demand dates are marked with a gold bolt.',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: GomandapTokens.slateGray,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),

        // Availability calendar
        AvailabilityCalendar(
          onDateSelected: (date) => notifier.selectDate(date),
        ),
        const SizedBox(height: 24),

        // Live selection feedback card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: state.selectedDate != null
                ? GomandapTokens.emeraldGreen.withValues(alpha: 0.08)
                : GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: state.selectedDate != null
                  ? GomandapTokens.emeraldGreen.withValues(alpha: 0.3)
                  : GomandapTokens.lightSlate,
            ),
          ),
          child: Row(
            children: [
              Icon(
                state.selectedDate != null ? Icons.event_available_rounded : Icons.info_outline_rounded,
                color: state.selectedDate != null ? GomandapTokens.emeraldGreen : GomandapTokens.royalNavy,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.selectedDate != null ? 'Date Confirmed' : 'Date Not Selected',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: state.selectedDate != null ? GomandapTokens.emeraldGreen : GomandapTokens.royalNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.selectedDate != null
                          ? 'Event scheduled for ${_formatDate(state.selectedDate!)}'
                          : 'Please choose an available date in the calendar above to proceed.',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: GomandapTokens.slateGray,
                      ),
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

