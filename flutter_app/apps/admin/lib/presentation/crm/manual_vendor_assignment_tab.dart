import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class ManualVendorAssignmentTab extends ConsumerStatefulWidget {
  const ManualVendorAssignmentTab({super.key});

  @override
  ConsumerState<ManualVendorAssignmentTab> createState() => _ManualVendorAssignmentTabState();
}

class _ManualVendorAssignmentTabState extends ConsumerState<ManualVendorAssignmentTab> {
  // Mock data for unassigned inquiries
  final List<Map<String, dynamic>> _inquiries = [
    {
      'id': 'INQ-1001',
      'client': 'Rahul Sharma',
      'type': 'Venue',
      'date': 'Oct 24, 2026',
      'budget': '₹5 Lakhs',
      'status': 'Pending Assignment',
    },
    {
      'id': 'INQ-1002',
      'client': 'Priya & Ankit',
      'type': 'Decorator',
      'date': 'Nov 12, 2026',
      'budget': '₹1.5 Lakhs',
      'status': 'Pending Assignment',
    },
  ];

  void _assignVendor(String inquiryId) {
    // In a real app, this would open a vendor picker modal/bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Vendor to Assign', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: GomandapTokens.softMist, child: Icon(Icons.storefront, color: GomandapTokens.royalNavy)),
                title: const Text('Royal Palace Banquets', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Rating: 4.8 | Match Score: 95%'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vendor manually assigned successfully!'), backgroundColor: GomandapTokens.emeraldGreen),
                    );
                    setState(() {
                      _inquiries.removeWhere((i) => i['id'] == inquiryId);
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: GomandapTokens.champagneGoldStart, foregroundColor: Colors.white),
                  child: const Text('Assign'),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(backgroundColor: GomandapTokens.softMist, child: Icon(Icons.storefront, color: GomandapTokens.royalNavy)),
                title: const Text('Elite Decorators Inc.', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Rating: 4.5 | Match Score: 88%'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vendor manually assigned successfully!'), backgroundColor: GomandapTokens.emeraldGreen),
                    );
                    setState(() {
                      _inquiries.removeWhere((i) => i['id'] == inquiryId);
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: GomandapTokens.champagneGoldStart, foregroundColor: Colors.white),
                  child: const Text('Assign'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Manual Vendor Assignment 📋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        const Text('Review client custom inquiries and manually assign the best vetted vendors.', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
        const SizedBox(height: 28),
        
        if (_inquiries.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: GomandapTokens.softMist,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GomandapTokens.lightSlate, style: BorderStyle.solid),
            ),
            child: const Text('No pending inquiries for manual assignment.', style: TextStyle(color: GomandapTokens.slateGray, fontWeight: FontWeight.w600)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _inquiries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final inq = _inquiries[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: GomandapTokens.lightSlate),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: GomandapTokens.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(inq['id'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: GomandapTokens.warning)),
                        ),
                        Text(inq['date'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(inq['client'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.category_rounded, size: 14, color: GomandapTokens.slateGray),
                        const SizedBox(width: 4),
                        Text(inq['type'], style: const TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
                        const SizedBox(width: 16),
                        const Icon(Icons.account_balance_wallet_rounded, size: 14, color: GomandapTokens.slateGray),
                        const SizedBox(width: 4),
                        Text(inq['budget'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: GomandapTokens.emeraldGreen)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _assignVendor(inq['id']),
                        icon: const Icon(Icons.assignment_ind_rounded, size: 18),
                        label: const Text('Assign Vendor Manually', style: TextStyle(fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GomandapTokens.royalNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
