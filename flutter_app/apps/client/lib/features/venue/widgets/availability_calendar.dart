import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

enum DateState { available, booked }

class AvailabilityCalendar extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;

  const AvailabilityCalendar({super.key, this.onDateSelected});

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  DateTime? _selectedDate;
  String _selectedPanchangam = 'Telugu'; // 'Telugu', 'Tamil', 'North'

  // Auspicious dates definitions based on regional Panchangams
  final Map<String, List<int>> _auspiciousDates = {
    'Telugu': [6, 7, 8, 14, 15, 23, 24, 28, 29],
    'Tamil': [7, 8, 15, 24, 28],
    'North': [6, 7, 8, 14, 15, 24, 29, 30],
  };

  // Astrological Panchangam details for each auspicious day
  final Map<String, Map<int, Map<String, String>>> _panchangamDetails = {
    'Telugu': {
      6: {'tithi': 'Dwadasi', 'nakshatram': 'Chitta', 'muhurtham': 'Amrutha Kalam: 09:30 AM - 11:00 AM'},
      7: {'tithi': 'Trayodasi', 'nakshatram': 'Swati', 'muhurtham': 'Abhijit Muhurtham: 11:45 AM - 12:35 PM'},
      8: {'tithi': 'Chaturdasi', 'nakshatram': 'Visakha', 'muhurtham': 'Subha Lagna: 08:15 AM - 10:00 AM'},
      14: {'tithi': 'Dwadasi', 'nakshatram': 'Uttara', 'muhurtham': 'Amrutha Kalam: 10:15 AM - 11:45 AM'},
      15: {'tithi': 'Trayodasi', 'nakshatram': 'Hasta', 'muhurtham': 'Abhijit Muhurtham: 11:45 AM - 12:35 PM'},
      23: {'tithi': 'Sapthami', 'nakshatram': 'Rohini', 'muhurtham': 'Subha Lagna: 07:30 AM - 09:15 AM'},
      24: {'tithi': 'Ashtami', 'nakshatram': 'Mrigasira', 'muhurtham': 'Amrutha Kalam: 03:20 PM - 04:50 PM'},
      28: {'tithi': 'Dwadasi', 'nakshatram': 'Chitta', 'muhurtham': 'Subha Lagna: 08:30 AM - 10:15 AM'},
      29: {'tithi': 'Trayodasi', 'nakshatram': 'Swati', 'muhurtham': 'Abhijit Muhurtham: 11:45 AM - 12:35 PM'},
    },
    'Tamil': {
      7: {'tithi': 'Valarpirai Dwadasi', 'nakshatram': 'Swathi', 'muhurtham': 'Subha Muhurtham: 09:00 AM - 10:30 AM'},
      8: {'tithi': 'Valarpirai Trayodasi', 'nakshatram': 'Visakam', 'muhurtham': 'Gowri Nalla Neram: 12:15 PM - 01:15 PM'},
      15: {'tithi': 'Valarpirai Dwadasi', 'nakshatram': 'Hastham', 'muhurtham': 'Subha Muhurtham: 09:15 AM - 10:45 AM'},
      24: {'tithi': 'Valarpirai Ashtami', 'nakshatram': 'Mirugaseerisham', 'muhurtham': 'Gowri Nalla Neram: 04:30 PM - 05:30 PM'},
      28: {'tithi': 'Valarpirai Dwadasi', 'nakshatram': 'Chithirai', 'muhurtham': 'Subha Muhurtham: 08:45 AM - 10:15 AM'},
    },
    'North': {
      6: {'tithi': 'Shukla Dwadashi', 'nakshatra': 'Chitra', 'muhurtham': 'Vivah Lagna: 09:15 AM - 11:30 AM'},
      7: {'tithi': 'Shukla Trayodashi', 'nakshatra': 'Swati', 'muhurtham': 'Abhijit Muhurat: 11:45 AM - 12:40 PM'},
      8: {'tithi': 'Shukla Chaturdashi', 'nakshatra': 'Vishakha', 'muhurtham': 'Gauri Puja Time: 07:30 AM - 09:00 AM'},
      14: {'tithi': 'Krishna Dwadashi', 'nakshatra': 'Uttara Phalguni', 'muhurtham': 'Vivah Lagna: 10:00 AM - 12:15 PM'},
      15: {'tithi': 'Krishna Trayodashi', 'nakshatra': 'Hasta', 'muhurtham': 'Abhijit Muhurat: 11:45 AM - 12:40 PM'},
      24: {'tithi': 'Shukla Ashtami', 'nakshatra': 'Mrigashirsha', 'muhurtham': 'Shubh Vivah Time: 07:45 AM - 09:30 AM'},
      29: {'tithi': 'Shukla Dwadashi', 'nakshatra': 'Swati', 'muhurtham': 'Vivah Lagna: 10:30 AM - 12:45 PM'},
      30: {'tithi': 'Shukla Trayodashi', 'nakshatra': 'Vishakha', 'muhurtham': 'Abhijit Muhurat: 11:45 AM - 12:40 PM'},
    },
  };

  // Pre-configured booked dates to simulate live vendor reservation conflicts
  final List<int> _bookedDates = [3, 4, 12, 19, 20, 26];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final currentMonth = _getMonthName(today.month);
    final auspiciousList = _auspiciousDates[_selectedPanchangam] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Slot Availability ($currentMonth)',
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
                  Text('Supabase Synced', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: GomandapTokens.emeraldGreen)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Regional Panchangam selector pills
        Text(
          'Select Regional Panchangam Almanac:',
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.slateGray),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildPanchangamPill('Telugu', 'Telugu Panchangam ☀️'),
            const SizedBox(width: 6),
            _buildPanchangamPill('Tamil', 'Tamil Panchangam ☀️'),
            const SizedBox(width: 6),
            _buildPanchangamPill('North', 'North Vivah Muhurat ☀️'),
          ],
        ),
        const SizedBox(height: 16),

        // Visual Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem('Available', GomandapTokens.emeraldGreen),
            _buildLegendItem('Booked', GomandapTokens.slateGray, isStrikethrough: true),
            _buildLegendItem('Panchangam Muhurtham ✨', const Color(0xFFDFBA73)),
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
            final displayDay = dayNumber > 30 ? dayNumber - 30 : dayNumber;

            DateState state = DateState.available;
            if (_bookedDates.contains(displayDay)) {
              state = DateState.booked;
            }

            final isAuspicious = auspiciousList.contains(displayDay);
            final isSelected = _selectedDate?.day == displayDay;

            return _buildDateCell(displayDay, state, isAuspicious, isSelected);
          },
        ),
        const SizedBox(height: 16),

        // Selected Date Panchangam astrological information panel
        if (_selectedDate != null) _buildAstrologyPanel(),
      ],
    );
  }

  Widget _buildPanchangamPill(String key, String label) {
    final isActive = _selectedPanchangam == key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedPanchangam = key;
          _selectedDate = null; // Clear active selected date when switching almanacs
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? GomandapTokens.royalNavy : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? GomandapTokens.royalNavy : GomandapTokens.lightSlate,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: isActive ? Colors.white : GomandapTokens.royalNavy,
          ),
        ),
      ),
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: GomandapTokens.royalNavy.withValues(alpha: 0.8),
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDateCell(int day, DateState state, bool isAuspicious, bool isSelected) {
    Color cellColor = Colors.white;
    Color textColor = GomandapTokens.royalNavy;
    Border? border = Border.all(color: GomandapTokens.lightSlate);
    Widget? activeBadge;

    if (state == DateState.booked) {
      cellColor = GomandapTokens.softMist.withValues(alpha: 0.5);
      textColor = GomandapTokens.slateGray.withValues(alpha: 0.5);
      border = null;
    } else if (isAuspicious) {
      cellColor = const Color(0xFFDFBA73).withValues(alpha: 0.12);
      textColor = const Color(0xFFC5A059);
      border = Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.6), width: 1.5);
      activeBadge = const Positioned(
        top: 2, right: 2,
        child: Icon(Icons.star_rounded, size: 8, color: Color(0xFFDFBA73)),
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
              : isAuspicious
                  ? [
                      BoxShadow(
                        color: const Color(0xFFDFBA73).withValues(alpha: 0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
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
                fontSize: 13,
                fontWeight: isSelected || isAuspicious
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: textColor,
                decoration: state == DateState.booked ? TextDecoration.lineThrough : null,
              ),
            ),
            if (activeBadge != null && !isSelected) activeBadge,
            if (state == DateState.available && !isAuspicious && !isSelected)
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

  Widget _buildAstrologyPanel() {
    final dayNum = _selectedDate!.day;
    final details = _panchangamDetails[_selectedPanchangam]?[dayNum];

    final isAuspicious = details != null;
    final title = isAuspicious ? '✨ Auspicious Muhurtham Selected!' : 'Slot Available';
    final bgColor = isAuspicious 
        ? const Color(0xFFDFBA73).withValues(alpha: 0.08)
        : GomandapTokens.emeraldGreen.withValues(alpha: 0.06);
    final borderColor = isAuspicious
        ? const Color(0xFFDFBA73).withValues(alpha: 0.25)
        : GomandapTokens.emeraldGreen.withValues(alpha: 0.15);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAuspicious ? Icons.verified_user_rounded : Icons.check_circle_outline_rounded,
                color: isAuspicious ? const Color(0xFFC5A059) : GomandapTokens.emeraldGreen,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isAuspicious ? const Color(0xFFB08C45) : GomandapTokens.emeraldGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isAuspicious) ...[
            Text(
              '• Tithi / Lunar Phase: ${details['tithi']}',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy),
            ),
            const SizedBox(height: 2),
            Text(
              '• Nakshatram / Star: ${details['nakshatram'] ?? details['nakshatra']}',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy),
            ),
            const SizedBox(height: 2),
            Text(
              '• Timing: ${details['muhurtham']}',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy),
            ),
          ] else ...[
            Text(
              'No high-demand or special Panchangam Muhurtham recorded on this date. Perfect for standard event packages or customized bookings!',
              style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w500, color: GomandapTokens.slateGray),
            ),
          ]
        ],
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
