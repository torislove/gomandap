import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_footer.dart';
import '../../home/home_notifier.dart';
import '../../home/widgets/advanced_vendor_card.dart';

class StaggeredResultsFeed extends StatelessWidget {
  final List<VendorSummary> vendors;
  final bool isLoading;

  const StaggeredResultsFeed({
    super.key,
    required this.vendors,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
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
              childAspectRatio: 0.72,
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
          Expanded(
            flex: 10,
            child: Container(
              decoration: const BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 110, color: GomandapTokens.softMist),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 70, color: GomandapTokens.softMist),
                  const Spacer(),
                  Container(height: 28, decoration: BoxDecoration(color: GomandapTokens.softMist, borderRadius: BorderRadius.circular(8))),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.4));
  }
}

