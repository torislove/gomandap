import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:gomandap_common/data/repository_impl/vendor_application_repository.dart';
import 'package:gomandap_common/domain/models/vendor_application.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:rxdart/rxdart.dart';

// ─── Live Stats Provider ──────────────────────────────────────────────────────

class AdminStats {
  final int totalVendors;
  final int pendingReviews;
  final int approvedVendors;
  final int rejectedVendors;
  final int activeBookings;
  final double totalRevenue;

  const AdminStats({
    this.totalVendors = 0,
    this.pendingReviews = 0,
    this.approvedVendors = 0,
    this.rejectedVendors = 0,
    this.activeBookings = 0,
    this.totalRevenue = 0,
  });
}

final adminStatsProvider = StreamProvider.autoDispose<AdminStats>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return Stream.value(const AdminStats());

  final vendorStream = client.from('vendor_applications').stream(primaryKey: ['id']);
  final bookingStream = client.from('bookings').stream(primaryKey: ['id']);

  return Rx.combineLatest2(vendorStream, bookingStream, (vendors, bookings) {
    final total = vendors.length;
    final pending = vendors.where((r) => r['status'] == 'pending').length;
    final approved = vendors.where((r) => r['status'] == 'approved').length;
    final rejected = vendors.where((r) => r['status'] == 'rejected').length;

    final activeB = bookings.where((b) => b['status'] == 'confirmed').length;
    final double revenue = bookings.fold(0.0, (sum, b) => sum + (double.tryParse(b['total_amount']?.toString() ?? '0') ?? 0));

    return AdminStats(
      totalVendors: total,
      pendingReviews: pending,
      approvedVendors: approved,
      rejectedVendors: rejected,
      activeBookings: activeB,
      totalRevenue: revenue,
    );
  });
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final stats = statsAsync.value ?? const AdminStats();
    final applicationsAsync = ref.watch(allVendorApplicationsProvider);
    final isConnected = ref.watch(supabaseClientProvider) != null;

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ───────────────────────────────────────────────
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GoMandap Admin',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: GomandapTokens.royalNavy,
                          ),
                        ),
                        const Text(
                          'Control Center',
                          style: TextStyle(
                            fontSize: 13,
                            color: GomandapTokens.slateGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Connection status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? GomandapTokens.emeraldGreen.withValues(alpha: 0.1)
                            : GomandapTokens.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isConnected
                              ? GomandapTokens.emeraldGreen.withValues(alpha: 0.3)
                              : GomandapTokens.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: isConnected ? GomandapTokens.emeraldGreen : GomandapTokens.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected ? 'Live' : 'Offline',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isConnected ? GomandapTokens.emeraldGreen : GomandapTokens.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ─── Stats Grid (2×2) ──────────────────────────────────────
                const Text(
                  'Platform Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: GomandapTokens.royalNavy,
                  ),
                ),
                const SizedBox(height: 14),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard(
                      value: '${stats.totalVendors}',
                      label: 'Total Applications',
                      icon: Icons.store_rounded,
                      color: GomandapTokens.royalNavy,
                      isLoading: statsAsync.isLoading,
                    ),
                    _StatCard(
                      value: '${stats.pendingReviews}',
                      label: 'Pending Review',
                      icon: Icons.hourglass_top_rounded,
                      color: GomandapTokens.warning,
                      isLoading: statsAsync.isLoading,
                    ),
                    _StatCard(
                      value: '${stats.approvedVendors}',
                      label: 'Approved Vendors',
                      icon: Icons.verified_rounded,
                      color: GomandapTokens.emeraldGreen,
                      isLoading: statsAsync.isLoading,
                    ),
                    _StatCard(
                      value: '${stats.rejectedVendors}',
                      label: 'Rejected',
                      icon: Icons.cancel_rounded,
                      color: GomandapTokens.error,
                      isLoading: statsAsync.isLoading,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ─── Recent Activity ───────────────────────────────────────
                Row(
                  children: [
                    const Text(
                      'Recent Applications',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: GomandapTokens.royalNavy,
                      ),
                    ),
                    const Spacer(),
                    if (statsAsync.isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                applicationsAsync.when(
                  loading: () => const _ActivitySkeleton(),
                  error: (e, _) => _ErrorCard(message: '$e'),
                  data: (apps) {
                    if (apps.isEmpty) {
                      return const _EmptyActivity();
                    }
                    final recent = apps.take(5).toList();
                    return Column(
                      children: recent
                          .map((app) => _ActivityRow(app: app))
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          isLoading
              ? Container(
                  width: 40,
                  height: 24,
                  decoration: BoxDecoration(
                    color: GomandapTokens.softMist,
                    borderRadius: BorderRadius.circular(6),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: GomandapTokens.slateGray,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final VendorApplication app;
  const _ActivityRow({required this.app});

  Color get _statusColor {
    switch (app.status) {
      case VendorAppStatus.approved: return GomandapTokens.emeraldGreen;
      case VendorAppStatus.rejected: return GomandapTokens.error;
      case VendorAppStatus.needsCorrection: return GomandapTokens.warning;
      default: return GomandapTokens.champagneGoldEnd;
    }
  }

  String get _statusLabel {
    switch (app.status) {
      case VendorAppStatus.approved: return 'Approved';
      case VendorAppStatus.rejected: return 'Rejected';
      case VendorAppStatus.needsCorrection: return 'Correction';
      default: return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GomandapTokens.lightSlate),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: GomandapTokens.royalNavy.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                app.businessName.isNotEmpty ? app.businessName[0].toUpperCase() : 'V',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: GomandapTokens.royalNavy,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.businessName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: GomandapTokens.royalNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${app.ownerName} · ${app.city}',
                  style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              _statusLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivitySkeleton extends StatelessWidget {
  const _ActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 64,
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 40, color: GomandapTokens.emeraldGreen),
            SizedBox(height: 12),
            Text(
              'All caught up! 🎉',
              style: TextStyle(fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
            ),
            Text(
              'No pending applications right now.',
              style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GomandapTokens.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GomandapTokens.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: GomandapTokens.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Could not load data. Check your connection.',
              style: const TextStyle(fontSize: 12, color: GomandapTokens.error),
            ),
          ),
        ],
      ),
    );
  }
}
