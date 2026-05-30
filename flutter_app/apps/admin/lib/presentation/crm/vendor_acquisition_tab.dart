import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

import 'package:gomandap_common/presentation/widgets/skeleton_loader.dart';
import '../approvals/admin_vendor_approval_screen.dart';
import 'admin_add_vendor_screen.dart';

class VendorAcquisitionTab extends ConsumerStatefulWidget {
  const VendorAcquisitionTab({super.key});

  @override
  ConsumerState<VendorAcquisitionTab> createState() => _VendorAcquisitionTabState();
}

class _VendorAcquisitionTabState extends ConsumerState<VendorAcquisitionTab> {
  int _internalTab = 0; // 0: Leads, 1: KYC Review, 2: Quality Scoring
  bool _isLoadingKanban = true; // Simulating network load for Skeletons

  @override
  void initState() {
    super.initState();
    // Simulate loading to show off Skeleton Loaders
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoadingKanban = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vendor CRM & Acquisition 💼', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        const Text('Manage the entire vendor lifecycle from outbound leads to KYC review and quality scoring.', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
        const SizedBox(height: 24),
        
        // Internal Tabs
        Row(
          children: [
            _buildTab(0, 'Leads Pipeline'),
            const SizedBox(width: 12),
            _buildTab(1, 'KYC & Approvals'),
            const SizedBox(width: 12),
            _buildTab(2, 'Quality Scoring'),
          ],
        ),
        const SizedBox(height: 24),
        
        // Tab Content
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildTab(int idx, String title) {
    final isSel = _internalTab == idx;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _internalTab = idx);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? GomandapTokens.royalNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSel ? Colors.transparent : GomandapTokens.lightSlate),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSel ? Colors.white : GomandapTokens.slateGray,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_internalTab) {
      case 0:
        return _buildLeadsPipeline();
      case 1:
        // Reuse existing approval screen
        return const AdminVendorApprovalScreen();
      case 2:
        return _buildQualityScoring();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLeadsPipeline() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Outbound Leads Kanban', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
              ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminAddVendorScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GomandapTokens.emeraldGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Lead', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isPortrait = constraints.maxWidth < 600;
                
                if (isPortrait) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildKanbanColumn('New Leads', ['Grand Palace Halls', 'Elite Decorators']),
                        const SizedBox(height: 16),
                        _buildKanbanColumn('Contacted', ['A1 Photography']),
                        const SizedBox(height: 16),
                        _buildKanbanColumn('Awaiting KYC', ['Bridal Glow Studio']),
                      ],
                    ),
                  );
                }
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildKanbanColumn('New Leads', ['Grand Palace Halls', 'Elite Decorators'])),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKanbanColumn('Contacted', ['A1 Photography'])),
                    const SizedBox(width: 16),
                    Expanded(child: _buildKanbanColumn('Awaiting KYC', ['Bridal Glow Studio'])),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String title, List<String> cards) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GomandapTokens.softMist,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: GomandapTokens.slateGray)),
          const SizedBox(height: 12),
          if (_isLoadingKanban)
            ...List.generate(3, (i) => const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: SkeletonLoader(height: 50, width: double.infinity, borderRadius: 8),
            ))
          else
            ...cards.map((c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(c, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: GomandapTokens.royalNavy)),
            )),
        ],
      ),
    );
  }

  Widget _buildQualityScoring() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile Quality Checklist (Live Vendors)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(height: 16),
          const Text('Ensure vendors maintain high-quality portfolios and accurate pricing to boost conversions.', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
          const SizedBox(height: 24),
          _buildScoringRow('Royal Mandapam', 92, true),
          const Divider(height: 32),
          _buildScoringRow('A1 Photography', 65, false, issues: 'Missing video portfolio, vague packages'),
        ],
      ),
    );
  }

  Widget _buildScoringRow(String name, int score, bool isPass, {String? issues}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: GomandapTokens.royalNavy)),
              if (issues != null) ...[
                const SizedBox(height: 4),
                Text('Needs Improvement: $issues', style: const TextStyle(fontSize: 12, color: GomandapTokens.error)),
              ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPass ? GomandapTokens.emeraldGreen.withValues(alpha: 0.1) : GomandapTokens.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Score: $score/100',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isPass ? GomandapTokens.emeraldGreen : GomandapTokens.warning,
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: GomandapTokens.softMist,
            foregroundColor: GomandapTokens.royalNavy,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Review', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
