import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:gomandap_common/domain/models/category_model.dart';
import 'package:gomandap_common/data/repository_impl/vendor_application_repository.dart';
import '../approvals/admin_vendor_approval_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _activeTab = 0; // 0: Overview, 1: Carousels, 2: Directories, 3: Sponsorships, 4: Vendor Onboarding

  // Banner states
  final _banners = [
    {
      'title': 'Grand Ballroom Reopenings',
      'subtitle': 'Flat 20% off on premium venues',
      'target_route': '/search?category=venue',
      'image_url': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
    },
    {
      'title': 'Sangeet Choreography Special',
      'subtitle': 'Book elite performance packages',
      'target_route': '/search?category=choreographer',
      'image_url': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
    },
  ];

  // Categories status (Active indices list supporting all 20 items)
  final List<int> _activeCategories = [1, 21, 22, 2, 3, 4, 5, 6, 7, 8, 10, 12, 17, 13, 9, 14, 15, 11, 16, 18];

  // Sangeet Ad Card variables
  final _titleController = TextEditingController(text: 'GoMandap Elite Events');
  final _descController = TextEditingController(
      text: 'Crafting grand memories, managing full sangeet packages, sound setups & catering.');
  final _actionLabelController = TextEditingController(text: 'Book Consult');
  double _animationSpeed = 1.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _actionLabelController.dispose();
    super.dispose();
  }

  void _saveToSupabase(String tableName, Map<String, dynamic> data) async {
    HapticFeedback.heavyImpact();
    final client = ref.read(supabaseClientProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (client == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: GomandapTokens.champagneGoldStart, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Local Simulation Cache Updated! Setup active Supabase URL to write to table "$tableName".',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: GomandapTokens.royalNavy,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await client.from(tableName).upsert(data);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Successfully synced configuration with live Supabase database! 🚀'),
          backgroundColor: GomandapTokens.emeraldGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Supabase sync error: $e'),
          backgroundColor: GomandapTokens.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sidebarWidth = MediaQuery.sizeOf(context).width > 700 ? 240 : 80;

    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar Control
          _buildSidebar(sidebarWidth),

          // Main Screen Dashboard Contents
          Expanded(
            child: Column(
              children: [
                // Top Header Panel
                _buildTopAppBar(),

                // Active Workspace Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: _buildActiveTabBody(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(double width) {
    final showLabels = width > 100;
    return Container(
      width: width,
      color: GomandapTokens.royalNavy,
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo Sparkle Motif
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration_rounded, color: GomandapTokens.champagneGoldStart, size: 24),
              if (showLabels) const SizedBox(width: 8),
              if (showLabels)
                const Text(
                  'GoMandap',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                ),
            ],
          ),
          if (showLabels) const SizedBox(height: 4),
          if (showLabels)
            const Text(
              'CONTROL PANEL',
              style: TextStyle(fontSize: 9, color: GomandapTokens.slateGray, fontWeight: FontWeight.w800, letterSpacing: 1.0),
            ),
          const SizedBox(height: 40),

          // Tab Options
          _buildSidebarTab(0, Icons.dashboard_rounded, 'Dashboard Hub', showLabels),
          _buildSidebarTab(1, Icons.view_carousel_rounded, 'Banner Sliders', showLabels),
          _buildSidebarTab(2, Icons.grid_view_rounded, 'Active Directory', showLabels),
          _buildSidebarTab(3, Icons.workspace_premium_rounded, 'Sangeet Campaigns', showLabels),
          _buildVendorOnboardingTab(showLabels),

          const Spacer(),
          // App credentials node details
          if (showLabels)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Supabase API Status', style: TextStyle(color: GomandapTokens.slateGray, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: ref.watch(supabaseClientProvider) != null
                              ? GomandapTokens.emeraldGreen
                              : GomandapTokens.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ref.watch(supabaseClientProvider) != null ? 'Connected Live' : 'Offline Cache Mode',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
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

  Widget _buildSidebarTab(int idx, IconData icon, String label, bool showLabel) {
    final isSel = _activeTab == idx;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeTab = idx);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSel ? GomandapTokens.champagneGoldStart.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSel ? Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.4)) : null,
        ),
        child: Row(
          mainAxisAlignment: showLabel ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSel ? GomandapTokens.champagneGoldStart : Colors.white60, size: 20),
            if (showLabel) const SizedBox(width: 12),
            if (showLabel)
              Text(
                label,
                style: TextStyle(
                  color: isSel ? Colors.white : Colors.white60,
                  fontSize: 13,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Vendor Onboarding sidebar tab with live pending count badge.
  Widget _buildVendorOnboardingTab(bool showLabel) {
    const idx = 4;
    final isSel = _activeTab == idx;
    final pendingAsync = ref.watch(vendorPendingCountProvider);
    final pendingCount = pendingAsync.valueOrNull ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeTab = idx);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSel
              ? GomandapTokens.champagneGoldStart.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSel
              ? Border.all(
                  color:
                      GomandapTokens.champagneGoldStart.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          mainAxisAlignment:
              showLabel ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.verified_user_rounded,
                    color: isSel
                        ? GomandapTokens.champagneGoldStart
                        : Colors.white60,
                    size: 20),
                if (pendingCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: GomandapTokens.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            if (showLabel) const SizedBox(width: 12),
            if (showLabel)
              Text(
                'Vendor Onboarding',
                style: TextStyle(
                  color: isSel ? Colors.white : Colors.white60,
                  fontSize: 13,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {

    return Container(
      height: 72,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Layout Configuration & Shelf Control Engine',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: GomandapTokens.softMist,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: GomandapTokens.royalNavy, size: 14),
                    SizedBox(width: 6),
                    Text('Node Verified ✅', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabBody() {
    switch (_activeTab) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildCarouselsTab();
      case 2:
        return _buildDirectoriesTab();
      case 3:
        return _buildSponsorshipsTab();
      case 4:
        return const AdminVendorApprovalScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Tab 1: Platform Overview ──────────────────────────────────────────────

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Analytics Console 🏛', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        const Text('Monitor active client registrations, total escrow bookings value, and platform commissions.', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
        const SizedBox(height: 28),

        Row(
          children: [
            _buildStatCard('₹28.4L', 'Total Locked Escrow', Icons.lock_clock_rounded, GomandapTokens.emeraldGreen),
            const SizedBox(width: 16),
            _buildStatCard('147', 'Verified Elite Partners', Icons.handshake_rounded, GomandapTokens.champagneGoldStart),
            const SizedBox(width: 16),
            _buildStatCard('12,410', 'Monthly Active Clients', Icons.trending_up_rounded, const Color(0xFF3B82F6)),
          ],
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Platform Activity Log', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
              SizedBox(height: 16),
              _ActivityRow(action: 'Client "Rahul Sharma" customized escrow venue package', time: '2 mins ago'),
              Divider(height: 20),
              _ActivityRow(action: 'Decorator Partner "Royal Floral Artistry" submitted verification paperwork', time: '14 mins ago'),
              Divider(height: 20),
              _ActivityRow(action: 'Sponsorship campaign SVG animation velocity scaled to 1.5x by admin', time: '40 mins ago'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GomandapTokens.lightSlate),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab 2: Carousel Sliders Manager ────────────────────────────────────────

  Widget _buildCarouselsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hero Banner Sliders Editor 📸', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                SizedBox(height: 6),
                Text('Configure horizontal sliders dynamically inside the client dashboard Home shelfs.', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _banners.add({
                    'title': 'New Luxury Deal',
                    'subtitle': 'Click to book customized planners',
                    'target_route': '/search',
                    'image_url': 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
                  });
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GomandapTokens.royalNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Slider', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 28),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _banners.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, idx) {
            final banner = _banners[idx];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GomandapTokens.lightSlate),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      banner['image_url'] ?? '',
                      width: 120, height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(banner['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(banner['subtitle'] ?? '', style: const TextStyle(color: GomandapTokens.slateGray, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text('Target Route: ${banner['target_route']}', style: const TextStyle(color: GomandapTokens.champagneGoldEnd, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _banners.removeAt(idx);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 32),
        Center(
          child: ElevatedButton(
            onPressed: () => _saveToSupabase('home_carousels', {'banners': _banners}),
            style: ElevatedButton.styleFrom(
              backgroundColor: GomandapTokens.royalNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Active Sliders Layout ✅', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ),
        ),
      ],
    );
  }

  // ─── Tab 3: Directory Shelves Controller ────────────────────────────────────

  Widget _buildDirectoriesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Active Category Shelves Panel 🏛', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        const Text('Toggle visibility of directory items inside the client search grid. Drag-to-order features active.', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
        const SizedBox(height: 28),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
          ),
          itemCount: weddingCategoriesList.length,
          itemBuilder: (context, idx) {
            final cat = weddingCategoriesList[idx];
            final int catId = cat.id;
            final isAct = _activeCategories.contains(catId);

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (isAct) {
                    _activeCategories.remove(catId);
                  } else {
                    _activeCategories.add(catId);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isAct ? GomandapTokens.royalNavy : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAct ? Colors.transparent : GomandapTokens.lightSlate,
                  ),
                  boxShadow: isAct
                      ? [
                          BoxShadow(
                            color: GomandapTokens.royalNavy.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.fallbackIcon, color: isAct ? GomandapTokens.champagneGoldStart : GomandapTokens.royalNavy, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        cat.name,
                        style: TextStyle(
                          color: isAct ? Colors.white : GomandapTokens.royalNavy,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 48),
        Center(
          child: ElevatedButton(
            onPressed: () => _saveToSupabase('app_configurations', {
              'id': 'global_config',
              'active_categories': _activeCategories,
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: GomandapTokens.royalNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Active Directories Config ✅', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ),
        ),
      ],
    );
  }

  // ─── Tab 4: Sponsorship Campaigns Editor ────────────────────────────────────

  Widget _buildSponsorshipsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sponsorship SVG Campaigns Editor 👑', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        const Text('Tune vectors, titles, and dancer animation speeds on the client panel sponsorship cards in real-time.', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditorTextField(label: 'Campaign Premium Title *', controller: _titleController, hint: 'e.g., GoMandap Elite Events'),
              const SizedBox(height: 20),
              _buildEditorTextField(
                label: 'Campaign Body Details *',
                controller: _descController,
                hint: 'Description of sangeet planning packages, sound and decibel details...',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildEditorTextField(label: 'Primary Call-to-Action Label *', controller: _actionLabelController, hint: 'e.g., Book Consult'),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vector SVG Dancer Animation Speed Multiplier',
                    style: TextStyle(fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy, fontSize: 13),
                  ),
                  Text(
                    '${_animationSpeed.toStringAsFixed(1)}x Speed',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: GomandapTokens.champagneGoldEnd, fontSize: 13),
                  ),
                ],
              ),
              Slider(
                min: 0.5, max: 3.0,
                value: _animationSpeed,
                activeColor: GomandapTokens.champagneGoldStart,
                inactiveColor: GomandapTokens.softMist,
                onChanged: (val) {
                  setState(() => _animationSpeed = val);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),
        Center(
          child: ElevatedButton(
            onPressed: () => _saveToSupabase('sponsorship_campaigns', {
              'id': 'sangeet_elite_campaign',
              'title': _titleController.text,
              'description': _descController.text,
              'action_label': _actionLabelController.text,
              'svg_animation_speed': _animationSpeed,
              'is_active': true,
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: GomandapTokens.royalNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Publish Sponsorship Campaign 🚀', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildEditorTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: GomandapTokens.slateGray.withValues(alpha: 0.7), fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String action, time;
  const _ActivityRow({required this.action, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(action, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy)),
        ),
        Text(time, style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
