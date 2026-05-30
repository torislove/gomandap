import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_button.dart';
import 'package:gomandap_common/domain/models/vendor_application.dart';
import 'package:gomandap_common/data/repository_impl/vendor_application_repository.dart';
import 'package:gomandap_common/core/storage/r2_upload_service.dart';

class VendorKycScreen extends ConsumerStatefulWidget {
  const VendorKycScreen({super.key});

  @override
  ConsumerState<VendorKycScreen> createState() => _VendorKycScreenState();
}

class _VendorKycScreenState extends ConsumerState<VendorKycScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  String? _kycDocUrl;

  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();
  
  final List<String> _selectedCategories = [];

  final List<String> _availableCategories = [
    'Banquet', 'Photography', 'Decor', 'Makeup', 'Catering'
  ];

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _gstinCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitKyc();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitKyc() async {
    setState(() => _isSubmitting = true);
    
    final repo = ref.read(vendorApplicationRepositoryProvider);
    
    final app = VendorApplication(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Mock ID
      businessName: _businessNameCtrl.text,
      ownerName: _ownerNameCtrl.text,
      phone: _phoneCtrl.text,
      city: _cityCtrl.text,
      categories: _selectedCategories,
      status: VendorAppStatus.pending,
      submittedAt: DateTime.now(),
      gstin: _gstinCtrl.text,
      priceMin: 10000,
      priceMax: 50000,
      portfolioUrls: const [],
      kycDocUrl: _kycDocUrl ?? 'https://images.unsplash.com/photo-1568602471122-7832951cc4c5',
      correctionNotes: const [],
    );

    await repo.submitApplication(app);
    
    ref.read(vendorPhoneProvider.notifier).setPhone(_phoneCtrl.text);
    
    setState(() => _isSubmitting = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KYC Submitted! Awaiting Admin Approval.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      appBar: AppBar(
        title: const Text('Vendor Onboarding', style: TextStyle(color: GomandapTokens.royalNavy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: GomandapTokens.royalNavy),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GomandapTokens.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: GomandapTokens.lightSlate,
                color: GomandapTokens.emeraldGreen,
              ),
              const SizedBox(height: GomandapTokens.spacingLg),
              
              Expanded(
                child: SingleChildScrollView(
                  child: _buildCurrentStep(),
                ),
              ),
              
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: GomandapButton(
                        label: 'Back',
                        isPrimary: false,
                        onPressed: _prevStep,
                      ),
                    ),
                  if (_currentStep > 0)
                    const SizedBox(width: GomandapTokens.spacingMd),
                  Expanded(
                    flex: 2,
                    child: GomandapButton(
                      label: _currentStep == 2 ? 'Submit KYC' : 'Next',
                      isLoading: _isSubmitting,
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Business Details', style: GomandapTokens.outfitHeader),
        const SizedBox(height: GomandapTokens.spacingMd),
        _buildTextField(_businessNameCtrl, 'Business Name'),
        const SizedBox(height: GomandapTokens.spacingMd),
        _buildTextField(_ownerNameCtrl, 'Owner Name'),
        const SizedBox(height: GomandapTokens.spacingMd),
        _buildTextField(_phoneCtrl, 'Phone Number', isPhone: true),
        const SizedBox(height: GomandapTokens.spacingMd),
        _buildTextField(_cityCtrl, 'City'),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories & Services', style: GomandapTokens.outfitHeader),
        const SizedBox(height: GomandapTokens.spacingMd),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _availableCategories.map((cat) {
            final isSelected = _selectedCategories.contains(cat);
            return ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: GomandapTokens.champagneGoldStart,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(cat);
                  } else {
                    _selectedCategories.remove(cat);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Legal & KYC', style: GomandapTokens.outfitHeader),
        const SizedBox(height: GomandapTokens.spacingMd),
        _buildTextField(_gstinCtrl, 'GSTIN Number (Optional)'),
        const SizedBox(height: GomandapTokens.spacingLg),
        Container(
          padding: const EdgeInsets.all(GomandapTokens.spacingMd),
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: Row(
            children: [
              const Icon(Icons.upload_file, color: GomandapTokens.royalNavy),
              const SizedBox(width: GomandapTokens.spacingMd),
              Expanded(
                child: Text(
                  _kycDocUrl != null
                      ? 'Document successfully uploaded! ✓\n(${_kycDocUrl!.substring(0, math.min(25, _kycDocUrl!.length))}...)'
                      : 'Upload Trade License / ID Proof\n(PDF, JPG, PNG)',
                  style: GomandapTokens.interBody.copyWith(
                    color: _kycDocUrl != null ? GomandapTokens.emeraldGreen : GomandapTokens.royalNavy,
                  ),
                ),
              ),
              GomandapButton(
                label: _kycDocUrl != null ? 'Re-upload' : 'Browse',
                isPrimary: false,
                onPressed: () async {
                  final service = ref.read(r2UploadServiceProvider);
                  if (!service.isConfigured) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cloudflare R2 credentials missing. Launch with --dart-define options to enable R2 document validation.'),
                        backgroundColor: GomandapTokens.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  setState(() => _isSubmitting = true);
                  try {
                    final uploadUrl = await service.uploadBytes(
                      vendorId: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : 'onboarding',
                      field: 'kyc_document',
                      bytes: Uint8List.fromList([1, 2, 3]),
                      ext: 'jpg',
                    );
                    setState(() {
                      _kycDocUrl = uploadUrl;
                    });
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('R2 upload failed: $e'),
                        backgroundColor: GomandapTokens.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } finally {
                    setState(() => _isSubmitting = false);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, {bool isPhone = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
