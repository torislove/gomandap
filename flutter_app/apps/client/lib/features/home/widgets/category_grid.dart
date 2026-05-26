import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:gomandap_common/domain/models/category_model.dart';

typedef CategoryItem = CategoryDetails;

class CategorySuperGrid extends ConsumerWidget {
  final void Function(CategoryItem category) onCategoryTap;

  const CategorySuperGrid({super.key, required this.onCategoryTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategoriesAsync = ref.watch(activeCategoriesStreamProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: activeCategoriesAsync.when(
        data: (activeIds) {
          // Dynamic Category Filtering controlled by Admin Panel toggles!
          final visibleCategories = weddingCategoriesList
              .where((cat) => activeIds.contains(cat.id))
              .toList();

          if (visibleCategories.isEmpty) {
            return Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GomandapTokens.lightSlate),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, color: GomandapTokens.slateGray, size: 24),
                    SizedBox(height: 6),
                    Text(
                      'No dynamic categories active at the moment 🏛',
                      style: TextStyle(
                        color: GomandapTokens.slateGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: visibleCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.38,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final cat = visibleCategories[index];
              return _CategoryGridItem(category: cat, onTap: () => onCategoryTap(cat));
            },
          );
        },
        loading: () => _buildGridPlaceholder(),
        error: (_, __) => _buildGridPlaceholder(),
      ),
    );
  }

  Widget _buildGridPlaceholder() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.38,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: GomandapTokens.softMist,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
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
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: GomandapTokens.royalNavy.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
                // Premium Ambient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
                // Frosted Category Name
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Text(
                    widget.category.name,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

