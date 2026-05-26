import 'package:flutter/material.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class ReviewPanel extends StatelessWidget {
  const ReviewPanel({super.key});

  final List<Map<String, dynamic>> reviews = const [
    {
      'name': 'Manoj Kumar',
      'date': 'May 12, 2026',
      'rating': 5.0,
      'comment': 'Hosted my brother\'s wedding here last week. The decoration and catering coordination was flawless. The GoMandap Escrow service gave us 100% peace of mind, releasing payments only as milestones were reached! Highly recommended.',
      'verified': true,
    },
    {
      'name': 'Priyanka Reddy',
      'date': 'April 28, 2026',
      'rating': 4.8,
      'comment': 'Stunning convention hall. Highly professional staff, clean green rooms, and massive parking space. The food was absolutely delicious and hot when served.',
      'verified': true,
    },
    {
      'name': 'Anish Sharma',
      'date': 'March 15, 2026',
      'rating': 4.5,
      'comment': 'Excellent location, spacious outdoor laws, and clean amenities. Recommended for grand reception gatherings.',
      'verified': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customer Ratings & Reviews',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: GomandapTokens.royalNavy,
          ),
        ),
        const SizedBox(height: 16),

        // Rating Overview & Bars Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Rating Score Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GomandapTokens.lightSlate),
              ),
              child: const Column(
                children: [
                  Text(
                    '4.9',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: GomandapTokens.royalNavy,
                    ),
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: GomandapTokens.champagneGoldEnd),
                      Icon(Icons.star_rounded, size: 14, color: GomandapTokens.champagneGoldEnd),
                      Icon(Icons.star_rounded, size: 14, color: GomandapTokens.champagneGoldEnd),
                      Icon(Icons.star_rounded, size: 14, color: GomandapTokens.champagneGoldEnd),
                      Icon(Icons.star_rounded, size: 14, color: GomandapTokens.champagneGoldEnd),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '182 Verified Reviews',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: GomandapTokens.slateGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Rating Bar breakdown chart
            Expanded(
              child: Column(
                children: [
                  _buildBreakdownRow('5 Star', 0.85),
                  _buildBreakdownRow('4 Star', 0.12),
                  _buildBreakdownRow('3 Star', 0.02),
                  _buildBreakdownRow('2 Star', 0.01),
                  _buildBreakdownRow('1 Star', 0.00),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Review list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _buildReviewCard(review);
          },
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String starLabel, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              starLabel,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: GomandapTokens.slateGray,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: percentage > 0.5 ? GomandapTokens.emeraldGreen : GomandapTokens.champagneGoldEnd,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '${(percentage * 100).toInt()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: GomandapTokens.slateGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = review['rating'] as double;
    final isVerified = review['verified'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GomandapTokens.lightSlate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name + Verified Check + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: GomandapTokens.royalNavy.withValues(alpha: 0.08),
                    child: Text(
                      review['name']![0],
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['name']!,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                      ),
                      if (isVerified)
                        const Row(
                          children: [
                            Icon(Icons.verified, size: 10, color: GomandapTokens.emeraldGreen),
                            SizedBox(width: 2),
                            Text(
                              'Verified Booking',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GomandapTokens.emeraldGreen),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              Text(
                review['date']!,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating stars
          Row(
            children: List.generate(5, (starIdx) {
              return Icon(
                Icons.star_rounded,
                size: 14,
                color: starIdx < rating ? GomandapTokens.champagneGoldEnd : GomandapTokens.lightSlate,
              );
            }),
          ),
          const SizedBox(height: 8),

          // Review Comment
          Text(
            review['comment']!,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: GomandapTokens.royalNavy,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

