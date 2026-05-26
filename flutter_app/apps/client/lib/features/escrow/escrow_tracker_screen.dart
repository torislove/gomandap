import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class EscrowTrackerScreen extends StatelessWidget {
  final String bookingId;
  const EscrowTrackerScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: GomandapTokens.royalNavy),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Escrow Tracker',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
            Text('Booking #$bookingId',
              style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: GomandapTokens.royalNavy),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Vendor Card
            _VendorSummaryCard(),
            const SizedBox(height: 24),

            // 2. Escrow Summary Cards Row
            const Row(
              children: [
                Expanded(child: _EscrowStatCard('Released', '₹1,10,000', GomandapTokens.emeraldGreen, Icons.check_circle_rounded)),
                SizedBox(width: 12),
                Expanded(child: _EscrowStatCard('Held', '₹2,75,000', GomandapTokens.warning, Icons.lock_clock_rounded)),
                SizedBox(width: 12),
                Expanded(child: _EscrowStatCard('Locked', '₹1,65,000', GomandapTokens.slateGray, Icons.lock_rounded)),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Escrow Timeline
            _EscrowTimeline(),
            const SizedBox(height: 24),

            // 4. GoMandap Promise
            _GoMandapPromiseBanner(),
            const SizedBox(height: 24),

            // 5. Action Buttons
            Row(
              children: [
                Expanded(
                  child: _OutlineActionButton(
                    icon: Icons.phone_rounded, label: 'Call Vendor',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OutlineActionButton(
                    icon: Icons.chat_bubble_outline_rounded, label: 'Chat',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OutlineActionButton(
                    icon: Icons.flag_outlined, label: 'Dispute',
                    onTap: () {}, isDestructive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _VendorSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              errorBuilder: (_, __, ___) => Container(
                width: 72, height: 72,
                color: GomandapTokens.softMist,
                child: const Icon(Icons.image, color: GomandapTokens.slateGray),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('The Heritage Gala Resort',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                    SizedBox(width: 4),
                    Icon(Icons.verified_rounded, size: 14, color: GomandapTokens.emeraldGreen),
                  ],
                ),
                SizedBox(height: 4),
                Text('Banquet Hall · Jubilee Hills',
                  style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: GomandapTokens.slateGray),
                    SizedBox(width: 4),
                    Text('14 Aug 2026', style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray)),
                    Text(' · ', style: TextStyle(color: GomandapTokens.slateGray)),
                    Icon(Icons.people_outline_rounded, size: 12, color: GomandapTokens.slateGray),
                    SizedBox(width: 4),
                    Text('300 guests', style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EscrowStatCard extends StatelessWidget {
  final String label, amount;
  final Color color;
  final IconData icon;

  const _EscrowStatCard(this.label, this.amount, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: GomandapTokens.slateGray, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EscrowTimeline extends StatelessWidget {
  final milestones = const [
    _Milestone('Booking Lock (20%)', '₹1,10,000', 'Released · 14 May 2026', MilestoneState.done),
    _Milestone('Pre-Event Payment (50%)', '₹2,75,000', 'Held · Due 1 Aug 2026', MilestoneState.current),
    _Milestone('Final Handover (30%)', '₹1,65,000', 'Locked · After Event', MilestoneState.locked),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
        boxShadow: GomandapTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Milestones',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(height: 20),
          ...List.generate(milestones.length, (i) {
            final m = milestones[i];
            final isLast = i == milestones.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline line + dot
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        _MilestoneDot(state: m.state),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: m.state == MilestoneState.done
                                  ? GomandapTokens.emeraldGreen
                                  : GomandapTokens.lightSlate,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Milestone content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.label,
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: m.state == MilestoneState.locked
                                  ? GomandapTokens.slateGray
                                  : GomandapTokens.royalNavy,
                            )),
                          const SizedBox(height: 2),
                          Text(m.amount,
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900,
                              color: _amountColor(m.state),
                            )),
                          const SizedBox(height: 4),
                          Text(m.statusText,
                            style: TextStyle(
                              fontSize: 11,
                              color: m.state == MilestoneState.done
                                  ? GomandapTokens.emeraldGreen
                                  : GomandapTokens.slateGray,
                              fontWeight: FontWeight.w600,
                            )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _amountColor(MilestoneState state) {
    switch (state) {
      case MilestoneState.done: return GomandapTokens.emeraldGreen;
      case MilestoneState.current: return GomandapTokens.warning;
      case MilestoneState.locked: return GomandapTokens.slateGray;
    }
  }
}

enum MilestoneState { done, current, locked }

class _Milestone {
  final String label, amount, statusText;
  final MilestoneState state;
  const _Milestone(this.label, this.amount, this.statusText, this.state);
}

class _MilestoneDot extends StatelessWidget {
  final MilestoneState state;
  const _MilestoneDot({required this.state});

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case MilestoneState.done:
        return Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(color: GomandapTokens.emeraldGreen, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
        );
      case MilestoneState.current:
        return Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: GomandapTokens.warning.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: GomandapTokens.warning, width: 2),
          ),
          child: Center(child: Container(width: 10, height: 10,
            decoration: const BoxDecoration(color: GomandapTokens.warning, shape: BoxShape.circle))),
        );
      case MilestoneState.locked:
        return Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            shape: BoxShape.circle,
            border: Border.all(color: GomandapTokens.lightSlate, width: 2),
          ),
          child: const Icon(Icons.lock_rounded, color: GomandapTokens.slateGray, size: 14),
        );
    }
  }
}

class _GoMandapPromiseBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GomandapTokens.emeraldGreen.withValues(alpha: 0.08), GomandapTokens.emeraldGreen.withValues(alpha: 0.03)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: GomandapTokens.emeraldGreen, shape: BoxShape.circle),
            child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GoMandap Escrow Promise',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                SizedBox(height: 4),
                Text('Your money is 100% secure. Funds are released to the vendor only after your event is successfully completed.',
                  style: TextStyle(fontSize: 11, color: GomandapTokens.slateGray, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OutlineActionButton({
    required this.icon, required this.label, required this.onTap, this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? GomandapTokens.error : GomandapTokens.royalNavy;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

