import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../../home/home_notifier.dart';

class SpecsAccordion extends StatefulWidget {
  final String category;
  final VendorCategorySpecs specs;

  const SpecsAccordion({
    super.key,
    required this.category,
    required this.specs,
  });

  @override
  State<SpecsAccordion> createState() => _SpecsAccordionState();
}

class _SpecsAccordionState extends State<SpecsAccordion> {
  int _expandedIndex = 0; // Pre-expand first section for professional high-visibility

  List<Map<String, dynamic>> _buildDynamicSections() {
    final cat = widget.category.toLowerCase();
    final bool isVenue = cat.contains('hall') || cat.contains('mandapam') || cat.contains('lawn') || cat == 'venue';
    final bool isPhoto = cat.contains('photo') || cat.contains('camera');
    final bool isMakeup = cat.contains('makeup') || cat.contains('brush');
    final bool isCatering = cat.contains('cater');
    final bool isDecor = cat.contains('decor') || cat.contains('canopy');

    if (isVenue) {
      final veg = widget.specs.vegPlatePrice ?? 1200;
      final nonVeg = widget.specs.nonVegPlatePrice ?? 1500;
      final cap = widget.specs.guestCapacity ?? 600;
      final rooms = widget.specs.roomsAvailable ?? 12;

      return [
        {
          'title': 'Pricing & Package Policy 💰',
          'items': [
            {'label': 'Vegetarian Plate Base', 'val': '₹${veg.toInt()} / plate'},
            {'label': 'Non-Vegetarian Plate Base', 'val': '₹${nonVeg.toInt()} / plate'},
            {'label': 'Booking Advance Required', 'val': '25% of total estimate'},
            {'label': 'Escrow Milestone Payment', 'val': 'Supported (3 parts)'},
          ],
        },
        {
          'title': 'Luxury Amenities & Spaces 🏛',
          'items': [
            {'label': 'Air Conditioning', 'val': 'Fully Centralized (100% backup)'},
            {'label': 'Guest Seating Capacity', 'val': '$cap Seated & Floating'},
            {'label': 'Deluxe VIP Suits', 'val': '4 Green rooms available'},
            {'label': 'Dedicated Parking Space', 'val': 'Valet parking for 180+ cars'},
            {'label': 'AC Guest Rooms Available', 'val': '$rooms AC Suites'},
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
    } else if (isPhoto) {
      final photo = widget.specs.candidDayRate ?? 50000;
      final video = widget.specs.videoDayRate ?? 60000;
      final days = widget.specs.deliveryTimelineDays ?? 45;
      final brand = widget.specs.equipmentBrand ?? 'Sony Alpha Cinema Systems';

      return [
        {
          'title': 'Creative Photography Pricing 💰',
          'items': [
            {'label': 'Candid Photography Rate', 'val': '₹${photo.toInt()} / day'},
            {'label': 'Cinematography / Video Rate', 'val': '₹${video.toInt()} / day'},
            {'label': 'Booking Advance Required', 'val': '25% holding deposit'},
            {'label': 'Escrow Milestone Release', 'val': 'Supported (3 parts)'},
          ],
        },
        {
          'title': 'Deliverables & Creative Gear 📸',
          'items': [
            {'label': 'Film / Photo Delivery Speed', 'val': '$days Days (Web link & drive)'},
            {'label': 'Primary Camera Setup', 'val': brand},
            {'label': 'Raw Footage Policy', 'val': 'Provided (Hard drive provided by client)'},
            {'label': 'Creative Crew Team Size', 'val': '5 Creative members'},
          ],
        },
        {
          'title': 'Travel & Cancellation Policies 📋',
          'items': [
            {'label': 'Outstation Shoots', 'val': 'Client-borne travel & lodging'},
            {'label': 'Cancellation Policy', 'val': '50% Refundable up to 30 days prior'},
          ],
        },
      ];
    } else if (isCatering) {
      final veg = widget.specs.cateringVegPrice ?? 1400;
      final nonVeg = widget.specs.cateringNonVegPrice ?? 1800;
      final minPlates = widget.specs.minPlatesBooking ?? 150;

      return [
        {
          'title': 'Saffron Royal Catering Pricing 💰',
          'items': [
            {'label': 'Vegetarian Base Plate', 'val': '₹${veg.toInt()} / plate'},
            {'label': 'Non-Vegetarian Base Plate', 'val': '₹${nonVeg.toInt()} / plate'},
            {'label': 'Minimum Plates Booking', 'val': '$minPlates plates minimum'},
            {'label': 'Escrow Milestone Payment', 'val': 'Supported (3 parts)'},
          ],
        },
        {
          'title': 'Culinary Highlights & Cuisines 🍽',
          'items': [
            {'label': 'Cuisine Offerings', 'val': 'South Indian, North Indian, Pan-Asian'},
            {'label': 'Live Chaat & Dessert Bars', 'val': 'Available on request'},
            {'label': 'Kitchen Hygiene Standards', 'val': 'ISO 22000 Audited & Vetted'},
          ],
        },
      ];
    } else if (isMakeup) {
      final bridal = widget.specs.bridalMakeupPrice ?? 30000;
      final family = widget.specs.familyMakeupPrice ?? 5000;
      final brand = widget.specs.makeupBrandTier ?? 'Premium MAC & Huda Beauty';
      final trial = (widget.specs.trialSessionAvailable ?? true) ? 'Paid trial adjustable in booking' : 'No trials offered';

      return [
        {
          'title': 'Makeup Artistry Packages 💰',
          'items': [
            {'label': 'Bridal HD / Airbrush Package', 'val': '₹${bridal.toInt()} per event'},
            {'label': 'Family / Guest Makeup', 'val': '₹${family.toInt()} / pax'},
            {'label': 'Trial Session Policy', 'val': trial},
            {'label': 'Advance Booking Deposit', 'val': '25% holding deposit'},
          ],
        },
        {
          'title': 'Cosmetics & Draping details 💄',
          'items': [
            {'label': 'Primary Brand Tier', 'val': brand},
            {'label': 'Hair Styling & Saree Draping', 'val': 'Included in Bridal package'},
            {'label': 'Makeup Lashes / Accessories', 'val': 'Premium Mink lashes included'},
          ],
        },
      ];
    } else if (isDecor) {
      final indoor = widget.specs.indoorDecorPrice ?? 80000;
      final outdoor = widget.specs.outdoorStagePrice ?? 120000;
      final setup = widget.specs.setupHours ?? 8;
      final flora = widget.specs.floralGrade ?? 'Premium Fresh Flowers';

      return [
        {
          'title': 'Elite Decoration Pricing 💰',
          'items': [
            {'label': 'Indoor Mandap Base Decor', 'val': '₹${indoor.toInt()}'},
            {'label': 'Outdoor Backdrop Base Decor', 'val': '₹${outdoor.toInt()}'},
            {'label': 'Floral Quality Grade', 'val': flora},
            {'label': 'Advance Booking Deposit', 'val': '25% locked in Escrow'},
          ],
        },
        {
          'title': 'Execution & Layout Timelines ⏱',
          'items': [
            {'label': 'Setup Hours Required', 'val': '$setup Hours design & installation'},
            {'label': 'Theme Customizations', 'val': '3D CAD render layout beforehand'},
            {'label': 'Sound, Laser & Stage AV', 'val': 'Audio truss & lasers panel supported'},
          ],
        },
      ];
    } else {
      return _defaultSections;
    }
  }

  final List<Map<String, dynamic>> _defaultSections = [
    {
      'title': 'Pricing & Booking Policy 💰',
      'items': [
        {'label': 'Booking Advance required', 'val': '25% of total estimate'},
        {'label': 'Escrow milestone payment', 'val': 'Supported (3 parts)'},
      ],
    },
    {
      'title': 'Rules & Cancellation Policies 📋',
      'items': [
        {'label': 'Cancellation Policy', 'val': 'Flexible refund policy applies'},
        {'label': 'Outside Vendors', 'val': 'Allowed from panel list only'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final sections = _buildDynamicSections();

    return Column(
      children: sections.asMap().entries.map((entry) {
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        section['title']!,
                        style: GoogleFonts.outfit(
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
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: GomandapTokens.slateGray,
                                ),
                              ),
                              Text(
                                item['val']!,
                                style: GoogleFonts.inter(
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
