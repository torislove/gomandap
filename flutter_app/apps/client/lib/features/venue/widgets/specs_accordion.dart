import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class SpecsAccordion extends StatefulWidget {
  final Map<String, dynamic>? customSpecs;

  const SpecsAccordion({super.key, this.customSpecs});

  @override
  State<SpecsAccordion> createState() => _SpecsAccordionState();
}

class _SpecsAccordionState extends State<SpecsAccordion> {
  int _expandedIndex = -1;

  final List<Map<String, dynamic>> _defaultSections = [
    {
      'title': 'Pricing & Package Policy 💰',
      'items': [
        {'label': 'Vegetarian Plate base', 'val': '₹1,200 - ₹1,500 / plate'},
        {'label': 'Non-Vegetarian Plate base', 'val': '₹1,500 - ₹1,800 / plate'},
        {'label': 'Booking Advance required', 'val': '25% of total estimate'},
        {'label': 'Escrow milestone payment', 'val': 'Supported (3 parts)'},
      ],
    },
    {
      'title': 'Luxury Amenities & Spaces 🏛',
      'items': [
        {'label': 'Air Conditioning', 'val': 'Fully Centralized (100% backup)'},
        {'label': 'Green Rooms available', 'val': '4 Deluxe VIP suits'},
        {'label': 'Seating Capacity', 'val': '800 Seated, 1500 Floating'},
        {'label': 'Dedicated Parking', 'val': 'Valet parking for 180 cars'},
      ],
    },
    {
      'title': 'Operating Policies & Rules 📋',
      'items': [
        {'label': 'Outside Caterers', 'val': 'Allowed (Special license required)'},
        {'label': 'Outside Decorators', 'val': 'Allowed from panel list only'},
        {'label': 'Alcohol & Bars', 'val': 'Permitted (State license mandatory)'},
        {'label': 'Late Night Music', 'val': 'Allowed inside halls till 1:00 AM'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _defaultSections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;
        final isExpanded = _expandedIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GomandapTokens.lightSlate),
            boxShadow: GomandapTokens.softShadow,
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _expandedIndex = isExpanded ? -1 : index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        section['title']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: GomandapTokens.royalNavy,
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: GomandapTokens.slateGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                    children: [
                      const Divider(color: GomandapTokens.lightSlate, height: 1),
                      const SizedBox(height: 12),
                      ...(section['items'] as List<Map<String, String>>).map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['label']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: GomandapTokens.slateGray,
                                ),
                              ),
                              Text(
                                item['val']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: GomandapTokens.royalNavy,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
