import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/category_model.dart';

class VendorOnboardingWizard extends StatefulWidget {
  const VendorOnboardingWizard({super.key});

  @override
  State<VendorOnboardingWizard> createState() => _VendorOnboardingWizardState();
}

class _VendorOnboardingWizardState extends State<VendorOnboardingWizard> {
  int _currentStep = 0; // 0: Identity, 1: Milestones, 2: Portfolio, 3: Video, 4: Success

  // Category & Sub-Services State
  String? _selectedCategory;
  List<String> _selectedSubServices = [];

  // Step 1 Controllers
  final _nameController = TextEditingController();
  final _localityController = TextEditingController();
  final _gstinController = TextEditingController();
  final _descController = TextEditingController();

  // Step 2 Controllers
  final _basePriceController = TextEditingController(text: '1200');
  String _refundPolicy = 'Non-Refundable';
  double _milestone1 = 25;
  double _milestone2 = 50;
  double _milestone3 = 25;

  // Step 2 Dynamic Category-Specific Controllers
  final _vegPriceController = TextEditingController(text: '1200');
  final _nonVegPriceController = TextEditingController(text: '1500');
  final _capacityController = TextEditingController(text: '600');
  final _roomsController = TextEditingController(text: '12');

  final _candidRateController = TextEditingController(text: '50000');
  final _videoRateController = TextEditingController(text: '60000');
  final _deliveryDaysController = TextEditingController(text: '45');
  final _cameraBrandController = TextEditingController(text: 'Sony Alpha FX3');

  final _makeupBridalController = TextEditingController(text: '30000');
  final _makeupFamilyController = TextEditingController(text: '5000');
  String _makeupBrand = 'Huda Beauty & MAC';
  bool _trialAvailable = true;

  final _decorIndoorController = TextEditingController(text: '80000');
  final _decorOutdoorController = TextEditingController(text: '120000');
  final _decorSetupHoursController = TextEditingController(text: '8');
  String _floralGrade = 'Premium Fresh Flowers';

  // Step 3 Mock Portfolios
  final List<String> _mockImages = [];

  // Step 4 Video Simulation
  bool _isVideoUploading = false;
  double _videoProgress = 0.0;
  bool _isVideoUploaded = false;
  bool _isPlayingMockVideo = false;

  @override
  void dispose() {
    _nameController.dispose();
    _localityController.dispose();
    _gstinController.dispose();
    _descController.dispose();
    _basePriceController.dispose();
    
    _vegPriceController.dispose();
    _nonVegPriceController.dispose();
    _capacityController.dispose();
    _roomsController.dispose();
    _candidRateController.dispose();
    _videoRateController.dispose();
    _deliveryDaysController.dispose();
    _cameraBrandController.dispose();
    _makeupBridalController.dispose();
    _makeupFamilyController.dispose();
    _decorIndoorController.dispose();
    _decorOutdoorController.dispose();
    _decorSetupHoursController.dispose();
    
    super.dispose();
  }

  void _nextStep() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 4) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: GomandapTokens.royalNavy),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: const Text(
          'Become a GoMandap Vendor',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
        ),
      ),
      body: Column(
        children: [
          // Top Stepper Line
          _buildTopStepper(),

          // Active Wizard Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildActiveStepBody(),
            ),
          ),

          // Bottom Navigation Row
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildTopStepper() {
    final steps = ['Identity', 'Milestones', 'Portfolio', 'Intro Pitch'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (idx) {
          final isCompleted = idx < _currentStep;
          final isActive = idx == _currentStep;

          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? GomandapTokens.emeraldGreen
                        : isActive
                            ? GomandapTokens.royalNavy
                            : GomandapTokens.softMist,
                    shape: BoxShape.circle,
                    border: isActive ? Border.all(color: GomandapTokens.champagneGoldStart, width: 1.5) : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.done_rounded, size: 12, color: Colors.white)
                        : Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isActive ? Colors.white : GomandapTokens.slateGray,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  steps[idx],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive || isCompleted ? FontWeight.w800 : FontWeight.w600,
                    color: isActive
                        ? GomandapTokens.royalNavy
                        : isCompleted
                            ? GomandapTokens.emeraldGreen
                            : GomandapTokens.slateGray,
                  ),
                ),
                if (idx < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isCompleted ? GomandapTokens.emeraldGreen : GomandapTokens.lightSlate,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveStepBody() {
    switch (_currentStep) {
      case 0:
        return _buildIdentityStep();
      case 1:
        return _buildMilestonesStep();
      case 2:
        return _buildPortfolioStep();
      case 3:
        return _buildVideoStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Step 1: Business Identity ───────────────────────────────────────────────

  Widget _buildIdentityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 1: Business Profile 🏛', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        const Text('Register your business parameters correctly. Verified profiles attract up to 3x more bookings.', style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray, height: 1.45)),
        const SizedBox(height: 24),

        _buildTextField(label: 'Registered Business Name *', controller: _nameController, hint: 'e.g., The Royal Arch Decorators'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Operating Locality *', controller: _localityController, hint: 'e.g., Jubilee Hills, Hyderabad'),
        const SizedBox(height: 16),
        _buildTextField(label: 'GSTIN (Optional)', controller: _gstinController, hint: 'e.g., 36AAAAA1111A1Z1'),
        const SizedBox(height: 16),

        const Text('Primary Service Category *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text('Select a category', style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
              isExpanded: true,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy),
              items: weddingCategoriesList.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat.name,
                  child: Text(cat.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                  _selectedSubServices = []; // Reset sub-services
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (_selectedCategory != null) ...[
          const Text('Specialized Sub-Services *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(height: 6),
          const Text('Select all the sub-services you specialize in:', style: TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
          const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final cat = weddingCategoriesList.firstWhere(
                (c) => c.name == _selectedCategory,
                orElse: () => weddingCategoriesList.first,
              );
              return Wrap(
                spacing: 8, runSpacing: 8,
                children: cat.subServices.map((subService) {
                  final isSel = _selectedSubServices.contains(subService);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isSel) {
                          _selectedSubServices.remove(subService);
                        } else {
                          _selectedSubServices.add(subService);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? GomandapTokens.emeraldGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSel ? Colors.transparent : GomandapTokens.lightSlate,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSel ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                            size: 14,
                            color: isSel ? Colors.white : GomandapTokens.slateGray,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            subService,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel ? Colors.white : GomandapTokens.royalNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Description with real-time character gauge
        const Text('Business Description *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: TextField(
            controller: _descController,
            maxLines: 5,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy),
            decoration: InputDecoration(
              hintText: 'Share a rich story about your years of experience, sangeet expertise, decorator panels, and service guarantee...',
              hintStyle: TextStyle(color: GomandapTokens.slateGray.withValues(alpha: 0.7), fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _descController.text.length < 200
                  ? 'Requires at least 200 characters to ensure listing quality'
                  : 'Perfect! Description threshold met ✅',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _descController.text.length < 200 ? Colors.redAccent : GomandapTokens.emeraldGreen,
              ),
            ),
            Text(
              '${_descController.text.length} / 2000',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GomandapTokens.slateGray),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Step 2: Milestone Builder ───────────────────────────────────────────────

  Widget _buildMilestonesStep() {
    final cat = _selectedCategory?.toLowerCase() ?? '';
    final bool isVenue = cat.contains('hall') || cat.contains('mandapam') || cat.contains('lawn') || cat == 'venue';
    final bool isPhoto = cat.contains('photo') || cat.contains('camera');
    final bool isMakeup = cat.contains('makeup') || cat.contains('brush');
    final bool isCatering = cat.contains('cater');
    final bool isDecor = cat.contains('decor') || cat.contains('canopy');

    Widget categorySpecificFields;

    if (isVenue) {
      categorySpecificFields = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Veg Plate Price (₹) *',
                  controller: _vegPriceController,
                  hint: 'e.g. 1200',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Non-Veg Plate Price (₹) *',
                  controller: _nonVegPriceController,
                  hint: 'e.g. 1500',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Total Pax Capacity *',
                  controller: _capacityController,
                  hint: 'e.g. 800',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'AC Rooms Count *',
                  controller: _roomsController,
                  hint: 'e.g. 12',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (isPhoto) {
      categorySpecificFields = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Candid Photo Day-Rate (₹) *',
                  controller: _candidRateController,
                  hint: 'e.g. 50000',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Cinematography Day-Rate (₹) *',
                  controller: _videoRateController,
                  hint: 'e.g. 60000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Delivery Speed (Days) *',
                  controller: _deliveryDaysController,
                  hint: 'e.g. 45',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Primary Camera Brand *',
                  controller: _cameraBrandController,
                  hint: 'e.g. Sony, Canon, RED',
                ),
              ),
            ],
          ),
        ],
      );
    } else if (isCatering) {
      categorySpecificFields = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Veg Starting Plate (₹) *',
                  controller: _vegPriceController,
                  hint: 'e.g. 1000',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Non-Veg Starting Plate (₹) *',
                  controller: _nonVegPriceController,
                  hint: 'e.g. 1300',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Minimum Plates Order Booking *',
            controller: _capacityController,
            hint: 'e.g. 150',
            keyboardType: TextInputType.number,
          ),
        ],
      );
    } else if (isMakeup) {
      categorySpecificFields = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Bridal HD Pkg (₹) *',
                  controller: _makeupBridalController,
                  hint: 'e.g. 25000',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Guest Makeup / Pax (₹) *',
                  controller: _makeupFamilyController,
                  hint: 'e.g. 4000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Cosmetics Brand Tier *',
            controller: TextEditingController(text: _makeupBrand)
              ..addListener(() {
                _makeupBrand = _makeupBrand;
              }),
            hint: 'e.g. MAC, Huda Beauty, Chanel',
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Paid Trial Session Available *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
              Switch(
                value: _trialAvailable,
                activeColor: GomandapTokens.emeraldGreen,
                onChanged: (val) => setState(() => _trialAvailable = val),
              ),
            ],
          ),
        ],
      );
    } else if (isDecor) {
      categorySpecificFields = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Indoor Decor Base (₹) *',
                  controller: _decorIndoorController,
                  hint: 'e.g. 80000',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: 'Outdoor Stage Base (₹) *',
                  controller: _decorOutdoorController,
                  hint: 'e.g. 120000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Setup Time Speed (Hours) *',
            controller: _decorSetupHoursController,
            hint: 'e.g. 8',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          const Text('Floral Quality Grade *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: GomandapTokens.softMist,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GomandapTokens.lightSlate),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _floralGrade,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy),
                isExpanded: true,
                items: ['Premium Fresh Flowers', 'Artificial Silk Flowers', 'Mixed Fresh & Silk'].map((g) {
                  return DropdownMenuItem<String>(
                    value: g,
                    child: Text(g),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _floralGrade = val);
                },
              ),
            ),
          ),
        ],
      );
    } else {
      categorySpecificFields = _buildTextField(
        label: 'Package Base Starting Price (₹) *',
        controller: _basePriceController,
        hint: 'e.g. 15000',
        keyboardType: TextInputType.number,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 2: Dynamic Category Packages 💰', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        Text('Configure your pricing metrics specific to the selected category: $_selectedCategory.', style: const TextStyle(fontSize: 12, color: GomandapTokens.slateGray, height: 1.45)),
        const SizedBox(height: 24),

        categorySpecificFields,
        const SizedBox(height: 24),

        const Text('Cancellation Refund Policy *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 12),
        Row(
          children: ['Non-Refundable', '50% Refundable', 'Flexible'].map((policy) {
            final isSel = _refundPolicy == policy;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _refundPolicy = policy);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSel ? GomandapTokens.royalNavy : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSel ? Colors.transparent : GomandapTokens.lightSlate),
                  ),
                  child: Center(
                    child: Text(
                      policy,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isSel ? Colors.white : GomandapTokens.royalNavy,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        // Milestone Release Configurator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Configure Escrow Milestone Release', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
            Text(
              'Sum: ${(_milestone1 + _milestone2 + _milestone3).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: (_milestone1 + _milestone2 + _milestone3 == 100)
                    ? GomandapTokens.emeraldGreen
                    : Colors.redAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildMilestoneSlider('Milestone 1: Booking Advance Deposit', _milestone1, (val) {
          setState(() => _milestone1 = val);
        }),
        _buildMilestoneSlider('Milestone 2: Pre-Event Morning Hold', _milestone2, (val) {
          setState(() => _milestone2 = val);
        }),
        _buildMilestoneSlider('Milestone 3: Post-Event Verified Handover', _milestone3, (val) {
          setState(() => _milestone3 = val);
        }),
      ],
    );
  }

  Widget _buildMilestoneSlider(String label, double val, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
            Text('${val.toInt()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          ],
        ),
        Slider(
          min: 0, max: 100,
          value: val,
          activeColor: GomandapTokens.emeraldGreen,
          inactiveColor: GomandapTokens.softMist,
          onChanged: (newVal) {
            HapticFeedback.selectionClick();
            onChanged(newVal.roundToDouble());
          },
        ),
      ],
    );
  }

  // ─── Step 3: Immersive Portfolio Grid ───────────────────────────────────────

  Widget _buildPortfolioStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 3: Immersive Gallery 📸', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        const Text('Upload up to 12 high-resolution photos representing your wedding stages and planning venues.', style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray, height: 1.45)),
        const SizedBox(height: 24),

        // Grid portfolio list
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.0,
          ),
          itemCount: _mockImages.length + 1,
          itemBuilder: (context, idx) {
            if (idx == _mockImages.length) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (_mockImages.length >= 12) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Maximum portfolio upload limit of 12 reached!'), behavior: SnackBarBehavior.floating),
                    );
                    return;
                  }
                  // Simulate image upload addition with webp compress note
                  setState(() {
                    _mockImages.add('https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400');
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.bolt, color: GomandapTokens.champagneGoldEnd, size: 14),
                          SizedBox(width: 6),
                          Text('Auto-resized & compressed JPEG to WebP (510KB) successfully! 🚀'),
                        ],
                      ),
                      backgroundColor: GomandapTokens.royalNavy,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: GomandapTokens.softMist,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GomandapTokens.lightSlate, style: BorderStyle.solid),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded, color: GomandapTokens.royalNavy),
                        SizedBox(height: 4),
                        Text('Add Photo', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy)),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    _mockImages[idx],
                    fit: BoxFit.cover,
                    width: double.infinity, height: double.infinity,
                  ),
                ),
                // Delete button
                Positioned(
                  top: 4, right: 4,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _mockImages.removeAt(idx);
                      });
                    },
                    child: Container(
                      width: 22, height: 22,
                      decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, size: 12, color: Color(0xFFE11D48)),
                    ),
                  ),
                ),
                // Compression Tag Badge
                Positioned(
                  bottom: 4, left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: GomandapTokens.emeraldGreen.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('WEBP', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Total uploaded photos: ${_mockImages.length} / 12',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
        ),
      ],
    );
  }

  // ─── Step 4: 60s Video Intro ─────────────────────────────────────────────────

  Widget _buildVideoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 4: Video Introduction 🎥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        const Text('Upload a 60-second video overview demonstrating your facilities and sangeet setups. Progressive transcoding tags will be applied.', style: TextStyle(fontSize: 12, color: GomandapTokens.slateGray, height: 1.45)),
        const SizedBox(height: 28),

        // Video upload simulator container
        if (!_isVideoUploaded && !_isVideoUploading)
          GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              setState(() {
                _isVideoUploading = true;
                _videoProgress = 0.0;
              });

              // Simulate upload progress over 2s
              for (int i = 1; i <= 10; i++) {
                await Future.delayed(const Duration(milliseconds: 200));
                if (!mounted) return;
                setState(() {
                  _videoProgress = i * 0.1;
                });
              }

              setState(() {
                _isVideoUploading = false;
                _isVideoUploaded = true;
              });
            },
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GomandapTokens.lightSlate),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library_rounded, size: 40, color: GomandapTokens.royalNavy),
                    SizedBox(height: 8),
                    Text('Select Video Walkthrough', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                    SizedBox(height: 4),
                    Text('MP4, MOV supported · Max 60 seconds (50MB)', style: TextStyle(fontSize: 10, color: GomandapTokens.slateGray)),
                  ],
                ),
              ),
            ),
          )
        else if (_isVideoUploading)
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GomandapTokens.lightSlate),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(GomandapTokens.emeraldGreen)),
                const SizedBox(height: 16),
                Text(
                  'Uploading introduction video: ${(_videoProgress * 100).toInt()}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                ),
                const SizedBox(height: 8),
                const Text('Encoding to H.264 progressive format...', style: TextStyle(fontSize: 11, color: GomandapTokens.slateGray)),
              ],
            ),
          )
        else
          // Video preview card
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GomandapTokens.emeraldGreen),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Mock Video Static background
                  Image.network(
                    'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=600',
                    fit: BoxFit.cover,
                  ),

                  // Transcoding Complete Banner Tag
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: GomandapTokens.emeraldGreen.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, size: 10, color: Colors.white),
                          SizedBox(width: 4),
                          Text('TRANSCODED H.264 ✅', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),

                  // Play overlay simulation
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _isPlayingMockVideo = !_isPlayingMockVideo;
                        });
                      },
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                        child: Icon(
                          _isPlayingMockVideo ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 32,
                          color: GomandapTokens.royalNavy,
                        ),
                      ),
                    ),
                  ),

                  if (_isPlayingMockVideo)
                    Positioned(
                      bottom: 12, left: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Text('Simulating sangeet walk-through 0:14 / 0:60', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ─── Bottom Actions Bar ──────────────────────────────────────────────────────

  Widget _buildBottomActions() {
    final isFirst = _currentStep == 0;

    // Validators
    bool isNextDisabled = false;
    if (_currentStep == 0) {
      isNextDisabled = _nameController.text.isEmpty ||
          _localityController.text.isEmpty ||
          _selectedCategory == null ||
          _selectedSubServices.isEmpty ||
          _descController.text.length < 200;
    } else if (_currentStep == 1) {
      final double sum = _milestone1 + _milestone2 + _milestone3;
      final cat = _selectedCategory?.toLowerCase() ?? '';
      final bool isVenue = cat.contains('hall') || cat.contains('mandapam') || cat.contains('lawn') || cat == 'venue';
      final bool isPhoto = cat.contains('photo') || cat.contains('camera');
      final bool isMakeup = cat.contains('makeup') || cat.contains('brush');
      final bool isCatering = cat.contains('cater');
      final bool isDecor = cat.contains('decor') || cat.contains('canopy');

      bool categoryValid = true;
      if (isVenue) {
        categoryValid = _vegPriceController.text.isNotEmpty &&
            _nonVegPriceController.text.isNotEmpty &&
            _capacityController.text.isNotEmpty &&
            _roomsController.text.isNotEmpty;
      } else if (isPhoto) {
        categoryValid = _candidRateController.text.isNotEmpty &&
            _videoRateController.text.isNotEmpty &&
            _deliveryDaysController.text.isNotEmpty &&
            _cameraBrandController.text.isNotEmpty;
      } else if (isCatering) {
        categoryValid = _vegPriceController.text.isNotEmpty &&
            _nonVegPriceController.text.isNotEmpty &&
            _capacityController.text.isNotEmpty;
      } else if (isMakeup) {
        categoryValid = _makeupBridalController.text.isNotEmpty &&
            _makeupFamilyController.text.isNotEmpty &&
            _makeupBrand.isNotEmpty;
      } else if (isDecor) {
        categoryValid = _decorIndoorController.text.isNotEmpty &&
            _decorOutdoorController.text.isNotEmpty &&
            _decorSetupHoursController.text.isNotEmpty;
      } else {
        categoryValid = _basePriceController.text.isNotEmpty;
      }

      isNextDisabled = !categoryValid || sum != 100;
    } else if (_currentStep == 2) {
      isNextDisabled = _mockImages.isEmpty;
    } else if (_currentStep == 3) {
      isNextDisabled = !_isVideoUploaded;
    }

    final String continueText = _currentStep == 3 ? 'Launch Vendor Profile 🚀' : 'Continue';

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: GomandapTokens.lightSlate)),
      ),
      child: Row(
        children: [
          if (!isFirst)
            GestureDetector(
              onTap: _prevStep,
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: GomandapTokens.softMist,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GomandapTokens.lightSlate),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: GomandapTokens.royalNavy),
              ),
            ),
          if (!isFirst) const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: isNextDisabled
                  ? null
                  : () {
                      if (_currentStep == 3) {
                        _simulateCloudflareR2AndSupabaseSync();
                      } else {
                        _nextStep();
                      }
                    },
              child: AnimatedOpacity(
                opacity: isNextDisabled ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [GomandapTokens.emeraldGreen, GomandapTokens.emeraldGreenDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isNextDisabled
                        ? []
                        : [
                            BoxShadow(
                              color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                  ),
                  child: Center(
                    child: Text(
                      continueText,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateCloudflareR2AndSupabaseSync() {
    HapticFeedback.heavyImpact();

    final cat = _selectedCategory?.toLowerCase() ?? '';
    final bool isVenue = cat.contains('hall') || cat.contains('mandapam') || cat.contains('lawn') || cat == 'venue';
    final bool isPhoto = cat.contains('photo') || cat.contains('camera');
    final bool isMakeup = cat.contains('makeup') || cat.contains('brush');
    final bool isCatering = cat.contains('cater');
    final bool isDecor = cat.contains('decor') || cat.contains('canopy');

    Map<String, dynamic> categorySpecs = {};
    if (isVenue) {
      categorySpecs = {
        'vegPlatePrice': double.tryParse(_vegPriceController.text),
        'nonVegPlatePrice': double.tryParse(_nonVegPriceController.text),
        'guestCapacity': int.tryParse(_capacityController.text),
        'roomsAvailable': int.tryParse(_roomsController.text),
      };
    } else if (isPhoto) {
      categorySpecs = {
        'candidDayRate': double.tryParse(_candidRateController.text),
        'videoDayRate': double.tryParse(_videoRateController.text),
        'deliveryTimelineDays': int.tryParse(_deliveryDaysController.text),
        'equipmentBrand': _cameraBrandController.text,
      };
    } else if (isCatering) {
      categorySpecs = {
        'cateringVegPrice': double.tryParse(_vegPriceController.text),
        'cateringNonVegPrice': double.tryParse(_nonVegPriceController.text),
        'minPlatesBooking': int.tryParse(_capacityController.text),
      };
    } else if (isMakeup) {
      categorySpecs = {
        'bridalMakeupPrice': double.tryParse(_makeupBridalController.text),
        'familyMakeupPrice': double.tryParse(_makeupFamilyController.text),
        'makeupBrandTier': _makeupBrand,
        'trialSessionAvailable': _trialAvailable,
      };
    } else if (isDecor) {
      categorySpecs = {
        'indoorDecorPrice': double.tryParse(_decorIndoorController.text),
        'outdoorStagePrice': double.tryParse(_decorOutdoorController.text),
        'setupHours': int.tryParse(_decorSetupHoursController.text),
        'floralGrade': _floralGrade,
      };
    }

    final double price = isVenue || isCatering
        ? (double.tryParse(_vegPriceController.text) ?? 1200)
        : isPhoto
            ? (double.tryParse(_candidRateController.text) ?? 50000)
            : isMakeup
                ? (double.tryParse(_makeupBridalController.text) ?? 30000)
                : isDecor
                    ? (double.tryParse(_decorIndoorController.text) ?? 80000)
                    : (double.tryParse(_basePriceController.text) ?? 15000);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _UploadSyncDialog(
          selectedCategory: _selectedCategory ?? 'Elite Partner',
          specs: categorySpecs,
          imageCount: _mockImages.length,
          basePrice: price,
          onComplete: () {
            Navigator.pop(context); // Pop dialog
            _nextStep(); // Go to success page
          },
        );
      },
    );
  }

  // ─── Step 5: Success Celebration Screen ───────────────────────────────────────

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: GomandapTokens.royalNavy,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating Crown Gold Icon
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: GomandapTokens.champagneGoldStart, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.workspace_premium_rounded, size: 44, color: GomandapTokens.champagneGoldStart),
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Profile Launched Successfully! 👑',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your business page is now live and Escrow protected. Standard 2% platform transaction rate will be active.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 40),

            // Mock registration details card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  const _SuccessField(label: 'Registration Status', val: 'Active Verified ✅'),
                  const SizedBox(height: 10),
                  _SuccessField(label: 'Operating Category', val: _selectedCategory ?? 'Elite Partner'),
                  const SizedBox(height: 10),
                  _SuccessField(label: 'Linked Account ID', val: 'GMD-VEN-${1000 + _nameController.text.length * 37}-2026'),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // CTA Button
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.go('/home');
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [GomandapTokens.champagneGoldStart, GomandapTokens.champagneGoldEnd],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Go to Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: GomandapTokens.slateGray.withValues(alpha: 0.6), fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessField extends StatelessWidget {
  final String label;
  final String val;

  const _SuccessField({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600)),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _UploadSyncDialog extends StatefulWidget {
  final String selectedCategory;
  final Map<String, dynamic> specs;
  final int imageCount;
  final double basePrice;
  final VoidCallback onComplete;

  const _UploadSyncDialog({
    required this.selectedCategory,
    required this.specs,
    required this.imageCount,
    required this.basePrice,
    required this.onComplete,
  });

  @override
  State<_UploadSyncDialog> createState() => _UploadSyncDialogState();
}

class _UploadSyncDialogState extends State<_UploadSyncDialog> {
  int _currentStage = 0;
  final List<String> _stages = [
    'Compressing portfolio images to high-density WebP...',
    'Requesting presigned upload tokens from Supabase...',
    'Uploading compressed media to Cloudflare R2 bucket...',
    'Transcoding H.264 video intro segments...',
    'Syncing dynamic category_specs to Supabase JSONB record...',
    'Initializing Milestone Escrow release locks...'
  ];

  @override
  void initState() {
    super.initState();
    _runSyncPipeline();
  }

  Future<void> _runSyncPipeline() async {
    for (int i = 0; i < _stages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _currentStage = i + 1;
      });
      HapticFeedback.lightImpact();
    }
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GomandapTokens.royalNavy,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(GomandapTokens.champagneGoldStart),
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Syncing Supabase & Cloudflare R2',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Publishing ${widget.selectedCategory} listing with escrow locks.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: List.generate(_stages.length, (idx) {
                final isCompleted = idx < _currentStage;
                final isActive = idx == _currentStage;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? GomandapTokens.emeraldGreen
                              : isActive
                                  ? GomandapTokens.champagneGoldStart
                                  : Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.done_rounded, size: 10, color: Colors.white)
                              : Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: isActive ? Colors.white : Colors.white60,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _stages[idx],
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isCompleted || isActive ? FontWeight.w800 : FontWeight.w500,
                            color: isCompleted
                                ? GomandapTokens.emeraldGreen
                                : isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
