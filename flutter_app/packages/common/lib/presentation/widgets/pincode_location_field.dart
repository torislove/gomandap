import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/pincode_service.dart';
import '../../theme/gomandap_tokens.dart';

class PincodeLocationField extends StatefulWidget {
  final Function(String village, String district, String state) onLocationSelected;

  const PincodeLocationField({super.key, required this.onLocationSelected});

  @override
  State<PincodeLocationField> createState() => _PincodeLocationFieldState();
}

class _PincodeLocationFieldState extends State<PincodeLocationField> {
  final TextEditingController _pincodeController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMsg;
  List<PincodeLocationData> _fetchedLocations = [];
  
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedVillage;

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchPincodeData(String pincode) async {
    if (pincode.length != 6) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _fetchedLocations.clear();
      _selectedState = null;
      _selectedDistrict = null;
      _selectedVillage = null;
    });

    final locations = await PincodeService.fetchByPincode(pincode);

    if (mounted) {
      if (locations.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Invalid PIN or service unavailable';
        });
      } else {
        HapticFeedback.lightImpact();
        setState(() {
          _isLoading = false;
          _fetchedLocations = locations;
          _selectedState = locations.first.state;
          _selectedDistrict = locations.first.district;
          
          // Auto-select if only 1 village
          if (locations.length == 1) {
            _selectedVillage = locations.first.village;
            _notifyParent();
          }
        });
      }
    }
  }

  void _notifyParent() {
    if (_selectedVillage != null && _selectedDistrict != null && _selectedState != null) {
      widget.onLocationSelected(_selectedVillage!, _selectedDistrict!, _selectedState!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PIN CODE INPUT
        const Text('Postal PIN Code', style: TextStyle(fontWeight: FontWeight.w700, color: GomandapTokens.slateGray, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: TextField(
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (val) {
              if (val.length == 6) {
                FocusScope.of(context).unfocus(); // hide keyboard
                _fetchPincodeData(val);
              }
            },
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Enter 6-digit PIN',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: _isLoading 
                ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: GomandapTokens.emeraldGreen)))
                : null,
            ),
          ),
        ),
        if (_errorMsg != null) ...[
          const SizedBox(height: 4),
          Text(_errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        ],

        // AUTO-FILLED DATA OR DROPDOWN
        if (_fetchedLocations.isNotEmpty) ...[
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildReadOnlyField('State', _selectedState ?? ''),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReadOnlyField('District', _selectedDistrict ?? ''),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          const Text('Select Village/Locality', style: TextStyle(fontWeight: FontWeight.w700, color: GomandapTokens.slateGray, fontSize: 13)),
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: GomandapTokens.softMist,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GomandapTokens.emeraldGreen.withValues(alpha: 0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedVillage,
                hint: const Text('Choose your specific area'),
                items: _fetchedLocations.map((loc) {
                  return DropdownMenuItem<String>(
                    value: loc.village,
                    child: Text(loc.village, style: const TextStyle(fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedVillage = val;
                  });
                  _notifyParent();
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, color: GomandapTokens.slateGray, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: GomandapTokens.lightSlate.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: GomandapTokens.slateGray)),
        ),
      ],
    );
  }
}
