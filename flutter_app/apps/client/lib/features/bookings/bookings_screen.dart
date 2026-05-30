import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/data/repository_impl/escrow_repository_impl.dart';
import 'package:gomandap_common/domain/models/escrow.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:intl/intl.dart';
import '../../core/i18n/i18n_notifier.dart';

// ─── Bookings Screen ──────────────────────────────────────────────────────────

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
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
    final bookingsAsync = ref.watch(clientBookingsProvider);

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Consumer(
          builder: (context, r, _) => Text(
            r.watch(i18nProvider).t('bookings.title'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
          ),
        ),
        actions: [
          if (bookingsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else if (bookingsAsync.hasValue)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  const Icon(Icons.wifi_tethering, color: Colors.green, size: 14),
                  const SizedBox(width: 4),
                  const Text('Live', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: GomandapTokens.emeraldGreen,
          unselectedLabelColor: GomandapTokens.slateGray,
          indicatorColor: GomandapTokens.emeraldGreen,
          indicatorWeight: 2,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Consumer(builder: (context, r, _) => Tab(text: r.watch(i18nProvider).t('bookings.upcoming'))),
            Consumer(builder: (context, r, _) => Tab(text: r.watch(i18nProvider).t('bookings.completed'))),
            Consumer(builder: (context, r, _) => Tab(text: r.watch(i18nProvider).t('bookings.cancelled'))),
          ],
        ),
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _BookingsList(bookings: const [], status: 'upcoming'),
        data: (_) => TabBarView(
          controller: _tabController,
          children: [
            Consumer(builder: (_, r, __) => _BookingsList(bookings: r.watch(upcomingBookingsProvider), status: 'upcoming')),
            Consumer(builder: (_, r, __) => _BookingsList(bookings: r.watch(completedBookingsProvider), status: 'completed')),
            Consumer(builder: (_, r, __) => _BookingsList(bookings: r.watch(cancelledBookingsProvider), status: 'cancelled')),
          ],
        ),
      ),
    );
  }
}

class _BookingsList extends ConsumerWidget {
  final List<Booking> bookings;
  final String status;
  const _BookingsList({required this.bookings, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(i18nProvider);

    if (bookings.isEmpty) {
      return _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: tr.t('bookings.empty_${status}_title'),
        subtitle: tr.t('bookings.empty_${status}_sub'),
        ctaLabel: status == 'upcoming' ? tr.t('bookings.explore_venues') : null,
        onCta: status == 'upcoming' ? () => context.go('/home') : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final booking = bookings[idx];
        return _BookingCard(booking: booking);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.confirmed: return GomandapTokens.emeraldGreen;
      case BookingStatus.pending: return GomandapTokens.champagneGoldEnd;
      case BookingStatus.cancelled: return Colors.redAccent;
      case BookingStatus.completed: return GomandapTokens.royalNavy;
      default: return GomandapTokens.slateGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(booking.eventDate);
    final formattedAmount = '₹${(booking.totalAmount / 1000).toStringAsFixed(0)}K';

    return GestureDetector(
      onTap: () => context.push('/booking/${booking.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GomandapTokens.lightSlate),
          boxShadow: GomandapTokens.softShadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: booking.vendorImageUrl != null && booking.vendorImageUrl!.isNotEmpty
                  ? Image.network(booking.vendorImageUrl!, width: 64, height: 64, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage())
                  : _placeholderImage(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.vendorName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(booking.vendorCategory,
                    style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: GomandapTokens.slateGray),
                      const SizedBox(width: 4),
                      Text(formattedDate,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy)),
                      const SizedBox(width: 12),
                      const Icon(Icons.people_rounded, size: 12, color: GomandapTokens.slateGray),
                      const SizedBox(width: 4),
                      Text('${booking.guestCount} Pax',
                        style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: _statusColor, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(formattedAmount,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: GomandapTokens.slateGray),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: GomandapTokens.softMist,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.store_rounded, color: GomandapTokens.slateGray, size: 28),
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
