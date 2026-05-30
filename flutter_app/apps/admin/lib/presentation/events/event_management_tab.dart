import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/core/utils/id_generator.dart';
import '../../application/event_booking_provider.dart';

class EventManagementTab extends ConsumerStatefulWidget {
  const EventManagementTab({super.key});

  @override
  ConsumerState<EventManagementTab> createState() => _EventManagementTabState();
}

class _EventManagementTabState extends ConsumerState<EventManagementTab> {
  String _activeFilter = 'All'; // 'All', 'Upcoming', 'Ongoing', 'Completed'

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(liveEventBookingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Bookings & Escrow Tracker 📊',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
        ),
        const SizedBox(height: 6),
        const Text(
          'Monitor live wedding bookings, check customer-to-vendor relationships, and release escrow funds instantaneously.',
          style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray),
        ),
        const SizedBox(height: 24),

        // Filter Chips (Portrait optimized horizontal scroll)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All'),
              _buildFilterChip('Upcoming'),
              _buildFilterChip('Ongoing'),
              _buildFilterChip('Completed'),
              _buildFilterChip('Disputed', color: GomandapTokens.error),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Bookings List Stream
        bookingsAsync.when(
          data: (allBookings) {
            // Apply filtering logic
            final filtered = allBookings.where((b) {
              final isDisputed = b.escrowStatus == 'Disputed' || b.escrowStatus == 'Cancelled';
              if (_activeFilter == 'All') return true;
              if (_activeFilter == 'Disputed' && isDisputed) return true;
              if (isDisputed) return false;
              if (_activeFilter == 'Completed' && b.currentMilestone == 3) return true;
              if (_activeFilter == 'Ongoing' && b.currentMilestone == 2) return true;
              if (_activeFilter == 'Upcoming' && b.currentMilestone == 1) return true;
              return false;
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                    'No $_activeFilter bookings found.',
                    style: const TextStyle(color: GomandapTokens.slateGray, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return _BookingCard(booking: filtered[index]);
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: GomandapTokens.champagneGoldStart),
          ),
          error: (err, stack) => Center(
            child: Text('Error loading live bookings: $err', style: const TextStyle(color: GomandapTokens.error)),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {Color? color}) {
    final isSel = _activeFilter == label;
    final accentColor = color ?? GomandapTokens.royalNavy;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _activeFilter = label);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? accentColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSel ? Colors.transparent : GomandapTokens.lightSlate),
          boxShadow: isSel
              ? [BoxShadow(color: accentColor.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.white : (color ?? GomandapTokens.slateGray),
            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final AdminBooking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandedBkgId = GomandapIdGenerator.formatBookingId(booking.id);
    final brandedCliId = GomandapIdGenerator.formatClientId(booking.clientId);
    final brandedVndId = GomandapIdGenerator.formatVendorId(booking.vendorId, booking.vendorCategory);
    
    final escrowState = ref.watch(escrowActionProvider);
    final isDisputed = booking.escrowStatus == 'Disputed' || booking.escrowStatus == 'Cancelled';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDisputed ? GomandapTokens.error.withValues(alpha: 0.02) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDisputed ? GomandapTokens.error.withValues(alpha: 0.3) : GomandapTokens.lightSlate),
        boxShadow: [
          BoxShadow(
            color: isDisputed ? GomandapTokens.error.withValues(alpha: 0.05) : GomandapTokens.royalNavy.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID + Category + Date
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GomandapTokens.royalNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  brandedBkgId,
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
                ),
              ),
              if (isDisputed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: GomandapTokens.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GomandapTokens.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 10, color: GomandapTokens.error),
                      const SizedBox(width: 4),
                      Text(
                        booking.escrowStatus.toUpperCase(),
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: GomandapTokens.error),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GomandapTokens.softMist,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.vendorCategory,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GomandapTokens.slateGray),
                ),
              ),
              if (booking.isClubbed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: GomandapTokens.emeraldGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link_rounded, size: 10, color: GomandapTokens.emeraldGreen),
                      SizedBox(width: 4),
                      Text(
                        'Clubbed Package',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: GomandapTokens.emeraldGreen),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 12, color: GomandapTokens.slateGray),
                  const SizedBox(width: 6),
                  Text(booking.eventDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Client & Vendor Info (Portrait layout: Column instead of Row)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GomandapTokens.softMist,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GomandapTokens.lightSlate),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.face_rounded, size: 16, color: Colors.blueAccent),
                    SizedBox(width: 6),
                    Text('CLIENT REGISTERED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.blueAccent)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(booking.clientName, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                const SizedBox(height: 4),
                Text(brandedCliId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: GomandapTokens.slateGray)),
                const SizedBox(height: 4),
                Text('📞 ${booking.clientPhone}', style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GomandapTokens.softMist,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GomandapTokens.lightSlate),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storefront_rounded, size: 16, color: GomandapTokens.champagneGoldStart),
                    SizedBox(width: 6),
                    Text('VENDOR PARTNER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.champagneGoldStart)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(booking.vendorName, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                const SizedBox(height: 4),
                Text(brandedVndId, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: GomandapTokens.slateGray)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 12, color: GomandapTokens.slateGray),
                    const SizedBox(width: 4),
                    Text(booking.vendorCity, style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: GomandapTokens.lightSlate),
          const SizedBox(height: 16),

          // Escrow Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Package Value', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${booking.totalAmount.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]},")}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDisputed ? GomandapTokens.error : GomandapTokens.emeraldGreen),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDisputed
                      ? GomandapTokens.error.withValues(alpha: 0.1)
                      : booking.currentMilestone == 3 
                          ? GomandapTokens.emeraldGreen.withValues(alpha: 0.1) 
                          : GomandapTokens.champagneGoldStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDisputed
                        ? GomandapTokens.error.withValues(alpha: 0.3)
                        : booking.currentMilestone == 3 
                            ? GomandapTokens.emeraldGreen.withValues(alpha: 0.3) 
                            : GomandapTokens.champagneGoldStart.withValues(alpha: 0.3)
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDisputed ? Icons.gavel_rounded : booking.currentMilestone == 3 ? Icons.check_circle_rounded : Icons.lock_clock_rounded,
                      size: 14,
                      color: isDisputed ? GomandapTokens.error : booking.currentMilestone == 3 ? GomandapTokens.emeraldGreen : GomandapTokens.champagneGoldStart,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      booking.escrowStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDisputed ? GomandapTokens.error : booking.currentMilestone == 3 ? GomandapTokens.emeraldGreen : GomandapTokens.champagneGoldStart,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Bar & Action Button
          if (isDisputed && booking.escrowStatus == 'Disputed') ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: escrowState.isLoading ? null : () {
                      HapticFeedback.heavyImpact();
                      ref.read(escrowActionProvider.notifier).resolveDispute(booking.id, 'Refunded to Client');
                    },
                    icon: escrowState.isLoading 
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: GomandapTokens.error, strokeWidth: 2))
                        : const Icon(Icons.undo_rounded, size: 16),
                    label: const Text('Refund Client', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: GomandapTokens.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      side: const BorderSide(color: GomandapTokens.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: escrowState.isLoading ? null : () {
                      HapticFeedback.heavyImpact();
                      ref.read(escrowActionProvider.notifier).resolveDispute(booking.id, 'Force Released to Vendor');
                    },
                    icon: escrowState.isLoading 
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.verified_user_rounded, size: 16),
                    label: const Text('Force Release', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GomandapTokens.emeraldGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: booking.currentMilestone / 3,
                      minHeight: 8,
                      backgroundColor: GomandapTokens.softMist,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        booking.currentMilestone == 3 ? GomandapTokens.emeraldGreen : GomandapTokens.champagneGoldStart,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                if (booking.currentMilestone < 3 && !isDisputed)
                  ElevatedButton.icon(
                    onPressed: escrowState.isLoading ? null : () {
                      HapticFeedback.heavyImpact();
                      ref.read(escrowActionProvider.notifier).releaseMilestone(booking.id, booking.currentMilestone);
                    },
                    icon: escrowState.isLoading 
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.outbox_rounded, size: 16),
                    label: const Text('Release Funds', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GomandapTokens.royalNavy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
