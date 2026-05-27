import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/presentation/widgets/buttons.dart';
import 'package:gomandap_common/auth/auth_notifier.dart';
import '../../core/router/app_router.dart';
import '../onboarding/onboarding_notifier.dart';

// ignore: do_not_use_environment
const _kMockOtp = String.fromEnvironment('MOCK_OTP', defaultValue: '');
const _kMockAuth = bool.fromEnvironment('MOCK_AUTH', defaultValue: false);


class ClientLoginScreen extends ConsumerStatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  ConsumerState<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends ConsumerState<ClientLoginScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isOtpMode = false;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _canSubmit = false;
  int _resendSeconds = 60;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 8.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String val) {
    setState(() => _canSubmit = val.length == 10 && _nameController.text.trim().isNotEmpty);
  }

  void _handleSendOtp() {
    if (!_canSubmit) {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      return;
    }
    HapticFeedback.mediumImpact();
    // In mock mode, skip the real OTP network call entirely
    if (!_kMockAuth) {
      ref.read(authNotifierProvider.notifier).sendOtp("+91${_phoneController.text}");
    }
    setState(() {
      _isOtpMode = true;
      _canSubmit = false;
    });
    // In mock mode, pre-fill 123456 for instant verification
    if (_kMockAuth || _kMockOtp.isNotEmpty) {
      final code = _kMockOtp.isNotEmpty ? _kMockOtp : '123456';
      for (int i = 0; i < 6 && i < code.length; i++) {
        _otpControllers[i].text = code[i];
      }
      setState(() => _canSubmit = true);
    }
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
      HapticFeedback.mediumImpact();
      // ── Mock-OTP bypass for development ──────────────────────────────────
      // If MOCK_AUTH flag is set OR the OTP matches the mock code, skip real
      // Supabase verification and navigate directly.
      final isMockOtp = _kMockAuth ||
          (_kMockOtp.isNotEmpty && otp == _kMockOtp) ||
          otp == '123456'; // universal dev shortcut
      if (!isMockOtp) {
        ref.read(authNotifierProvider.notifier).verifyOtp(otp);
      }
      ref.read(onboardingNotifierProvider.notifier).setUserName(_nameController.text.trim());
      AppRouter.onLoginSuccess();
      context.go('/onboarding');
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStateStatus.loading;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium dark background with champagne gold underglow gradient
          Container(
            decoration: BoxDecoration(
              gradient: GomandapTokens.crimsonEventGradient, // India event portal crimson underglow
            ),
          ),
          // Luxury Ethnic Filigree Overlays
          Positioned.fill(
            child: CustomPaint(
              painter: EthnicFiligreePainter(),
            ),
          ),
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDFBA73).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFDFBA73).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  // Logo
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFBA73).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFDFBA73).withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.celebration_rounded,
                            size: 44,
                            color: Color(0xFFDFBA73),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'GoMandap',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Plan Your Perfect Celebration',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 3. Shaking Frosted Glass Card
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnim.value, 0),
                        child: child,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: const Color(0xFFDFBA73).withValues(alpha: 0.04),
                                blurRadius: 30,
                                spreadRadius: -2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isOtpMode ? _buildOtpSection() : _buildPhoneSection(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CTA Button
                  PrimaryButton(
                    text: _isOtpMode ? 'Verify & Explore →' : 'Continue →',
                    isLoading: isLoading,
                    onPressed: () {
                      if (_canSubmit) {
                        if (_isOtpMode) {
                          _handleVerify();
                        } else {
                          _handleSendOtp();
                        }
                      } else {
                        HapticFeedback.heavyImpact();
                        _shakeController.forward(from: 0.0);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  if (!_isOtpMode)
                    Center(
                      child: GhostButton(
                        text: 'Browse as Guest',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(onboardingNotifierProvider.notifier).setUserName("Guest");
                          AppRouter.onLoginSuccess();
                          context.go('/onboarding');
                        },
                      ),
                    ),

                  if (_isOtpMode) ...[
                    Center(
                      child: _resendSeconds > 0
                          ? Text(
                              'Resend OTP in 0:${_resendSeconds.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : GhostButton(
                              text: 'Resend OTP',
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                _handleSendOtp();
                              },
                            ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: GhostButton(
                        text: 'Change Phone Number',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _isOtpMode = false;
                            _canSubmit = _phoneController.text.length == 10 &&
                                _nameController.text.trim().isNotEmpty;
                          });
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    required void Function(String) onChanged,
    int? maxLength,
    bool isPhone = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(prefixIcon, color: const Color(0xFFDFBA73), size: 20),
          ),
          if (isPhone) ...[
            const Text(
              '+91',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 20,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLength: maxLength,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneSection() {
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Welcome to GoMandap 🏛',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Let's personalize your elegant celebration search",
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),

        // Full Name Input
        const Text(
          'Full Name *',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFFDFBA73),
          ),
        ),
        const SizedBox(height: 8),
        _buildGlassInput(
          controller: _nameController,
          hintText: 'e.g., Manoj Kumar',
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
          onChanged: (val) {
            setState(() {
              _canSubmit = val.trim().isNotEmpty && _phoneController.text.length == 10;
            });
          },
        ),
        const SizedBox(height: 16),

        // Mobile Number Input
        const Text(
          'Mobile Number *',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFFDFBA73),
          ),
        ),
        const SizedBox(height: 8),
        _buildGlassInput(
          controller: _phoneController,
          hintText: '9876543210',
          prefixIcon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          isPhone: true,
          onChanged: _onPhoneChanged,
        ),
      ],
    );
  }

  Widget _buildOtpSection() {
    final isMockMode = _kMockAuth || _kMockOtp.isNotEmpty;
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Verify OTP 🔑',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Sent to +91 ${_phoneController.text}",
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isMockMode) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFC107).withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.science_rounded, size: 14, color: Color(0xFFFFC107)),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '🧪 DEV MODE — OTP pre-filled: 123456. Just tap Verify →',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFFC107),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 42,
              height: 52,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                maxLength: 1,
                textAlign: TextAlign.center,
                onChanged: (val) => _onOtpDigit(index, val),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFDFBA73),
                      width: 1.5,
                    ),
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
