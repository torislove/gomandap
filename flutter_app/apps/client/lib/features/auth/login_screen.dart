import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/presentation/widgets/buttons.dart';
import 'package:gomandap_common/auth/auth_notifier.dart';
import '../../core/router/app_router.dart';

class ClientLoginScreen extends ConsumerStatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  ConsumerState<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends ConsumerState<ClientLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isOtpMode = false;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _canSubmit = false;
  int _resendSeconds = 60;

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onPhoneChanged(String val) {
    setState(() => _canSubmit = val.length == 10);
  }

  void _handleSendOtp() {
    if (!_canSubmit) return;
    ref.read(authNotifierProvider.notifier).sendOtp("+91${_phoneController.text}");
    setState(() {
      _isOtpMode = true;
      _canSubmit = false;
    });
    _otpFocusNodes[0].requestFocus();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendSeconds--);
      return _resendSeconds > 0;
    });
  }

  void _onOtpDigit(int index, String val) {
    if (val.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (val.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }

    final otp = _otpControllers.map((c) => c.text).join();
    setState(() => _canSubmit = otp.length == 6);
  }

  void _handleVerify() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      ref.read(authNotifierProvider.notifier).verifyOtp(otp);
      AppRouter.onLoginSuccess();
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStateStatus.loading;

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Logo
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.celebration_rounded, size: 56, color: GomandapTokens.champagneGoldStart),
                    SizedBox(height: 12),
                    Text('GoMandap',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy, letterSpacing: -0.5)),
                    SizedBox(height: 4),
                    Text('Plan Your Perfect Celebration',
                      style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isOtpMode ? _buildOtpSection() : _buildPhoneSection(),
              ),

              const Spacer(),

              // CTA Button
              PrimaryButton(
                text: _isOtpMode ? 'Verify & Explore →' : 'Continue →',
                isLoading: isLoading,
                onPressed: _canSubmit ? (_isOtpMode ? _handleVerify : _handleSendOtp) : null,
              ),

              const SizedBox(height: 16),

              if (!_isOtpMode)
                Center(
                  child: GhostButton(
                    text: 'Browse as Guest',
                    onPressed: () {
                      AppRouter.onLoginSuccess();
                      context.go('/home');
                    },
                  ),
                ),

              if (_isOtpMode) ...[
                Center(
                  child: _resendSeconds > 0
                      ? Text(
                          'Resend OTP in 0:${_resendSeconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: GomandapTokens.slateGray, fontSize: 13),
                        )
                      : GhostButton(text: 'Resend OTP', onPressed: _handleSendOtp),
                ),
                const SizedBox(height: 8),
                Center(
                  child: GhostButton(
                    text: 'Change Number',
                    onPressed: () => setState(() {
                      _isOtpMode = false;
                      _canSubmit = _phoneController.text.length == 10;
                    }),
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneSection() {
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Enter Mobile Number',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        const Text("We'll send a one-time password to verify",
          style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GomandapTokens.lightSlate),
            boxShadow: GomandapTokens.softShadow,
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('+91',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
              ),
              Container(width: 1, height: 24, color: GomandapTokens.lightSlate),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  onChanged: _onPhoneChanged,
                  style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: GomandapTokens.royalNavy, letterSpacing: 2,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '98765 43210',
                    hintStyle: TextStyle(color: Color(0xFFCBD5E1), letterSpacing: 2),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpSection() {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Verify OTP',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        const SizedBox(height: 6),
        Text("Sent to +91 ${_phoneController.text}",
          style: const TextStyle(fontSize: 13, color: GomandapTokens.slateGray)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 48,
              height: 56,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                maxLength: 1,
                textAlign: TextAlign.center,
                onChanged: (val) => _onOtpDigit(index, val),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
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
                    borderSide: const BorderSide(color: GomandapTokens.emeraldGreen, width: 2),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
