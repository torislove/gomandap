import 'package:flutter/material.dart';
import '../../theme/gomandap_tokens.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GomandapTokens.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: GomandapTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: GomandapTokens.champagneGoldStart, size: 28),
          const SizedBox(height: GomandapTokens.spacingXs),
          Text(title, style: GomandapTokens.outfitSubtitle),
          const SizedBox(height: GomandapTokens.spacingXxs),
          Text(value, style: GomandapTokens.outfitTitle.copyWith(fontSize: 20)),
        ],
      ),
    );
  }
}
