import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

// ─── Bookings Screen ──────────────────────────────────────────────────────────

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Bookings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: GomandapTokens.emeraldGreen,
          unselectedLabelColor: GomandapTokens.slateGray,
          indicatorColor: GomandapTokens.emeraldGreen,
          indicatorWeight: 2,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Completed'), Tab(text: 'Cancelled')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BookingsList(status: 'upcoming'),
          _BookingsList(status: 'completed'),
          _BookingsList(status: 'cancelled'),
        ],
      ),
    );
  }
}

class _BookingsList extends StatelessWidget {
  final String status;
  const _BookingsList({required this.status});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final mockBookings = status == 'upcoming' ? [
      const _MockBooking(
        id: 'GM-2026-08741', vendorName: 'The Heritage Gala Resort',
        category: 'Venue', eventDate: '14 Aug 2026', guestCount: 300,
        totalAmount: '₹5,50,000', status: 'Confirmed',
        statusColor: GomandapTokens.emeraldGreen,
        milestoneProgress: 0.2,
      ),
      const _MockBooking(
        id: 'GM-2026-08742', vendorName: 'Lens & Light Studio',
        category: 'Photography', eventDate: '14 Aug 2026', guestCount: 0,
        totalAmount: '₹55,000', status: 'Pending',
        statusColor: GomandapTokens.warning,
        milestoneProgress: 0.0,
      ),
    ] : status == 'completed' ? [
      const _MockBooking(
        id: 'GM-2026-07210', vendorName: 'Bloom Floral Decor',
        category: 'Decor', eventDate: '22 Feb 2026', guestCount: 200,
        totalAmount: '₹75,000', status: 'Completed',
        statusColor: GomandapTokens.slateGray,
        milestoneProgress: 1.0,
      ),
    ] : [];

    if (mockBookings.isEmpty) {
      return _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: status == 'cancelled' ? 'No cancelled bookings' : 'No $status bookings',
        subtitle: 'Your $status bookings will appear here',
        ctaLabel: status == 'upcoming' ? 'Explore Venues' : null,
        onCta: status == 'upcoming' ? () => context.go('/home') : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: mockBookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _BookingCard(booking: mockBookings[i]),
    );
  }
}

class _MockBooking {
  final String id, vendorName, category, eventDate, totalAmount, status;
  final int guestCount;
  final Color statusColor;
  final double milestoneProgress;

  const _MockBooking({
    required this.id, required this.vendorName, required this.category,
    required this.eventDate, required this.guestCount, required this.totalAmount,
    required this.status, required this.statusColor, required this.milestoneProgress,
  });
}

class _BookingCard extends StatelessWidget {
  final _MockBooking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/escrow/${booking.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GomandapTokens.lightSlate),
          boxShadow: GomandapTokens.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: GomandapTokens.softMist,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(booking.category,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GomandapTokens.slateGray)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(booking.status,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: booking.statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(booking.vendorName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 13, color: GomandapTokens.slateGray),
                const SizedBox(width: 4),
                Text(booking.eventDate, style: const TextStyle(fontSize: 12, color: GomandapTokens.slateGray)),
                if (booking.guestCount > 0) ...[
                  const Text(' · ', style: TextStyle(color: GomandapTokens.slateGray)),
                  const Icon(Icons.people_outline_rounded, size: 13, color: GomandapTokens.slateGray),
                  const SizedBox(width: 4),
                  Text('${booking.guestCount} guests',
                    style: const TextStyle(fontSize: 12, color: GomandapTokens.slateGray)),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // Escrow Progress Bar
            if (booking.milestoneProgress > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Escrow Progress', style: TextStyle(fontSize: 11, color: GomandapTokens.slateGray, fontWeight: FontWeight.w600)),
                  Text('${(booking.milestoneProgress * 100).toInt()}% Released',
                    style: const TextStyle(fontSize: 11, color: GomandapTokens.emeraldGreen, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: booking.milestoneProgress,
                  backgroundColor: GomandapTokens.softMist,
                  valueColor: const AlwaysStoppedAnimation(GomandapTokens.emeraldGreen),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
                    Text(booking.totalAmount,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: GomandapTokens.royalNavy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('View Details', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const _EmptyState({
    required this.icon, required this.title, required this.subtitle,
    this.ctaLabel, this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                color: GomandapTokens.softMist,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: GomandapTokens.slateGray),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: GomandapTokens.slateGray),
              textAlign: TextAlign.center),
            if (ctaLabel != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onCta,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: GomandapTokens.emeraldGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(ctaLabel!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

