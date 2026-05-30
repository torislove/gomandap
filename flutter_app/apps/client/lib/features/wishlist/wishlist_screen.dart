import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import '../../core/i18n/i18n_notifier.dart';
import '../../core/i18n/tr_widget.dart';
import '../home/home_notifier.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  String _selectedFilter = 'All';
  final _filters = ['wishlist.all', 'wishlist.venues', 'wishlist.photography', 'wishlist.makeup', 'wishlist.decor', 'wishlist.catering'];

  bool _isLoading = true;
  List<VendorSummary> _wishlistItems = [];

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoading = true);
    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      setState(() {
        _wishlistItems = const [];
        _isLoading = false;
      });
      return;
    }

    try {
      const userId = 'user_123'; // Simulating standard active user ID
      final shortlistsRes = await client.from('shortlists').select('vendor_id').eq('user_id', userId);
      final List<String> vendorIds = (shortlistsRes as List<dynamic>)
          .map((e) => e['vendor_id'].toString())
          .toList();

      if (vendorIds.isEmpty) {
        setState(() {
          _wishlistItems = const [];
          _isLoading = false;
        });
        return;
      }

      final vendorsRes = await client.from('vendors').select().inFilter('id', vendorIds);
      final vendors = (vendorsRes as List<dynamic>).map<VendorSummary>((row) {
        final gallery = row['photos'] as List<dynamic>?;
        final images = gallery?.map((e) => e.toString()).toList() ?? [];
        if (images.isEmpty) {
          final cover = row['cover_photo_url']?.toString();
          if (cover != null && cover.isNotEmpty) {
            images.add(cover);
          }
        }
        final categoryName = row['type']?.toString() == 'Banquet' ? 'Venue' : (row['type']?.toString() ?? 'Service');
        return VendorSummary(
          id: row['id']?.toString() ?? '',
          name: row['name']?.toString() ?? '',
          locality: row['locality']?.toString() ?? '',
          rating: double.tryParse(row['rating']?.toString() ?? '') ?? 4.8,
          reviewCount: 18,
          basePlatePrice: double.tryParse(row['base_price']?.toString() ?? '') ?? 1500,
          packagePrice: double.tryParse(row['base_price']?.toString() ?? '') ?? 450000,
          imageUrls: images.isEmpty ? ['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'] : images,
          videoUrl: row['video_url']?.toString(),
          category: categoryName,
        );
      }).toList();

      setState(() {
        _wishlistItems = vendors;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Wishlist load error: $e');
      setState(() {
        _wishlistItems = const [];
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromWishlist(String vendorId, String businessName) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    try {
      const userId = 'user_123';
      await client.from('shortlists').delete().eq('user_id', userId).eq('vendor_id', vendorId);
      
      setState(() {
        _wishlistItems.removeWhere((item) => item.id == vendorId);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.t('wishlist.removed', {'name': businessName})),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Remove shortlist error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map category filters from i18n names
    final filtered = _wishlistItems.where((item) {
      if (_selectedFilter == 'All') return true;
      final filterLower = _selectedFilter.toLowerCase();
      if (filterLower.contains('venue')) {
        return item.category == 'Venue';
      } else if (filterLower.contains('photograph')) {
        return item.category.toLowerCase().contains('photo');
      } else if (filterLower.contains('makeup')) {
        return item.category.toLowerCase().contains('makeup');
      } else if (filterLower.contains('decor')) {
        return item.category.toLowerCase().contains('decor');
      } else if (filterLower.contains('cater')) {
        return item.category.toLowerCase().contains('cater');
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: GomandapTokens.royalNavy),
          onPressed: () => context.pop(),
        ),
        title: const Tr('wishlist.title',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(GomandapTokens.champagneGoldStart)))
          : Column(
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
                      // Match filters
                      final filterKey = filter == 'wishlist.all' ? 'All' : filter;
                      final isActive = filterKey == _selectedFilter;
                      final translatedFilter = ref.t(filter);
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedFilter = filterKey);
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
                          child: Text(translatedFilter,
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
                          itemBuilder: (_, i) {
                            final vendor = filtered[i];
                            return _WishlistCard(
                              item: vendor,
                              onRemove: () {
                                HapticFeedback.mediumImpact();
                                _removeFromWishlist(vendor.id, vendor.name);
                              },
                              onTap: () => context.push('/vendor/${vendor.id}'),
                            );
                          },
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
          const Tr('wishlist.empty_title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(height: 8),
          const Tr('wishlist.empty_sub', style: TextStyle(color: GomandapTokens.slateGray)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(color: GomandapTokens.emeraldGreen, borderRadius: BorderRadius.circular(12)),
              child: const Tr('cart.explore_vendors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final VendorSummary item;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _WishlistCard({required this.item, required this.onRemove, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final priceLabel = item.category == 'Venue'
        ? '₹${item.basePlatePrice.toInt()}/plate'
        : '₹${item.packagePrice.toInt()}';

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
                    item.imageUrls.first,
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
                  Text(priceLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: GomandapTokens.emeraldGreen)),
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
