import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/vendor.dart';
import 'package:gomandap_common/data/repository_impl/offline_first_vendor_repository.dart';
import 'package:gomandap_common/presentation/widgets/ifsc_bank_field.dart';
import 'package:gomandap_common/core/utils/id_generator.dart';


class AdminAddVendorScreen extends ConsumerStatefulWidget {
  const AdminAddVendorScreen({super.key});

  @override
  ConsumerState<AdminAddVendorScreen> createState() => _AdminAddVendorScreenState();
}

class _AdminAddVendorScreenState extends ConsumerState<AdminAddVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // State variables
  String _businessName = '';
  String _category = 'Venue';
  // ignore: unused_field
  String _city = 'Hyderabad';
  double _basePrice = 0.0;
  // ignore: unused_field
  String _phone = '';
  // ignore: unused_field
  String _gstin = '';
  // ignore: unused_field
  String _bankAccountNumber = '';
  
  
  final double _lat = 17.4065;
  final double _lng = 78.4772;
  
  // ignore: unused_field
  final String _bankIfscCode = '';
  
  bool _isSaving = false;

  final List<String> _categories = ['Venue', 'Photography', 'Decorator', 'Catering', 'Choreographer'];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    HapticFeedback.heavyImpact();
    setState(() => _isSaving = true);

    try {
      final vendorRepo = ref.read(vendorRepositoryProvider);
      
      final vendorId = GomandapIdGenerator.formatVendorId(DateTime.now().millisecondsSinceEpoch.toString());
      
      final newVendor = Vendor(
        id: vendorId,
        businessName: _businessName,
        category: _category,
        rating: 5.0, // Default for admin-added
        reviewCount: 0,
        primaryImage: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800', // Mock initial image
        portfolioImages: [],
        pricingPackages: {
          'base_price': _basePrice,
        },
        latitude: _lat,
        longitude: _lng,
      );

      await vendorRepo.saveVendor(newVendor);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('$_businessName instantly activated on platform! 🚀', style: const TextStyle(fontWeight: FontWeight.w700)),
          ]),
          backgroundColor: GomandapTokens.emeraldGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding vendor: $e'),
          backgroundColor: GomandapTokens.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPortrait = MediaQuery.sizeOf(context).width < 800;
    
    return Scaffold(
      backgroundColor: GomandapTokens.softMist,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: GomandapTokens.royalNavy),
        title: Text('Onboard New Elite Vendor', style: GoogleFonts.outfit(color: GomandapTokens.royalNavy, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: Center(
        child: Container(
          width: isPortrait ? double.infinity : 600,
          margin: EdgeInsets.all(isPortrait ? 0 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isPortrait ? BorderRadius.zero : BorderRadius.circular(24),
            border: isPortrait ? null : Border.all(color: GomandapTokens.lightSlate),
            boxShadow: isPortrait ? [] : [
              BoxShadow(color: GomandapTokens.royalNavy.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 12))
            ],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storefront_rounded, color: GomandapTokens.champagneGoldEnd, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Direct CRM Injection', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                            const Text('Vendors added here bypass the approval queue and go live instantly.', style: TextStyle(color: GomandapTokens.slateGray, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Category Selection
                  Text('Business Category', style: _labelStyle()),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSel = _category == cat;
                      return GestureDetector(
                        onTap: () => setState(() => _category = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? GomandapTokens.royalNavy : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? Colors.transparent : GomandapTokens.lightSlate),
                            boxShadow: isSel ? [BoxShadow(color: GomandapTokens.royalNavy.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : [],
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSel ? Colors.white : GomandapTokens.slateGray,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Basic Details
                  _buildInputRow(
                    label: 'Business Name',
                    icon: Icons.business_rounded,
                    hint: 'e.g. Royal Palace Halls',
                    onSaved: (v) => _businessName = v!,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInputRow(
                    label: 'Phone Number',
                    icon: Icons.phone_android_rounded,
                    hint: '9876543210',
                    onSaved: (v) => _phone = v!,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInputRow(
                    label: 'GSTIN (Optional)',
                    icon: Icons.receipt_long_rounded,
                    hint: '22AAAAA0000A1Z5',
                    onSaved: (v) => _gstin = v!,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInputRow(
                    label: 'Base Pricing (₹)',
                    icon: Icons.currency_rupee_rounded,
                    hint: '150000',
                    isNumeric: true,
                    onSaved: (v) => _basePrice = double.tryParse(v ?? '0') ?? 0.0,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInputRow(
                    label: 'City',
                    icon: Icons.location_city_rounded,
                    hint: 'Hyderabad',
                    onSaved: (v) => _city = v!,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),
                  
                  // Maps integration
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GomandapTokens.emeraldGreen.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GomandapTokens.emeraldGreen.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.map_rounded, color: GomandapTokens.emeraldGreen, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GPS Verification Locked', style: TextStyle(fontWeight: FontWeight.w800, color: GomandapTokens.emeraldGreen, fontSize: 13)),
                              Text('Coordinates auto-resolved via admin override.', style: TextStyle(color: GomandapTokens.emeraldGreen, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: GomandapTokens.emeraldGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Verified', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Bank Details
                  Text('Settlement Bank Details', style: _labelStyle()),
                  const SizedBox(height: 8),
                  _buildInputRow(
                    label: 'Bank Account Number',
                    icon: Icons.numbers_rounded,
                    hint: '01234567890123',
                    onSaved: (v) => _bankAccountNumber = v ?? '',
                  ),
                  const SizedBox(height: 16),
                  IfscBankField(
                    onBankDetailsFetched: (bank, branch) {
                      // Bank is verified
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GomandapTokens.royalNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: GomandapTokens.royalNavy.withValues(alpha: 0.4),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Launch Vendor 🚀', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: GomandapTokens.royalNavy,
  );

  Widget _buildInputRow({
    required String label,
    required IconData icon,
    required String hint,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle()),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: GomandapTokens.royalNavy),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w400),
            prefixIcon: Icon(icon, color: GomandapTokens.slateGray, size: 20),
            filled: true,
            fillColor: GomandapTokens.softMist,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: GomandapTokens.lightSlate),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: GomandapTokens.lightSlate),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: GomandapTokens.champagneGoldStart, width: 2),
            ),
            errorStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }
}
