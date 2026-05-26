import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class CityParallaxRow extends StatefulWidget {
  const CityParallaxRow({super.key});

  @override
  State<CityParallaxRow> createState() => _CityParallaxRowState();
}

class _CityParallaxRowState extends State<CityParallaxRow> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> cities = [
    {
      'name': 'Hyderabad',
      'count': '340+ Mandaps',
      'image': 'https://images.unsplash.com/photo-1605649487212-47bdab064df7?auto=format&fit=crop&w=600&q=80',
      'tagline': 'Royal Heritage & Grandeur',
    },
    {
      'name': 'Bengaluru',
      'count': '280+ Venues',
      'image': 'https://images.unsplash.com/photo-1596176530529-78163a4f7af2?auto=format&fit=crop&w=600&q=80',
      'tagline': 'Garden Luxury & Tech-Chic',
    },
    {
      'name': 'Chennai',
      'count': '190+ Mandaps',
      'image': 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?auto=format&fit=crop&w=600&q=80',
      'tagline': 'Coastal Grace & Tradition',
    },
    {
      'name': 'Mumbai',
      'count': '420+ Venues',
      'image': 'https://images.unsplash.com/photo-1570168007244-23704139443d?auto=format&fit=crop&w=600&q=80',
      'tagline': 'High-Fashion Glamour',
    },
    {
      'name': 'Delhi NCR',
      'count': '510+ Venues',
      'image': 'https://images.unsplash.com/photo-1587474260584-136574528ed5?auto=format&fit=crop&w=600&q=80',
      'tagline': 'Imperial Celebrations',
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return CityParallaxCard(
            city: cities[index],
            scrollController: _scrollController,
          );
        },
      ),
    );
  }
}

class CityParallaxCard extends StatelessWidget {
  final Map<String, String> city;
  final ScrollController scrollController;

  const CityParallaxCard({
    super.key,
    required this.city,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // Dynamic city selection or search filtering logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exploring premium venues in ${city['name']}'),
            backgroundColor: GomandapTokens.royalNavy,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: GomandapTokens.royalNavy.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Parallax Background Image
              Flow(
                delegate: ParallaxFlowDelegate(
                  scrollable: Scrollable.of(context),
                  listItemContext: context,
                  backgroundImageKey: GlobalKey(),
                ),
                children: [
                  Image.network(
                    city['image']!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: GomandapTokens.softMist,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(GomandapTokens.emeraldGreen),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: GomandapTokens.softMist,
                      child: const Icon(Icons.image_not_supported, color: GomandapTokens.slateGray),
                    ),
                  ),
                ],
              ),
              // Dark elegant overlay gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              // Premium Glassmorphic details overlay
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          city['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: GomandapTokens.emeraldGreen.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            city['count']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      city['tagline']!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParallaxFlowDelegate extends FlowDelegate {
  ParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
  }) : super(repaint: scrollable.position);

  final ScrollableState scrollable;
  final BuildContext listItemContext;
  final GlobalKey backgroundImageKey;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return const BoxConstraints.tightFor(
      height: 180,
      width: 420, // Wider than viewport card so it has room to slide parallax
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    // Get scrollable bounds
    final scrollableBox = scrollable.context.findRenderObject() as RenderBox;
    // Get list item bounds
    final listItemBox = listItemContext.findRenderObject() as RenderBox;
    // Calculate the percentage position of the card relative to scrollable container
    final listItemOffset = listItemBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableBox,
    );

    // X percentage position: 0 at left-most edge, 1 at right-most edge
    final viewportWidth = scrollableBox.size.width;
    final cardPositionX = listItemOffset.dx;
    final cardWidth = listItemBox.size.width;

    // Normalizing X coordinate between -1 and 1 based on where the card is on screen
    final relativePositionX = (cardPositionX / (viewportWidth - cardWidth)).clamp(0.0, 1.0) * 2 - 1;

    // Maximum parallax slide amount
    const maxSlide = 80.0;
    final dx = -relativePositionX * maxSlide;

    // Paint background image with parallax offset
    context.paintChild(
      0,
      transform: Matrix4.translationValues(dx - 40, 0, 0),
    );
  }

  @override
  bool shouldRepaint(covariant ParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

