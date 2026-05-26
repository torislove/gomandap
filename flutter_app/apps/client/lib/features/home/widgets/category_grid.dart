import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/category_model.dart';

typedef CategoryItem = CategoryDetails;

class CategorySuperGrid extends ConsumerWidget {
  final void Function(CategoryItem category) onCategoryTap;

  const CategorySuperGrid({super.key, required this.onCategoryTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Separate Venues from Other Categories
    final venueCategories = weddingCategoriesList
        .where((cat) => cat.name == 'Banquet Halls' ||
                        cat.name == 'Kalyana Mandapams' ||
                        cat.name == 'Open Lawns')
        .toList();

    final otherCategories = weddingCategoriesList
        .where((cat) => cat.name != 'Banquet Halls' &&
                        cat.name != 'Kalyana Mandapams' &&
                        cat.name != 'Open Lawns')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Venues & Mandapams Section
        _buildSectionHeader('Venue Types', 'Banquet Halls, Mandapams & Gardens'),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: venueCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Premium 3-column design for venues
              childAspectRatio: 1.15,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final cat = venueCategories[index];
              return _CategoryGridItem(category: cat, onTap: () => onCategoryTap(cat));
            },
          ),
        ),

        // 2. GoMandap Trust Shelf (Explain core pillars in minimal space)
        const SizedBox(height: 8),
        const _GomandapTrustShelf(),
        const SizedBox(height: 4),

        // 3. Other Categories Section
        _buildSectionHeader('Other Services', 'Caterers, Planners, Decorators & More'),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: otherCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Highly compact 4-column design for other services
              childAspectRatio: 1.15,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final cat = otherCategories[index];
              return _CategoryGridItem(category: cat, onTap: () => onCategoryTap(cat));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFBA73), // Gold vertical bar indicator
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: GomandapTokens.royalNavy,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: GomandapTokens.slateGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GomandapTrustShelf extends StatelessWidget {
  const _GomandapTrustShelf();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: GomandapTokens.royalNavy.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pill 1: Milestone Escrow
            Expanded(
              child: _buildTrustPill(
                icon: Icons.shield_outlined,
                title: 'Milestone Escrow',
                desc: 'Pay in parts. Funds locked & released only on your approval.',
                accent: const Color(0xFFDFBA73), // Champagne Gold
              ),
            ),
            Container(
              width: 1,
              height: 28,
              color: GomandapTokens.royalNavy.withValues(alpha: 0.08),
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
            // Pill 2: Verified Partners
            Expanded(
              child: _buildTrustPill(
                icon: Icons.verified_user_outlined,
                title: 'Verified Partners',
                desc: 'Strictly vetted portfolios, active licenses & verified reviews.',
                accent: const Color(0xFF10B981), // Emerald Green
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustPill({
    required IconData icon,
    required String title,
    required String desc,
    required Color accent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 14),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: GomandapTokens.royalNavy,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 8,
                  color: GomandapTokens.slateGray,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryGridItem extends StatefulWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const _CategoryGridItem({required this.category, required this.onTap});

  @override
  State<_CategoryGridItem> createState() => _CategoryGridItemState();
}

class _CategoryGridItemState extends State<_CategoryGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: GomandapTokens.royalNavy.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
              // Gold-leaf outlines glow effect
              BoxShadow(
                color: const Color(0xFFDFBA73).withValues(alpha: 0.08),
                blurRadius: 15,
                spreadRadius: -1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Category Cover Photo
                Image.network(
                  widget.category.imageUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Vignette gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
                // 3D Glassmorphic Floating Title Plate
                Positioned(
                  bottom: 5,
                  left: 5,
                  right: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.category.name,
                          style: const TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ─── Intelligent Category Bottom Sheet ────────────────────────────────────────

void showCategorySheet(BuildContext context, CategoryItem category) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryBottomSheet(category: category),
  );
}

class _CategoryBottomSheet extends StatelessWidget {
  final CategoryItem category;
  const _CategoryBottomSheet({required this.category});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: GomandapTokens.pearlWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              height: 4, width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: category.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.fallbackIcon, color: category.accent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                        const Text('Top Vendors Near You',
                          style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: GomandapTokens.slateGray),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            // Quick filter chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ['All', 'Highest Rated', 'Budget', 'Escrow Only', 'Verified']
                    .map((label) => _FilterChipPill(label: label, isActive: label == 'All'))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Results placeholder
            Expanded(
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 5,
                itemBuilder: (_, i) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Text('Vendor Card', style: TextStyle(color: GomandapTokens.slateGray)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  final String label;
  final bool isActive;
  const _FilterChipPill({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? GomandapTokens.royalNavy : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? GomandapTokens.royalNavy : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : GomandapTokens.slateGray,
        ),
      ),
    );
  }
}

