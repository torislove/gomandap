import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _selectedFilter = 'All';
  final _filters = ['All', 'Venues', 'Photography', 'Makeup', 'Decor', 'Catering'];

  // Mock wishlist data
  final _wishlistItems = [
    const _WishlistItem(id: '1', name: 'The Heritage Gala Resort', category: 'Venue', locality: 'Jubilee Hills', rating: 4.9, price: '₹1,500/plate', imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=600'),
    const _WishlistItem(id: 'p1', name: 'Lens & Light Studio', category: 'Photography', locality: 'Banjara Hills', rating: 4.9, price: '₹55,000', imageUrl: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=600'),
    const _WishlistItem(id: 'm1', name: 'Glam Studio by Priya', category: 'Makeup', locality: 'Banjara Hills', rating: 4.8, price: '₹25,000', imageUrl: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=600'),
    const _WishlistItem(id: '2', name: 'Royal Orchid Convention', category: 'Venue', locality: 'Hitech City', rating: 4.7, price: '₹1,200/plate', imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=600'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'All'
        ? _wishlistItems
        : _wishlistItems.where((i) => i.category.toLowerCase() == _selectedFilter.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: GomandapTokens.royalNavy),
          onPressed: () => context.pop(),
        ),
        title: const Text('My Wishlist',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFE11D48)),
                  const SizedBox(width: 4),
                  Text('${_wishlistItems.length}',
                    style: const TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final filter = _filters[i];
                final isActive = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedFilter = filter);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? GomandapTokens.royalNavy : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? GomandapTokens.royalNavy : GomandapTokens.lightSlate,
                      ),
                    ),
                    child: Text(filter,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : GomandapTokens.slateGray,
                      )),
                  ),
                );
              },
            ),
          ),

          // Grid
          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _WishlistCard(
                      item: filtered[i],
                      onRemove: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _wishlistItems.removeWhere((w) => w.id == filtered[i].id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${filtered[i].name} removed'),
                            action: SnackBarAction(label: 'Undo', onPressed: () {}),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onTap: () => context.push('/vendor/${filtered[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_border_rounded, size: 64, color: GomandapTokens.lightSlate),
          const SizedBox(height: 16),
          const Text('No saved vendors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(height: 8),
          const Text('Tap ❤️ on any vendor to save them here', style: TextStyle(color: GomandapTokens.slateGray)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: GomandapTokens.emeraldGreen, borderRadius: BorderRadius.circular(12)),
              child: const Text('Explore Vendors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistItem {
  final String id, name, category, locality, price, imageUrl;
  final double rating;
  const _WishlistItem({required this.id, required this.name, required this.category, required this.locality, required this.rating, required this.price, required this.imageUrl});
}

class _WishlistCard extends StatelessWidget {
  final _WishlistItem item;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _WishlistCard({required this.item, required this.onRemove, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GomandapTokens.lightSlate),
          boxShadow: GomandapTokens.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    item.imageUrl,
                    height: 110, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 110, color: GomandapTokens.softMist,
                      child: const Icon(Icons.image, color: GomandapTokens.slateGray),
                    ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 30, height: 30,
                      decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_rounded, size: 15, color: Color(0xFFE11D48)),
                    ),
                  ),
                ),
                // Category badge
                Positioned(
                  bottom: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: GomandapTokens.royalNavy.withAlpha(210), borderRadius: BorderRadius.circular(4)),
                    child: Text(item.category, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(item.locality, style: const TextStyle(fontSize: 10, color: GomandapTokens.slateGray)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 11, color: GomandapTokens.champagneGoldStart),
                      const SizedBox(width: 2),
                      Text('${item.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.price, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: GomandapTokens.emeraldGreen)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: GomandapTokens.emeraldGreen),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('Check Availability', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GomandapTokens.emeraldGreen)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
