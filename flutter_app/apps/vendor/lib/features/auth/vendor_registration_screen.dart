import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/vendor_application.dart';
import 'package:gomandap_common/domain/models/category_model.dart';
import 'package:gomandap_common/data/repository_impl/vendor_application_repository.dart';
import 'package:gomandap_common/core/storage/r2_upload_service.dart';

// ─── Step draft state (held in local state for the wizard) ────────────────────
class _WizardDraft {
  String businessName = '';
  String ownerName = '';
  String city = '';
  String businessType = '';
  int yearsActive = 1;
  String gstin = '';
  String pan = '';
  String? kycDocUrl;
  List<String> selectedCategories = [];
  double priceMin = 10000;
  double priceMax = 200000;
  String description = '';
  List<String> portfolioUrls = [];
  String phone = '';
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class VendorRegistrationScreen extends ConsumerStatefulWidget {
  final String prefillPhone;
  const VendorRegistrationScreen({super.key, this.prefillPhone = ''});

  @override
  ConsumerState<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState
    extends ConsumerState<VendorRegistrationScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentStep = 0;
  bool _submitted = false;
  bool _isLoading = false;
  String _loadingMsg = '';

  final _draft = _WizardDraft();

  // Step 1 controllers
  final _bizNameCtrl   = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _cityCtrl      = TextEditingController();

  // Step 2 controllers
  final _gstinCtrl = TextEditingController();
  final _panCtrl   = TextEditingController();

  // Step 3 controllers
  final _descCtrl = TextEditingController();

  late AnimationController _successCtrl;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _draft.phone = widget.prefillPhone;
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _successScale = CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _bizNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _cityCtrl.dispose();
    _gstinCtrl.dispose();
    _panCtrl.dispose();
    _descCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  // ─── Navigation ─────────────────────────────────────────────────────────────

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  // ─── R2 Upload ──────────────────────────────────────────────────────────────

  Future<void> _uploadKycDoc() async {
    // In a real app, use file_picker to get bytes. Here we simulate.
    setState(() {
      _isLoading = true;
      _loadingMsg = 'Uploading KYC document to secure vault…';
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    final service = ref.read(r2UploadServiceProvider);
    final mockBytes = Uint8List.fromList(List.filled(100, 0));
    final url = await service.uploadBytes(
      vendorId: _draft.phone.isEmpty ? 'unknown' : _draft.phone,
      field:    'kyc_doc',
      bytes:    mockBytes,
      ext:      'pdf',
      mimeType: 'application/pdf',
    );
    setState(() {
      _draft.kycDocUrl = url;
      _isLoading = false;
    });
  }

  Future<void> _uploadPortfolioPhoto(int index) async {
    setState(() {
      _isLoading = true;
      _loadingMsg = 'Uploading photo ${index + 1} to portfolio vault…';
    });
    await Future.delayed(const Duration(milliseconds: 900));
    final service = ref.read(r2UploadServiceProvider);
    final mockBytes = Uint8List.fromList(List.filled(100, 0));
    final url = await service.uploadBytes(
      vendorId: _draft.phone.isEmpty ? 'unknown' : _draft.phone,
      field:    'portfolio_$index',
      bytes:    mockBytes,
      ext:      'jpg',
      mimeType: 'image/jpeg',
    );
    setState(() {
      if (index < _draft.portfolioUrls.length) {
        _draft.portfolioUrls[index] = url;
      } else {
        _draft.portfolioUrls.add(url);
      }
      _isLoading = false;
    });
  }

  // ─── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submitApplication() async {
    setState(() {
      _isLoading = true;
      _loadingMsg = 'Submitting your application to GoMandap…';
    });

    final application = VendorApplication(
      id: '',
      businessName: _draft.businessName,
      ownerName: _draft.ownerName,
      phone: _draft.phone,
      city: _draft.city,
      categories: _draft.selectedCategories.isEmpty
          ? [_draft.businessType]
          : _draft.selectedCategories,
      gstin: _draft.gstin.isEmpty ? null : _draft.gstin,
      description: _draft.description.isEmpty ? null : _draft.description,
      kycDocUrl: _draft.kycDocUrl,
      portfolioUrls: _draft.portfolioUrls,
      priceMin: _draft.priceMin.toInt(),
      priceMax: _draft.priceMax.toInt(),
      submittedAt: DateTime.now(),
    );

    try {
      final repo = ref.read(vendorApplicationRepositoryProvider);
      await repo.submitApplication(application);

      // Store phone in state for banner tracking
      ref.read(vendorPhoneProvider.notifier).state = _draft.phone;

      setState(() {
        _isLoading = false;
        _submitted = true;
      });
      _successCtrl.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Submission failed: $e'),
        backgroundColor: GomandapTokens.error,
      ));
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GomandapTokens.royalNavy,
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(child: _buildBackground()),

          // Content
          SafeArea(
            child: _submitted ? _buildSuccessScreen() : _buildWizard(),
          ),

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: GomandapTokens.champagneGoldStart,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _loadingMsg,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // ─── Wizard Shell ────────────────────────────────────────────────────────────

  Widget _buildWizard() {
    return Column(
      children: [
        _buildWizardHeader(),
        _buildStepIndicator(),
        Expanded(
          child: PageView(
            controller: _pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
              _buildStep4(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWizardHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _currentStep == 0
                ? () => Navigator.of(context).pop()
                : _prevStep,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white70, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Partner Registration',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of 4',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: GomandapTokens.goldLeafGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded,
                    size: 12, color: GomandapTokens.royalNavy),
                const SizedBox(width: 5),
                Text(
                  'GoMandap',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: GomandapTokens.royalNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final labels = ['Identity', 'KYC', 'Services', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(4, (i) {
          final isDone = i < _currentStep;
          final isActive = i == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 3,
                        decoration: BoxDecoration(
                          color: isDone || isActive
                              ? GomandapTokens.champagneGoldStart
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[i],
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: isActive
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isActive
                              ? GomandapTokens.champagneGoldStart
                              : isDone
                                  ? Colors.white54
                                  : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 3) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Step 1: Business Identity ───────────────────────────────────────────────

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _sectionCard(
            title: 'Business Identity',
            subtitle: 'Tell us about your business',
            icon: Icons.business_rounded,
            children: [
              _inputField(
                controller: _bizNameCtrl,
                label: 'Business / Brand Name *',
                hint: 'e.g. Royal Floral Artistry',
                icon: Icons.storefront_rounded,
                onChanged: (v) => _draft.businessName = v,
              ),
              const SizedBox(height: 14),
              _inputField(
                controller: _ownerNameCtrl,
                label: 'Owner / Contact Name *',
                hint: 'e.g. Manoj Kumar',
                icon: Icons.person_rounded,
                onChanged: (v) => _draft.ownerName = v,
              ),
              const SizedBox(height: 14),
              _inputField(
                controller: _cityCtrl,
                label: 'City *',
                hint: 'e.g. Hyderabad',
                icon: Icons.location_city_rounded,
                onChanged: (v) => _draft.city = v,
              ),
              const SizedBox(height: 14),
              _dropdownField(
                label: 'Primary Business Type *',
                value: _draft.businessType.isEmpty ? null : _draft.businessType,
                items: weddingCategoriesList.map((c) => c.name).toList(),
                onChanged: (v) => setState(() => _draft.businessType = v ?? ''),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Years in Business',
                      style: _labelStyle()),
                  Row(
                    children: [
                      _iconBtn(Icons.remove_rounded, () {
                        if (_draft.yearsActive > 1) {
                          setState(() => _draft.yearsActive--);
                        }
                      }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '${_draft.yearsActive}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: GomandapTokens.champagneGoldStart,
                          ),
                        ),
                      ),
                      _iconBtn(Icons.add_rounded, () {
                        setState(() => _draft.yearsActive++);
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ctaButton(
            label: 'Continue to KYC →',
            enabled: _draft.businessName.isNotEmpty &&
                _draft.ownerName.isNotEmpty &&
                _draft.city.isNotEmpty,
            onTap: _nextStep,
          ),
        ],
      ),
    );
  }

  // ─── Step 2: KYC & Documents ─────────────────────────────────────────────────

  Widget _buildStep2() {
    final isGstinValid = _isValidGstin(_draft.gstin) || _draft.gstin.isEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _sectionCard(
            title: 'KYC & Verification',
            subtitle: 'Secure your partner identity',
            icon: Icons.verified_user_rounded,
            accentColor: GomandapTokens.emeraldGreen,
            children: [
              _inputField(
                controller: _gstinCtrl,
                label: 'GSTIN Number',
                hint: '27AAPFU0939F1ZV',
                icon: Icons.receipt_long_rounded,
                onChanged: (v) => setState(() => _draft.gstin = v.toUpperCase()),
                errorText: _draft.gstin.isNotEmpty && !isGstinValid
                    ? 'Invalid GSTIN format'
                    : null,
              ),
              if (_draft.gstin.isNotEmpty && isGstinValid)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 14, color: GomandapTokens.emeraldGreen),
                      const SizedBox(width: 5),
                      Text('Valid GSTIN format',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: GomandapTokens.emeraldGreen,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              _inputField(
                controller: _panCtrl,
                label: 'PAN / Aadhaar Number',
                hint: 'ABCDE1234F or 1234 5678 9012',
                icon: Icons.credit_card_rounded,
                onChanged: (v) => _draft.pan = v,
              ),
              const SizedBox(height: 18),
              // KYC Document Upload
              GestureDetector(
                onTap: _uploadKycDoc,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _draft.kycDocUrl != null
                          ? GomandapTokens.emeraldGreen.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.12),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (_draft.kycDocUrl != null
                                  ? GomandapTokens.emeraldGreen
                                  : GomandapTokens.champagneGoldStart)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _draft.kycDocUrl != null
                              ? Icons.check_circle_rounded
                              : Icons.upload_file_rounded,
                          color: _draft.kycDocUrl != null
                              ? GomandapTokens.emeraldGreen
                              : GomandapTokens.champagneGoldStart,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _draft.kycDocUrl != null
                                  ? 'KYC Document Uploaded ✓'
                                  : 'Upload KYC Document',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _draft.kycDocUrl != null
                                    ? GomandapTokens.emeraldGreen
                                    : Colors.white,
                              ),
                            ),
                            Text(
                              'GST certificate, Shop Act, or Business Proof (PDF/JPG)',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ctaButton(
            label: 'Continue to Services →',
            enabled: true, // KYC is optional for now
            onTap: _nextStep,
          ),
        ],
      ),
    );
  }

  // ─── Step 3: Services & Pricing ──────────────────────────────────────────────

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _sectionCard(
            title: 'Services & Pricing',
            subtitle: 'Define your offerings',
            icon: Icons.local_offer_rounded,
            accentColor: GomandapTokens.champagneGoldStart,
            children: [
              // Category multi-select chips
              Text('Service Categories *', style: _labelStyle()),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: weddingCategoriesList.map((cat) {
                  final selected =
                      _draft.selectedCategories.contains(cat.name);
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (selected) {
                          _draft.selectedCategories.remove(cat.name);
                        } else {
                          _draft.selectedCategories.add(cat.name);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? GomandapTokens.champagneGoldStart
                                .withValues(alpha: 0.18)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? GomandapTokens.champagneGoldStart
                                  .withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selected)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 12,
                                color: GomandapTokens.champagneGoldStart,
                              ),
                            ),
                          Icon(cat.fallbackIcon,
                              size: 13,
                              color: selected
                                  ? GomandapTokens.champagneGoldStart
                                  : Colors.white54),
                          const SizedBox(width: 5),
                          Text(
                            cat.name,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: selected
                                  ? GomandapTokens.champagneGoldStart
                                  : Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Price Range Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Price Range', style: _labelStyle()),
                  Text(
                    '₹${_formatPrice(_draft.priceMin)} — ₹${_formatPrice(_draft.priceMax)}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: GomandapTokens.champagneGoldStart,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RangeSlider(
                min: 5000,
                max: 5000000,
                values: RangeValues(_draft.priceMin, _draft.priceMax),
                activeColor: GomandapTokens.champagneGoldStart,
                inactiveColor: Colors.white.withValues(alpha: 0.1),
                onChanged: (v) {
                  setState(() {
                    _draft.priceMin = v.start;
                    _draft.priceMax = v.end;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Description
              Text('Service Description', style: _labelStyle()),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  onChanged: (v) => _draft.description = v,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13, height: 1.5),
                  decoration: InputDecoration(
                    hintText:
                        'Describe your services, specialties, and unique offerings…',
                    hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Portfolio Upload Grid
              Text('Portfolio Photos (up to 6)', style: _labelStyle()),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 6,
                itemBuilder: (_, i) {
                  final hasPhoto = i < _draft.portfolioUrls.length;
                  return GestureDetector(
                    onTap: () => _uploadPortfolioPhoto(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: hasPhoto
                            ? GomandapTokens.emeraldGreen
                                .withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasPhoto
                              ? GomandapTokens.emeraldGreen
                                  .withValues(alpha: 0.4)
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasPhoto
                                ? Icons.check_circle_rounded
                                : Icons.add_photo_alternate_rounded,
                            color: hasPhoto
                                ? GomandapTokens.emeraldGreen
                                : Colors.white30,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasPhoto ? 'Uploaded' : 'Photo ${i + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              color: hasPhoto
                                  ? GomandapTokens.emeraldGreen
                                  : Colors.white30,
                              fontWeight: FontWeight.w700,
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
          const SizedBox(height: 20),
          _ctaButton(
            label: 'Review Application →',
            enabled: _draft.selectedCategories.isNotEmpty ||
                _draft.businessType.isNotEmpty,
            onTap: _nextStep,
          ),
        ],
      ),
    );
  }

  // ─── Step 4: Review & Submit ─────────────────────────────────────────────────

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GomandapTokens.champagneGoldStart.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded,
                        color: GomandapTokens.champagneGoldStart, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Application Summary',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _summaryRow('Business', _draft.businessName),
                _summaryRow('Owner', _draft.ownerName),
                _summaryRow('City', _draft.city),
                _summaryRow('Type', _draft.businessType),
                if (_draft.gstin.isNotEmpty)
                  _summaryRow('GSTIN', _draft.gstin),
                _summaryRow(
                  'Categories',
                  _draft.selectedCategories.isEmpty
                      ? _draft.businessType
                      : _draft.selectedCategories.join(', '),
                ),
                _summaryRow(
                  'Price Range',
                  '₹${_formatPrice(_draft.priceMin)} — ₹${_formatPrice(_draft.priceMax)}',
                ),
                _summaryRow(
                  'Portfolio',
                  '${_draft.portfolioUrls.length} photos uploaded',
                ),
                _summaryRow(
                  'KYC',
                  _draft.kycDocUrl != null ? 'Uploaded ✓' : 'Not uploaded',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Escrow Protection notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GomandapTokens.emeraldGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: GomandapTokens.emeraldGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_rounded,
                    color: GomandapTokens.emeraldGreen, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All bookings through GoMandap are Escrow Protected. '
                    'Your payouts are released only after event confirmation.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white60,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ctaButton(
            label: 'Submit for Verification 🚀',
            enabled: true,
            onTap: _submitApplication,
            isGold: true,
          ),
        ],
      ),
    );
  }

  // ─── Success Screen ──────────────────────────────────────────────────────────

  Widget _buildSuccessScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _successScale,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: GomandapTokens.goldLeafGradient,
                  boxShadow: [
                    BoxShadow(
                      color: GomandapTokens.champagneGoldStart
                          .withValues(alpha: 0.5),
                      blurRadius: 32,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.verified_rounded,
                    color: GomandapTokens.royalNavy, size: 52),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Application Submitted! 🎉',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to the GoMandap Partner Network.\n'
              'Our team will review your application within 24 hours.\n'
              "You'll receive a notification once verified.",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _ctaButton(
              label: 'Back to Login →',
              enabled: true,
              onTap: () => Navigator.of(context)
                  .popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper Widgets ──────────────────────────────────────────────────────────

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Color accentColor = GomandapTokens.champagneGoldStart,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      )),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? GomandapTokens.error.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(icon,
                    color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.8),
                    size: 16),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 12),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 4),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(errorText,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: GomandapTokens.error,
                    fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text('Select category',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 12)),
              dropdownColor: GomandapTokens.royalNavyLight,
              isExpanded: true,
              iconEnabledColor: GomandapTokens.champagneGoldStart,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              items: items
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(s)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _ctaButton({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool isGold = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: enabled
              ? (isGold
                  ? GomandapTokens.goldLeafGradient
                  : LinearGradient(
                      colors: [
                        GomandapTokens.champagneGoldStart
                            .withValues(alpha: 0.9),
                        GomandapTokens.champagneGoldEnd,
                      ],
                    ))
              : LinearGradient(colors: [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.04),
                ]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: GomandapTokens.champagneGoldStart
                        .withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: enabled
                  ? GomandapTokens.royalNavy
                  : Colors.white.withValues(alpha: 0.25),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.4),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: GomandapTokens.champagneGoldStart, size: 16),
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.9),
      );

  String _formatPrice(double val) {
    if (val >= 100000) {
      return '${(val / 100000).toStringAsFixed(1)}L';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(0)}K';
    }
    return val.toStringAsFixed(0);
  }

  bool _isValidGstin(String s) {
    final regex = RegExp(
        r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d{1}[A-Z]{1}\d{1}$');
    return regex.hasMatch(s);
  }
}
