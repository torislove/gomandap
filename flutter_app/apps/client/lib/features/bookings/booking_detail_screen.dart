import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: GomandapTokens.royalNavy, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
            ),
            Text(
              'ID: #$bookingId',
              style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Immersive Card
            _buildVendorOverview(),
            const SizedBox(height: 20),

            // Event Specs details
            _buildEventSpecsCard(),
            const SizedBox(height: 20),

            // Financial Summary
            _buildFinancialBreakdown(),
            const SizedBox(height: 20),

            // Trust escrows visualizer CTA
            _buildEscrowTrackerCTA(context),
            const SizedBox(height: 32),

            // Support/Actions footer
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.phone_rounded,
                    label: 'Call Vendor',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dialing Vendor support...'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Vendor Chat',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connecting to vendor secure line...'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildOutlineButton(
              label: 'Raise Dispute / Report Issue',
              isDestructive: true,
              onTap: () {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening GoMandap Dispute center...'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorOverview() {
    return Container(
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
            child: Image.network(
              'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400',
              width: 72, height: 72, fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'The Heritage Gala Resort',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.verified_rounded, size: 14, color: GomandapTokens.emeraldGreen),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Banquet Hall · Jubilee Hills, Hyd',
                  style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: GomandapTokens.champagneGoldEnd),
                    SizedBox(width: 4),
                    Text(
                      '4.9 (182 Reviews)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSpecsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Specifications',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
          ),
          SizedBox(height: 12),
          _SpecRow(label: 'Booking Date', val: '14 Aug 2026'),
          SizedBox(height: 8),
          _SpecRow(label: 'Guest Count', val: '300 Pax'),
          SizedBox(height: 8),
          _SpecRow(label: 'Event Type', val: 'Wedding / Grand Marriage reception'),
          SizedBox(height: 8),
          _SpecRow(label: 'Plating details', val: 'Standard Luxury Royal menu (Veg + Non-Veg)'),
        ],
      ),
    );
  }

  Widget _buildFinancialBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Settlement',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
          ),
          SizedBox(height: 12),
          _SpecRow(label: 'Estimate Subtotal', val: '₹5,50,000'),
          SizedBox(height: 8),
          _SpecRow(label: 'GoMandap partner Escrow fee', val: '₹11,000'),
          Divider(color: GomandapTokens.lightSlate, height: 20),
          _SpecRow(label: 'Total Secure Capital', val: '₹5,61,000', isBold: true),
        ],
      ),
    );
  }

  Widget _buildEscrowTrackerCTA(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/escrow/$bookingId');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GomandapTokens.emeraldGreen.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.shield_rounded, color: GomandapTokens.emeraldGreen, size: 24),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Escrow Milestones 🛡',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.emeraldGreen),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'View vertical payment timelines and release locks directly on booking progress.',
                    style: TextStyle(fontSize: 11, color: GomandapTokens.slateGray),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: GomandapTokens.emeraldGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: GomandapTokens.softMist,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GomandapTokens.lightSlate),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: GomandapTokens.royalNavy),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : GomandapTokens.royalNavy;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String val;
  final bool isBold;

  const _SpecRow({required this.label, required this.val, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? GomandapTokens.royalNavy : GomandapTokens.slateGray,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: GomandapTokens.royalNavy,
          ),
        ),
      ],
    );
  }
}

