import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class HeroCarousel extends StatefulWidget {
  final List<HeroBannerItem> items;

  const HeroCarousel({super.key, required this.items});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_controller.hasClients) {
        final next = (_currentIndex + 1) % widget.items.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return _HeroBannerCard(item: item);
            },
          ),
          // Page indicator dots
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.items.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: _currentIndex == i ? 24 : 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == i
                        ? GomandapTokens.champagneGoldStart
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBannerCard extends StatelessWidget {
  final HeroBannerItem item;
  const _HeroBannerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: GomandapTokens.royalNavy,
        image: item.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(item.imageUrl!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
              )
            : null,
      ),
      child: Stack(
        children: [
          // Gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
              ),
            ),
          ),
          // Sponsored badge
          if (item.isSponsored)
            Positioned(
              top: 12, right: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.black.withValues(alpha: 0.4),
                    child: const Text('Sponsored',
                      style: TextStyle(color: GomandapTokens.champagneGoldStart, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          // Content bottom
          Positioned(
            bottom: 16, left: 16, right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.badge != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [GomandapTokens.champagneGoldStart, GomandapTokens.champagneGoldEnd],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(item.badge!,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                Text(item.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                if (item.subtitle != null)
                  Text(item.subtitle!,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeroBannerItem {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? badge;
  final bool isSponsored;

  const HeroBannerItem({
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.badge,
    this.isSponsored = false,
  });
}

// Default mock data
final defaultHeroBanners = [
  const HeroBannerItem(
    title: 'Luxury Banquet Halls',
    subtitle: 'Starting at ₹900/plate · Escrow Protected',
    imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=1200',
    badge: '🏆 TOP PICKS',
  ),
  const HeroBannerItem(
    title: 'Exclusive Summer Deals',
    subtitle: 'Up to 25% off on Catering Packages',
    imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1200',
    badge: '🔥 LIMITED OFFER',
    isSponsored: true,
  ),
  const HeroBannerItem(
    title: 'Elite Wedding Photographers',
    subtitle: 'Verified Studios · Cinematic & Candid',
    imageUrl: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=1200',
    badge: '📸 FEATURED',
  ),
];

