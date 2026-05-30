import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../shared/vendor_responsive_shell.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';

class VendorCalendarScreen extends StatefulWidget {
  const VendorCalendarScreen({super.key});

  @override
  State<VendorCalendarScreen> createState() => _VendorCalendarScreenState();
}

class _VendorCalendarScreenState extends State<VendorCalendarScreen> {
  final Map<int, String> _customSlots = {
    4: 'Booked',
    5: 'Available',
    10: 'Tentative',
    11: 'Tentative',
    12: 'Booked',
    18: 'Booked',
    24: 'Available',
    25: 'Available',
  };

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return VendorResponsiveShell(
      activePath: '/calendar',
      child: GomandapScreen(
        backgroundColor: GomandapTokens.royalNavy,
        useHorizontalPadding: false,
        useSafeAreaTop: true,
        useSafeAreaBottom: false,
        maxWidth: 1200.0,
        appBar: screenWidth <= 800
            ? AppBar(
                backgroundColor: GomandapTokens.royalNavy,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.pop();
                  },
                ),
                title: Text(
                  'Interactive Slots Editor',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              )
            : null, // Sidebar handles headers on wide screens
        body: Stack(
          children: [
            // 1. Filigree backdrop
            Positioned.fill(
              child: CustomPaint(
                painter: EthnicFiligreePainter(color: const Color(0x0CDFBA73)),
              ),
            ),

            // 2. Calendar scroll layout
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 100),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (screenWidth > 800) ...[
                      // Desktop Header banner
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: GomandapTokens.champagneGoldStart, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Slots Availability Editor',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (screenWidth <= 800) ...[
                      // Mobile View
                      _buildMonthSelectorCard(),
                      const SizedBox(height: 24),
                      _buildWeekHeaderRow(),
                      const SizedBox(height: 12),
                      _buildCalendarDaysGrid(),
                      const SizedBox(height: 28),
                      _buildStatusLegendsRow(),
                      const SizedBox(height: 36),
                      _buildInstructionsCard(),
                    ] else ...[
                      // Desktop View: Split Layout
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side: Calendar Grid
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildMonthSelectorCard(),
                                const SizedBox(height: 24),
                                _buildWeekHeaderRow(),
                                const SizedBox(height: 12),
                                _buildCalendarDaysGrid(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          // Right side: Legend and Instructions
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LEGEND & STATUS',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: GomandapTokens.champagneGoldStart,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildStatusLegendsRow(),
                                const SizedBox(height: 36),
                                Text(
                                  'INSTRUCTIONS',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: GomandapTokens.champagneGoldStart,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInstructionsCard(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: GomandapTokens.champagneGoldStart, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tapping on a slot date dynamically cycles its booking status. Changes update client detail views instantly.',
              style: TextStyle(
                fontSize: 10,
                height: 1.4,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelectorCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 16),
            onPressed: () {},
          ),
          Text(
            'October 2026',
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildWeekHeaderRow() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((d) {
        return SizedBox(
          width: 38,
          child: Center(
            child: Text(
              d,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarDaysGrid() {
    // Shifting calendar start day offset (October 2026 starts on Thursday -> index 3 offset)
    const int offset = 3;
    const int totalDays = 31;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: totalDays + offset,
      itemBuilder: (context, index) {
        if (index < offset) {
          return const SizedBox.shrink();
        }

        final int day = index - offset + 1;
        final String status = _customSlots[day] ?? 'Available';

        Color cellColor;
        Color borderCellColor;
        Color textColor = Colors.white;

        if (status == 'Booked') {
          cellColor = const Color(0xFF991B1B); // Solid Deep Crimson
          borderCellColor = const Color(0xFFEF4444).withValues(alpha: 0.5);
        } else if (status == 'Tentative') {
          cellColor = const Color(0xFFB45309); // Solid Golden Amber
          borderCellColor = const Color(0xFFF59E0B).withValues(alpha: 0.5);
        } else {
          cellColor = GomandapTokens.royalNavyLight;
          borderCellColor = Colors.white.withValues(alpha: 0.08);
          textColor = Colors.white60;
        }

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (status == 'Available') {
                _customSlots[day] = 'Tentative';
              } else if (status == 'Tentative') {
                _customSlots[day] = 'Booked';
              } else {
                _customSlots[day] = 'Available';
              }
            });

            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Date Oct $day slot status updated to ${_customSlots[day]}. 🚀'),
                backgroundColor: GomandapTokens.royalNavy,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderCellColor, width: 1),
            ),
            child: Center(
              child: Text(
                '$day',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusLegendsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Available', GomandapTokens.royalNavyLight, Colors.white10),
        _buildLegendItem('Tentative / Hold', const Color(0xFFB45309), const Color(0xFFF59E0B).withValues(alpha: 0.5)),
        _buildLegendItem('Fully Booked', const Color(0xFF991B1B), const Color(0xFFEF4444).withValues(alpha: 0.5)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, Color border) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border, width: 0.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
