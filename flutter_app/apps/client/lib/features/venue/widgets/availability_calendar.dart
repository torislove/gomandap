import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

enum DateState { available, booked, highDemand }

class AvailabilityCalendar extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;

  const AvailabilityCalendar({super.key, this.onDateSelected});

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  DateTime? _selectedDate;

  // Static mock states for a standard 30-day block starting from today
  final Map<int, DateState> _mockDateStates = {
    3: DateState.booked,
    4: DateState.booked,
    8: DateState.highDemand,
    9: DateState.highDemand,
    14: DateState.booked,
    15: DateState.booked,
    16: DateState.highDemand,
    22: DateState.booked,
    23: DateState.highDemand,
  };

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final currentMonth = _getMonthName(today.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Availability for $currentMonth ${today.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: GomandapTokens.royalNavy,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded, size: 12, color: GomandapTokens.emeraldGreen),
                  const SizedBox(width: 4),
                  Text('Updated Live', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: GomandapTokens.emeraldGreen)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Visual Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem('Available', GomandapTokens.emeraldGreen),
            _buildLegendItem('Booked', GomandapTokens.slateGray, isStrikethrough: true),
            _buildLegendItem('High Demand 🔥', GomandapTokens.champagneGoldEnd),
          ],
        ),
        const SizedBox(height: 16),

        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 30, // 30 days starting from today
          itemBuilder: (context, index) {
            final dayNumber = today.day + index;
            // Handle month rollover visually for mock simplicity
            final displayDay = dayNumber > 30 ? dayNumber - 30 : dayNumber;
            final dateState = _mockDateStates[displayDay] ?? DateState.available;
            
            final isSelected = _selectedDate?.day == displayDay;

            return _buildDateCell(displayDay, dateState, isSelected);
          },
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool isStrikethrough = false}) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: isStrikethrough ? Colors.transparent : color,
            border: isStrikethrough ? Border.all(color: color) : null,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: GomandapTokens.royalNavy.withValues(alpha: 0.8),
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCell(int day, DateState state, bool isSelected) {
    Color cellColor = Colors.white;
    Color textColor = GomandapTokens.royalNavy;
    Border? border = Border.all(color: GomandapTokens.lightSlate);
    Widget? activeBadge;

    if (state == DateState.booked) {
      cellColor = GomandapTokens.softMist.withValues(alpha: 0.5);
      textColor = GomandapTokens.slateGray.withValues(alpha: 0.5);
      border = null;
    } else if (state == DateState.highDemand) {
      cellColor = GomandapTokens.champagneGoldStart.withValues(alpha: 0.12);
      textColor = GomandapTokens.champagneGoldEnd;
      border = Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.5));
      activeBadge = const Positioned(
        top: 2, right: 2,
        child: Icon(Icons.bolt, size: 8, color: GomandapTokens.champagneGoldEnd),
      );
    }

    if (isSelected) {
      cellColor = GomandapTokens.emeraldGreen;
      textColor = Colors.white;
      border = null;
    }

    final isClickable = state != DateState.booked;

    return GestureDetector(
      onTap: isClickable
          ? () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, day);
              });
              if (widget.onDateSelected != null) {
                widget.onDateSelected!(_selectedDate!);
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected || state == DateState.highDemand
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: textColor,
                decoration: state == DateState.booked ? TextDecoration.lineThrough : null,
              ),
            ),
            if (activeBadge != null && !isSelected) activeBadge,
            if (state == DateState.available && !isSelected)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4, height: 4,
                  decoration: const BoxDecoration(
                    color: GomandapTokens.emeraldGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int monthIndex) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[monthIndex - 1];
  }
}

