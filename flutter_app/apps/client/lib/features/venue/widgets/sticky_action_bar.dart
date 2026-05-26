import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class StickyActionBar extends StatelessWidget {
  final double price;
  final String category;
  final VoidCallback onBookPressed;

  const StickyActionBar({
    super.key,
    required this.price,
    required this.category,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isPerPlate = category == 'Venue' || category == 'Catering';
    final formattedPrice = isPerPlate
        ? '₹${price.toInt()}'
        : '₹${(price / 1000).toStringAsFixed(0)}K';

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 84,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            border: const Border(
              top: BorderSide(color: GomandapTokens.lightSlate, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Price Info Block
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Starting Estimate',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: GomandapTokens.slateGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        formattedPrice,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GomandapTokens.royalNavy,
                        ),
                      ),
                      if (isPerPlate)
                        const Text(
                          ' /plate',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: GomandapTokens.slateGray,
                          ),
                        )
                      else
                        const Text(
                          ' package',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: GomandapTokens.slateGray,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),

              // Chat Ghost Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening secure chat window with Vendor...'),
                      backgroundColor: GomandapTokens.royalNavy,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: GomandapTokens.softMist,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GomandapTokens.lightSlate),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: GomandapTokens.royalNavy,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Main Emerald "Book with Escrow" CTA
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    onBookPressed();
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [GomandapTokens.emeraldGreen, GomandapTokens.emeraldGreenDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          category == 'Venue' ? 'Book with Escrow' : 'Reserve Service',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

