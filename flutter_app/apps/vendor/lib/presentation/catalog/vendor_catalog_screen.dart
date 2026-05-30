import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/category_model.dart';
import '../shared/vendor_responsive_shell.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';

class VendorCatalogScreen extends StatefulWidget {
  const VendorCatalogScreen({super.key});

  @override
  State<VendorCatalogScreen> createState() => _VendorCatalogScreenState();
}

class _VendorCatalogScreenState extends State<VendorCatalogScreen> with SingleTickerProviderStateMixin {
  // Currently selected category (defaults to Banquet Halls)
  CategoryDetails _selectedCategory = weddingCategoriesList.first;

  // Controllers for general inputs
  final _basePriceController = TextEditingController(text: '120000');
  final _taxStatusController = TextEditingController(text: '18% GST Extra');
  final _minBookingController = TextEditingController(text: '1 Event Day');

  // Category specific inputs Map
  final Map<String, TextEditingController> _specsControllers = {};

  // R2 Portfolio State
  final List<Map<String, dynamic>> _portfolioItems = [
    {
      'url': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400',
      'name': 'Grand Ballroom Setup.jpg',
      'size': '4.2 MB',
      'uploaded': true,
      'progress': 1.0,
      'isR2': true,
    },
    {
      'url': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400',
      'name': 'Muhurtham Floral Gate.jpg',
      'size': '2.8 MB',
      'uploaded': true,
      'progress': 1.0,
      'isR2': true,
    },
  ];

  bool _isUploadingR2 = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _initializeCategorySpecs();
  }

  @override
  void dispose() {
    _basePriceController.dispose();
    _taxStatusController.dispose();
    _minBookingController.dispose();
    for (var controller in _specsControllers.values) {
      controller.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  void _initializeCategorySpecs() {
    // Clear and build inputs based on category
    _specsControllers.clear();
    
    if (_selectedCategory.name.contains('Hall') || _selectedCategory.name.contains('Mandap') || _selectedCategory.name.contains('Lawn')) {
      _specsControllers['Guest Capacity'] = TextEditingController(text: '800 Guests');
      _specsControllers['Veg Plate Price'] = TextEditingController(text: '₹1,200 / Plate');
      _specsControllers['Non-Veg Plate Price'] = TextEditingController(text: '₹1,500 / Plate');
      _specsControllers['Rooms Available'] = TextEditingController(text: '12 Luxury AC Rooms');
      _specsControllers['Parking Bays'] = TextEditingController(text: '250 Vehicles');
    } else if (_selectedCategory.name.contains('Photographer')) {
      _specsControllers['Candid Rate'] = TextEditingController(text: '₹75,000 / Day');
      _specsControllers['Cinematography Rate'] = TextEditingController(text: '₹90,000 / Day');
      _specsControllers['Delivery Speed'] = TextEditingController(text: '45 Business Days');
      _specsControllers['Camera Brand'] = TextEditingController(text: 'Sony Alpha 1 & FX3');
      _specsControllers['Raw Footage Policy'] = TextEditingController(text: 'Provided in SSD');
    } else if (_selectedCategory.name.contains('Makeup')) {
      _specsControllers['Bridal Package Fee'] = TextEditingController(text: '₹35,000');
      _specsControllers['Family Makeup Per Guest'] = TextEditingController(text: '₹6,000');
      _specsControllers['Premium Brands Used'] = TextEditingController(text: 'Huda Beauty, MAC & Dior');
      _specsControllers['Trial Session Available'] = TextEditingController(text: 'Yes (Paid Trial)');
      _specsControllers['Draping Support'] = TextEditingController(text: 'Saree & Dupatta Included');
    } else if (_selectedCategory.name.contains('Decor')) {
      _specsControllers['Setup Hours Needed'] = TextEditingController(text: '8 - 12 Hours');
      _specsControllers['Floral Grade'] = TextEditingController(text: 'Premium Fresh Flowers');
      _specsControllers['Sound Laser AV Status'] = TextEditingController(text: 'Add-on JBL Rig Available');
      _specsControllers['Seating Layouts'] = TextEditingController(text: 'Round Table & Theatre Style');
    } else {
      // General fallbacks
      for (var filter in _selectedCategory.deepFilterKeys) {
        _specsControllers[filter] = TextEditingController(text: 'Standard Premium Spec');
      }
    }
  }

  // Simulated Cloudflare R2 Upload Manager
  Future<void> _uploadPortfolioToR2() async {
    if (_isUploadingR2) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isUploadingR2 = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Compressing Image Assets (85% Quality)...';
    });

    // Step 1: Compress
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _uploadProgress = 0.25;
      _uploadStatus = 'Establishing Secure Connection to R2 Bucket...';
    });

    // Step 2: Upload
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _uploadProgress = 0.55;
      _uploadStatus = 'Uploading to r2://gomandap-vault/portfolio/...';
    });

    // Step 3: Stream upload
    for (int i = 60; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _uploadProgress = i / 100.0;
      });
    }

    // Step 4: Finished
    final newImages = [
      'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=400',
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
      'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=400',
    ];
    final randomImage = newImages[_portfolioItems.length % newImages.length];

    setState(() {
      _isUploadingR2 = false;
      _portfolioItems.add({
        'url': randomImage,
        'name': 'Portfolio_Item_${_portfolioItems.length + 1}.jpg',
        'size': '3.4 MB',
        'uploaded': true,
        'progress': 1.0,
        'isR2': true,
      });
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_done_rounded, color: GomandapTokens.emeraldGreen),
            const SizedBox(width: 8),
            Text(
              'Successfully uploaded to R2 Storage vault! ☁️',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: GomandapTokens.royalNavyLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Simulated Save operation with Supabase Dynamic Spec payload
  Future<void> _saveDynamicSpecs() async {
    HapticFeedback.heavyImpact();
    _animController.forward();
    
    // Show premium fullscreen saving sequence
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              color: GomandapTokens.royalNavyLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(GomandapTokens.champagneGoldStart),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Syncing to Supabase DB',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Updating polymorphic specification grids and Cloudflare R2 cache records.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: Colors.white60,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulate network delay to Supabase
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    _animController.reverse();
    Navigator.of(context).pop(); // Dismiss Dialog

    // Success alert dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GomandapTokens.royalNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: GomandapTokens.champagneGoldStart, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: GomandapTokens.champagneGoldStart, size: 24),
            const SizedBox(width: 8),
            Text(
              'Publish Success',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'Your dynamic vendor catalog has been successfully synchronized. All updates are live for active client searches in Jubilee Hills immediately!',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Acknowledge',
              style: GoogleFonts.outfit(
                color: GomandapTokens.champagneGoldStart,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return VendorResponsiveShell(
      activePath: '/catalog',
      child: GomandapScreen(
        backgroundColor: GomandapTokens.royalNavy,
        useHorizontalPadding: false,
        useSafeAreaTop: true,
        useSafeAreaBottom: false,
        maxWidth: 1200.0,
        body: Stack(
          children: [
            // 1. Gold Filigree corners backdrop
            Positioned.fill(
              child: CustomPaint(
                painter: EthnicFiligreePainter(color: const Color(0x10DFBA73)),
              ),
            ),

            // 2. Main Scrollable Container
            Column(
                children: [
                  // Top Custom Header with Hanging Marigold Garland
                  _buildDynamicHeader(),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (screenWidth <= 800) ...[
                              // Mobile stacked cards
                              _buildCategorySelectorCard(),
                              const SizedBox(height: 20),
                              _buildSpecificationFormSection(),
                              const SizedBox(height: 20),
                              _buildR2PortfolioSection(),
                              const SizedBox(height: 32),
                              _buildSaveActionButton(),
                            ] else ...[
                              // Desktop split column grid
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left side forms
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildCategorySelectorCard(),
                                        const SizedBox(height: 20),
                                        _buildSpecificationFormSection(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Right side uploads & CTA
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildR2PortfolioSection(),
                                        const SizedBox(height: 32),
                                        _buildSaveActionButton(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: GomandapTokens.royalNavy,
      ),
      child: Column(
        children: [
          // Marigold garland sweep at the top
          SizedBox(
            height: 16,
            width: double.infinity,
            child: CustomPaint(
              painter: MarigoldGarlandPainter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.pop();
                          },
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.workspace_premium_rounded, color: GomandapTokens.champagneGoldStart, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          'GoMandap Catalog',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Text(
                        'Polymorphic Service Specifications Manager',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: GomandapTokens.royalNavyLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_circle_rounded, size: 14, color: GomandapTokens.champagneGoldStart),
                      const SizedBox(width: 4),
                      Text(
                        'R2 Vault Active',
                        style: GoogleFonts.inter(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: GomandapTokens.champagneGoldStart,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
        ],
      ),
    );
  }

  Widget _buildCategorySelectorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.category_rounded, color: GomandapTokens.champagneGoldStart, size: 18),
              const SizedBox(width: 8),
              Text(
                'Primary Service Offering',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: GomandapTokens.royalNavy,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.15)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CategoryDetails>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: GomandapTokens.royalNavyLight,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: GomandapTokens.champagneGoldStart),
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                onChanged: (CategoryDetails? val) {
                  if (val != null) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedCategory = val;
                      _initializeCategorySpecs();
                    });
                  }
                },
                items: weddingCategoriesList.map((cat) {
                  return DropdownMenuItem<CategoryDetails>(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(cat.fallbackIcon, size: 16, color: GomandapTokens.champagneGoldStart),
                        const SizedBox(width: 10),
                        Text(cat.name),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Switching categories dynamically configures the corresponding parameters and layout specifications schemas inside the client portal.',
            style: TextStyle(
              fontSize: 9.5,
              color: Colors.white.withValues(alpha: 0.35),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_rounded, color: GomandapTokens.champagneGoldStart, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Spec Sheet & Rates',
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _selectedCategory.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: GomandapTokens.champagneGoldStart,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Base Price Input
          _buildTextField(
            label: 'Starting Base Rate (₹)',
            controller: _basePriceController,
            icon: Icons.currency_rupee_rounded,
            hint: 'e.g. 150000',
          ),
          const SizedBox(height: 14),

          // Taxes Status Input
          _buildTextField(
            label: 'Tax Policy / Details',
            controller: _taxStatusController,
            icon: Icons.receipt_long_rounded,
            hint: 'e.g. 18% GST Extra',
          ),
          const SizedBox(height: 14),

          // Minimum Booking Input
          _buildTextField(
            label: 'Minimum Booking Hold Duration',
            controller: _minBookingController,
            icon: Icons.calendar_today_rounded,
            hint: 'e.g. 1 Event Day',
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10, height: 1),
          ),

          // Category Specific Dynamic Header
          Text(
            'CATEGORY-SPECIFIC ATTRIBUTES',
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: GomandapTokens.champagneGoldStart,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),

          // Dynamic Textfields grid
          ..._specsControllers.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildTextField(
                label: entry.key,
                controller: entry.value,
                icon: _getIconForAttribute(entry.key),
                hint: 'Fill specification details',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: GomandapTokens.royalNavy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: GomandapTokens.champagneGoldStart, size: 16),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildR2PortfolioSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_upload_rounded, color: GomandapTokens.champagneGoldStart, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Portfolio Images (R2 Engine)',
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                '${_portfolioItems.length} Files',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Upload state indicator
          if (_isUploadingR2) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: GomandapTokens.royalNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _uploadStatus,
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${(_uploadProgress * 100).toInt()}%',
                        style: GoogleFonts.inter(fontSize: 10, color: GomandapTokens.champagneGoldStart, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _uploadProgress,
                      minHeight: 5,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(GomandapTokens.champagneGoldStart),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Photos Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _portfolioItems.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, idx) {
              if (idx == _portfolioItems.length) {
                // Add Item Block
                return GestureDetector(
                  onTap: _uploadPortfolioToR2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: GomandapTokens.royalNavy,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.25),
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_rounded, color: GomandapTokens.champagneGoldStart, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          'Upload R2',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: GomandapTokens.champagneGoldStart,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final item = _portfolioItems[idx];
              return Container(
                decoration: BoxDecoration(
                  color: GomandapTokens.royalNavy,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          item['url'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.image, color: Colors.white24));
                          },
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Color(0xCC000000)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        left: 6,
                        right: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['size'],
                                  style: const TextStyle(fontSize: 7, color: Colors.white30),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: GomandapTokens.emeraldGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'R2 Cache',
                                    style: TextStyle(fontSize: 6, color: GomandapTokens.emeraldGreen, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _portfolioItems.removeAt(idx);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 10, color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveActionButton() {
    return GestureDetector(
      onTap: _saveDynamicSpecs,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: GomandapTokens.goldLeafGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: GomandapTokens.goldGlowShadow,
        ),
        child: Center(
          child: Text(
            'Sync Specs to Supabase & Live Clients',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: GomandapTokens.royalNavy,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }



  IconData _getIconForAttribute(String attribute) {
    switch (attribute) {
      case 'Guest Capacity':
        return Icons.people_outline_rounded;
      case 'Veg Plate Price':
      case 'Non-Veg Plate Price':
        return Icons.restaurant_menu_rounded;
      case 'Rooms Available':
        return Icons.hotel_rounded;
      case 'Parking Bays':
        return Icons.local_parking_rounded;
      case 'Candid Rate':
      case 'Cinematography Rate':
        return Icons.photo_camera_rounded;
      case 'Delivery Speed':
        return Icons.speed_rounded;
      case 'Camera Brand':
        return Icons.camera_rounded;
      case 'Raw Footage Policy':
        return Icons.save_rounded;
      case 'Bridal Package Fee':
      case 'Family Makeup Per Guest':
        return Icons.brush_rounded;
      case 'Premium Brands Used':
        return Icons.dry_cleaning_rounded;
      case 'Trial Session Available':
        return Icons.check_circle_outline_rounded;
      case 'Draping Support':
        return Icons.accessibility_new_rounded;
      case 'Setup Hours Needed':
        return Icons.timer_rounded;
      case 'Floral Grade':
        return Icons.eco_rounded;
      case 'Sound Laser AV Status':
        return Icons.volume_up_rounded;
      case 'Seating Layouts':
        return Icons.grid_view_rounded;
      default:
        return Icons.check_box_outline_blank_rounded;
    }
  }
}
