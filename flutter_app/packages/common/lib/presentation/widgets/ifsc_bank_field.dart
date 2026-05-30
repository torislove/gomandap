import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/ifsc_service.dart';
import '../../theme/gomandap_tokens.dart';

class IfscBankField extends StatefulWidget {
  final Function(String bank, String branch) onBankDetailsFetched;

  const IfscBankField({super.key, required this.onBankDetailsFetched});

  @override
  State<IfscBankField> createState() => _IfscBankFieldState();
}

class _IfscBankFieldState extends State<IfscBankField> {
  final TextEditingController _ifscController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMsg;
  IfscData? _bankData;

  @override
  void dispose() {
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _fetchIfscData(String ifsc) async {
    if (ifsc.length != 11) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _bankData = null;
    });

    final data = await IfscService.fetchByIfsc(ifsc.toUpperCase());

    if (mounted) {
      if (data == null) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Invalid IFSC Code or service unavailable. Please check again.';
        });
      } else {
        HapticFeedback.lightImpact();
        setState(() {
          _isLoading = false;
          _bankData = data;
        });
        widget.onBankDetailsFetched(data.bank, data.branch);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IFSC INPUT
        const Text('Bank IFSC Code', style: TextStyle(fontWeight: FontWeight.w700, color: GomandapTokens.slateGray, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: GomandapTokens.softMist,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GomandapTokens.lightSlate),
          ),
          child: TextField(
            controller: _ifscController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 11,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
            ],
            onChanged: (val) {
              if (val.length == 11) {
                FocusScope.of(context).unfocus(); // hide keyboard
                _fetchIfscData(val);
              } else if (_bankData != null || _errorMsg != null) {
                setState(() {
                  _bankData = null;
                  _errorMsg = null;
                });
              }
            },
            decoration: InputDecoration(
              counterText: '',
              hintText: 'e.g. HDFC0001234',
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

        // AUTO-FILLED DATA
        if (_bankData != null) ...[
          const SizedBox(height: 16),
          _buildInfoRow(Icons.account_balance_rounded, 'Bank', _bankData!.bank),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.business_rounded, 'Branch', '${_bankData!.branch}, ${_bankData!.city}'),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GomandapTokens.emeraldGreen.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GomandapTokens.emeraldGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: GomandapTokens.emeraldGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: GomandapTokens.slateGray, fontWeight: FontWeight.w700)),
                Text(value, style: const TextStyle(fontSize: 13, color: GomandapTokens.royalNavy, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, size: 16, color: GomandapTokens.emeraldGreen),
        ],
      ),
    );
  }
}
