import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_button.dart';
import 'package:gomandap_common/presentation/widgets/interactive_card.dart';

class PlanningBoardScreen extends ConsumerWidget {
  const PlanningBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GomandapScreen(
      backgroundColor: GomandapTokens.pearlWhite,
      useHorizontalPadding: false,
      useSafeAreaBottom: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: GomandapTokens.royalNavy, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Collaborative Board',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: GomandapTokens.emeraldGreen),
            onPressed: () {
              _showInviteSheet(context);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Co-Planners Avatars
            Row(
              children: [
                const Text('Planners:', style: TextStyle(fontWeight: FontWeight.w700, color: GomandapTokens.slateGray, fontSize: 13)),
                const SizedBox(width: 12),
                _buildAvatar('You', GomandapTokens.royalNavy),
                _buildAvatar('Priya (Fiancée)', GomandapTokens.champagneGoldEnd),
                _buildAvatar('Mom', GomandapTokens.emeraldGreen),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showInviteSheet(context),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: GomandapTokens.softMist,
                    child: Icon(Icons.add_rounded, size: 18, color: GomandapTokens.royalNavy),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Budget Tracker
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: GomandapTokens.cardShadow,
                border: Border.all(color: GomandapTokens.lightSlate),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shared Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                      Text('₹12.5L / ₹20L', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GomandapTokens.emeraldGreen)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 0.625, // 12.5 / 20
                      minHeight: 12,
                      backgroundColor: GomandapTokens.softMist,
                      valueColor: AlwaysStoppedAnimation<Color>(GomandapTokens.emeraldGreen),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('62% allocated across 4 vendors', style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Kanban Columns
            const Text('Shortlisted Vendors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
            const SizedBox(height: 16),
            
            _buildKanbanColumn('Saved', [
              _VendorCardData('Royal Palace Halls', 'Venues • ₹5L', 'Priya'),
              _VendorCardData('A1 Photography', 'Photographers • ₹1.2L', 'You'),
            ]),
            const SizedBox(height: 24),
            
            _buildKanbanColumn('Contacted (Awaiting Quote)', [
              _VendorCardData('Elite Decorators', 'Decor • ₹3L', 'Mom'),
            ]),
            const SizedBox(height: 24),
            
            _buildKanbanColumn('Booked & Locked', [
              _VendorCardData('Spice Catering Co.', 'Catering • ₹4L', 'Priya'),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: -8.0),
      child: Tooltip(
        message: name,
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 14,
            backgroundColor: color,
            child: Text(name[0], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }

  Widget _buildKanbanColumn(String title, List<_VendorCardData> cards) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GomandapTokens.softMist.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: GomandapTokens.slateGray)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Text('${cards.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...cards.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InteractiveCard(
              scaleFactor: 0.98,
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: GomandapTokens.cardShadow,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: GomandapTokens.softMist,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: GomandapTokens.slateGray),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: GomandapTokens.royalNavy)),
                          const SizedBox(height: 4),
                          Text(c.details, style: const TextStyle(fontSize: 12, color: GomandapTokens.emeraldGreen, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Text('Added by', style: TextStyle(fontSize: 9, color: GomandapTokens.slateGray)),
                        const SizedBox(height: 4),
                        _buildAvatar(c.addedBy, c.addedBy == 'You' ? GomandapTokens.royalNavy : c.addedBy == 'Mom' ? GomandapTokens.emeraldGreen : GomandapTokens.champagneGoldEnd),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invite Co-Planner', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
            const SizedBox(height: 8),
            const Text('Share this code with your spouse, family, or event planner to build your wishlist together.', style: TextStyle(color: GomandapTokens.slateGray, fontSize: 14)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: const Text('GMDP-482-X9L', style: TextStyle(fontSize: 28, letterSpacing: 2, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
            ),
            const SizedBox(height: 32),
            GomandapButton(
              label: 'Share Invite Link',
              icon: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite link copied to clipboard!')));
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _VendorCardData {
  final String name;
  final String details;
  final String addedBy;

  _VendorCardData(this.name, this.details, this.addedBy);
}
