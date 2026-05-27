import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class VendorBookingsScreen extends StatefulWidget {
  const VendorBookingsScreen({super.key});

  @override
  State<VendorBookingsScreen> createState() => _VendorBookingsScreenState();
}

class _VendorBookingsScreenState extends State<VendorBookingsScreen>
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
      backgroundColor: GomandapTokens.royalNavy,
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
            Tab(text: 'Upcoming (2)'),
            Tab(text: 'Completed (8)'),
            Tab(text: 'Disputes (0)'),
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
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildBookingRow(
          title: 'Muhurtham Grand Wedding Wedding',
          client: 'Manoj Kumar & Kavya',
          date: '12th Oct 2026',
          price: '₹3,50,000',
          step: 'Milestone 2/3 · 50% Pre-Event Hold',
          status: 'Escrow Vault Locked 🔒',
          statusColor: GomandapTokens.champagneGoldStart,
        ),
        const SizedBox(height: 16),
        _buildBookingRow(
          title: 'Sangeet Reception Concert',
          client: 'Nikhil & Priya',
          date: '18th Oct 2026',
          price: '₹1,20,000',
          step: 'Milestone 1/3 · 25% Booking Lock',
          status: 'Funds Secure Vault 🔒',
          statusColor: GomandapTokens.emeraldGreen,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildCompletedBookingsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildBookingRow(
          title: 'Royal Engagement Gala',
          client: 'Suresh & Meghna',
          date: '15th May 2026',
          price: '₹2,50,000',
          step: '100% Milestone Handover Released',
          status: 'Cleared & Transferred ✅',
          statusColor: GomandapTokens.emeraldGreen,
        ),
        const SizedBox(height: 16),
        _buildBookingRow(
          title: 'Corporate Event AV Backdrop',
          client: 'Techlabs Inc',
          date: '02nd May 2026',
          price: '₹1,80,000',
          step: '100% Milestone Handover Released',
          status: 'Cleared & Transferred ✅',
          statusColor: GomandapTokens.emeraldGreen,
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildDisputesBookingsTab() {
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
          const SizedBox(height: 4),
          const Text(
            'Keep escrow standards high to prevent project disputes.',
            style: TextStyle(fontSize: 10, color: Colors.white30),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingRow({
    required String title,
    required String client,
    required String date,
    required String price,
    required String step,
    required String status,
    required Color statusColor,
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
