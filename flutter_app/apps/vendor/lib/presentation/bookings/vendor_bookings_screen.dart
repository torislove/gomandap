import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/vendor_bookings_provider.dart';

class VendorBookingsScreen extends ConsumerStatefulWidget {
  const VendorBookingsScreen({super.key});

  @override
  ConsumerState<VendorBookingsScreen> createState() => _VendorBookingsScreenState();
}

class _VendorBookingsScreenState extends ConsumerState<VendorBookingsScreen>
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
    return GomandapScreen(
      backgroundColor: GomandapTokens.royalNavy,
      useHorizontalPadding: false,
      useSafeAreaTop: true,
      useSafeAreaBottom: false,
      appBar: AppBar(
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
          'Escrow Bookings Manager',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: GomandapTokens.champagneGoldStart,
          labelColor: GomandapTokens.champagneGoldStart,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          tabs: const [
            Tab(text: 'Proposals'),
            Tab(text: 'Active Escrows'),
            Tab(text: 'Disputes & Past'),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. Filigree backdrop overlay
          Positioned.fill(
            child: CustomPaint(
              painter: EthnicFiligreePainter(color: const Color(0x0CDFBA73)),
            ),
          ),

          // 2. Tab Bar Views
          TabBarView(
            controller: _tabController,
            children: [
              _buildUpcomingBookingsTab(),
              _buildCompletedBookingsTab(),
              _buildDisputesBookingsTab(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingBookingsTab() {
    final bookingsAsync = ref.watch(vendorBookingsProvider);
    
    return bookingsAsync.when(
      data: (bookings) {
        final pending = bookings.where((b) => b.escrowStatus == 'Pending').toList();
        if (pending.isEmpty) {
          return const Center(child: Text('No pending proposals.', style: TextStyle(color: Colors.white)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: pending.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            final b = pending[i];
            return _buildBookingRow(
              id: b.id,
              title: 'Wedding Event',
              client: b.clientName,
              date: b.eventDate,
              price: '₹${b.totalAmount}',
              step: 'Awaiting your acceptance',
              status: 'Proposal Pending',
              statusColor: GomandapTokens.champagneGoldStart,
              isDisputed: false,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: GomandapTokens.champagneGoldStart)),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: GomandapTokens.error))),
    );
  }

  Widget _buildCompletedBookingsTab() {
    final bookingsAsync = ref.watch(vendorBookingsProvider);
    
    return bookingsAsync.when(
      data: (bookings) {
        final active = bookings.where((b) => b.escrowStatus.contains('Milestone')).toList();
        if (active.isEmpty) {
          return const Center(child: Text('No active escrows.', style: TextStyle(color: Colors.white)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: active.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            final b = active[i];
            return _buildBookingRow(
              id: b.id,
              title: 'Locked Event Escrow',
              client: b.clientName,
              date: b.eventDate,
              price: '₹${b.totalAmount}',
              step: b.escrowStatus,
              status: 'Active 🔒',
              statusColor: GomandapTokens.emeraldGreen,
              isDisputed: false,
              showDisputeButton: true,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: GomandapTokens.champagneGoldStart)),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: GomandapTokens.error))),
    );
  }

  Widget _buildDisputesBookingsTab() {
    final bookingsAsync = ref.watch(vendorBookingsProvider);
    
    return bookingsAsync.when(
      data: (bookings) {
        final disputes = bookings.where((b) => b.escrowStatus == 'Disputed' || b.escrowStatus == 'Cancelled').toList();
        if (disputes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel_rounded, size: 48, color: Colors.white.withValues(alpha: 0.15)),
                const SizedBox(height: 12),
                const Text(
                  'Zero Active Disputes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: disputes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            final b = disputes[i];
            return _buildBookingRow(
              id: b.id,
              title: 'Event Issue',
              client: b.clientName,
              date: b.eventDate,
              price: '₹${b.totalAmount}',
              step: b.escrowStatus,
              status: b.escrowStatus == 'Disputed' ? 'Admin Intervening 🚨' : 'Cancelled ❌',
              statusColor: GomandapTokens.error,
              isDisputed: true,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: GomandapTokens.champagneGoldStart)),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: GomandapTokens.error))),
    );
  }

  Widget _buildBookingRow({
    required String id,
    required String title,
    required String client,
    required String date,
    required String price,
    required String step,
    required String status,
    required Color statusColor,
    required bool isDisputed,
    bool showDisputeButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                price,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: GomandapTokens.champagneGoldStart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Client: $client · Date: $date',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step,
                    style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              if (showDisputeButton)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    ref.read(vendorActionProvider.notifier).updateBookingStatus(id, 'Disputed');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dispute filed. Admin notified.'), backgroundColor: GomandapTokens.error),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: GomandapTokens.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GomandapTokens.error.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.gavel_rounded, size: 10, color: GomandapTokens.error),
                        SizedBox(width: 4),
                        Text(
                          'File Dispute',
                          style: TextStyle(color: GomandapTokens.error, fontSize: 9.5, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Details',
                        style: TextStyle(color: Colors.white60, fontSize: 9.5, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, size: 8, color: Colors.white60),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
