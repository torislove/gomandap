import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_footer.dart';
import 'package:gomandap_common/presentation/widgets/skeleton_loader.dart';
import '../../home/home_notifier.dart';
import '../../home/widgets/advanced_vendor_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../search_notifier.dart';

class StaggeredResultsFeed extends ConsumerWidget {
  final List<VendorSummary> vendors;
  final bool isLoading;

  const StaggeredResultsFeed({
    super.key,
    required this.vendors,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.58,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => _SkeletonFeedCard(),
      );
    }

    if (vendors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 72,
                color: GomandapTokens.slateGray,
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 20),
              const Text(
                'No matches found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: GomandapTokens.royalNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try broadening your budget, capacity ranges, or switching categories to discover premium event vendors.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: GomandapTokens.slateGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Clears filters and resets query
                  final notifier = ref.read(searchNotifierProvider.notifier);
                  notifier.clearAllFilters();
                  notifier.updateQuery('');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GomandapTokens.softMist,
                  foregroundColor: GomandapTokens.royalNavy,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: const Text('Suggested Alternatives', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.58,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final vendor = vendors[index];
                return AdvancedVendorCard(
                  vendor: vendor,
                  isSponsored: (index + 1) % 5 == 0, // Every 5th result is gold sponsored
                  onTap: () => context.push('/vendor/${vendor.id}'),
                  onBookNow: () => context.push('/vendor/${vendor.id}'),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: (index * 70).ms, curve: Curves.easeOut)
                    .slideY(begin: 0.15, end: 0, duration: 450.ms, delay: (index * 70).ms, curve: Curves.easeOutCubic);
              },
              childCount: vendors.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
        const SliverToBoxAdapter(
          child: GomandapFooter(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 90),
        ),
      ],
    );
  }
}

class _SkeletonFeedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: SkeletonLoader(width: double.infinity, height: double.infinity, borderRadius: 0),
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(height: 12, width: 110),
                  const SizedBox(height: 6),
                  const SkeletonLoader(height: 10, width: 70),
                  const Spacer(),
                  const SkeletonLoader(height: 28, width: double.infinity),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

