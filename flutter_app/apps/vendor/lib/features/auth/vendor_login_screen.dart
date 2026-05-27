import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

// ignore: do_not_use_environment
const _kMockOtp  = String.fromEnvironment('MOCK_OTP',  defaultValue: '');
const _kMockAuth = bool.fromEnvironment('MOCK_AUTH',   defaultValue: false);

// Callback type passed in from the router to navigate after login
typedef OnVendorLoginSuccess = void Function();

class VendorLoginScreen extends ConsumerStatefulWidget {
  final OnVendorLoginSuccess? onSuccess;
  const VendorLoginScreen({super.key, this.onSuccess});

  @override
  ConsumerState<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends ConsumerState<VendorLoginScreen>
    with TickerProviderStateMixin {
  final _phoneCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpNodes = List.generate(6, (_) => FocusNode());

  bool _isOtpMode = false;
  bool _canSubmit = false;
  int _resendSeconds = 60;
  bool _isLoading = false;

  late AnimationController _bgRotateCtrl;
  late AnimationController _cardSlideCtrl;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  late Animation<Offset> _cardSlideAnim;

  @override
  void initState() {
    super.initState();

    _bgRotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _cardSlideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardSlideCtrl, curve: Curves.easeOutCubic));
    _cardSlideCtrl.forward();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bgRotateCtrl.dispose();
    _cardSlideCtrl.dispose();
    _shakeCtrl.dispose();
    _phoneCtrl.dispose();
    _businessCtrl.dispose();
    for (final c in _otpCtrls) { c.dispose(); }
    for (final f in _otpNodes) { f.dispose(); }
    super.dispose();
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────
  void _onPhoneChanged(String v) {
    setState(() => _canSubmit =
        v.length == 10 && _businessCtrl.text.trim().isNotEmpty);
  }

  void _onBusinessChanged(String v) {
    setState(() => _canSubmit =
        v.trim().isNotEmpty && _phoneCtrl.text.length == 10);
  }

  void _handleSendOtp() {
    if (!_canSubmit) {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });
    // Simulate network delay (mock mode — no real SMS)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isOtpMode = true;
        _canSubmit = false;
        _resendSeconds = 60;
      });
      // Pre-fill OTP in mock mode
      if (_kMockAuth || _kMockOtp.isNotEmpty) {
        final code = _kMockOtp.isNotEmpty ? _kMockOtp : '123456';
        for (int i = 0; i < 6 && i < code.length; i++) {
          _otpCtrls[i].text = code[i];
        }
        setState(() => _canSubmit = true);
      }
      _otpNodes[0].requestFocus();
      _startResendTimer();
    });
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
      _otpNodes[index + 1].requestFocus();
    } else if (val.isEmpty && index > 0) {
      _otpNodes[index - 1].requestFocus();
    }
    final otp = _otpCtrls.map((c) => c.text).join();
    setState(() => _canSubmit = otp.length == 6);
  }

  void _handleVerify() {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length != 6) {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    final isMock = _kMockAuth ||
        (_kMockOtp.isNotEmpty && otp == _kMockOtp) ||
        otp == '123456';

    Future.delayed(Duration(milliseconds: isMock ? 600 : 1200), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      widget.onSuccess?.call();
    });
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Animated radial navy background
          Positioned.fill(child: _buildAnimatedBackground()),

          // 2. Subtle filigree overlay
          Positioned.fill(
            child: CustomPaint(
              painter: EthnicFiligreePainter(
                  color: const Color(0x18DFBA73)),
            ),
          ),

          // 3. Marigold garland at top
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 12,
              child: CustomPaint(painter: _GarlandPainter()),
            ),
          ),

          // 4. Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildLogo(),
                    const SizedBox(height: 32),
                    SlideTransition(
                      position: _cardSlideAnim,
                      child: FadeTransition(
                        opacity: _cardSlideCtrl,
                        child: AnimatedBuilder(
                          animation: _shakeAnim,
                          builder: (ctx, child) => Transform.translate(
                            offset: Offset(_shakeAnim.value, 0),
                            child: child,
                          ),
                          child: _buildGlassCard(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildCTA(),
                    const SizedBox(height: 12),
                    _buildFooterActions(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Logo ──────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFDFBA73), Color(0xFFC59A48)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDFBA73).withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.storefront_rounded,
              color: Color(0xFF0F172A), size: 34),
        ),
        const SizedBox(height: 14),
        Text(
          'GoMandap',
          style: GoogleFonts.outfit(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Vendor Suite',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFDFBA73),
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'India\'s Premier Wedding & Event Portal',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  // ─── Frosted Glass Card ────────────────────────────────────────────────────
  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _isOtpMode ? _buildOtpSection() : _buildPhoneSection(),
          ),
        ),
      ),
    );
  }

  // ─── Phone + Business section ──────────────────────────────────────────────
  Widget _buildPhoneSection() {
    return Column(
      key: const ValueKey('phone'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Welcome, Vendor Partner 🏆',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to manage your bookings, catalog, and escrow',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: Colors.white.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        _fieldLabel('Business / Brand Name *'),
        const SizedBox(height: 8),
        _glassInput(
          controller: _businessCtrl,
          hint: 'e.g. Royal Events & Decorators',
          icon: Icons.business_rounded,
          onChanged: _onBusinessChanged,
        ),
        const SizedBox(height: 16),
        _fieldLabel('Registered Mobile Number *'),
        const SizedBox(height: 8),
        _glassInput(
          controller: _phoneCtrl,
          hint: '9876543210',
          icon: Icons.phone_android_rounded,
          isPhone: true,
          maxLength: 10,
          keyboardType: TextInputType.phone,
          onChanged: _onPhoneChanged,
        ),
        const SizedBox(height: 10),
        // Trust badges row
        Row(
          children: [
            _trustBadge(Icons.verified_rounded, 'GSTIN Verified'),
            const SizedBox(width: 10),
            _trustBadge(Icons.security_rounded, 'Escrow Protected'),
          ],
        ),
      ],
    );
  }

  // ─── OTP section ───────────────────────────────────────────────────────────
  Widget _buildOtpSection() {
    final isMock = _kMockAuth || _kMockOtp.isNotEmpty;
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Verify OTP 🔑',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sent to +91 ${_phoneCtrl.text}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isMock) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFFFC107).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.science_rounded,
                    size: 14, color: Color(0xFFFFC107)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🧪 DEV MODE — OTP pre-filled: 123456. Tap Verify to continue →',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: const Color(0xFFFFC107),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        // 6-digit OTP grid
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 44,
              height: 54,
              child: TextField(
                controller: _otpCtrls[i],
                focusNode: _otpNodes[i],
                keyboardType: TextInputType.number,
                maxLength: 1,
                textAlign: TextAlign.center,
                onChanged: (v) => _onOtpDigit(i, v),
                style: const TextStyle(
                  fontSize: 22,
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
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFDFBA73),
                      width: 1.8,
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

  // ─── CTA Button ────────────────────────────────────────────────────────────
  Widget _buildCTA() {
    final label = _isOtpMode ? 'Verify & Enter Suite →' : 'Send OTP →';
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () => _isOtpMode ? _handleVerify() : _handleSendOtp(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: _canSubmit && !_isLoading
              ? const LinearGradient(
                  colors: [Color(0xFFDFBA73), Color(0xFFC59A48)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _canSubmit && !_isLoading
              ? [
                  BoxShadow(
                    color: const Color(0xFFDFBA73).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF0F172A),
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _canSubmit
                        ? const Color(0xFF0F172A)
                        : Colors.white.withValues(alpha: 0.3),
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }

  // ─── Footer actions ────────────────────────────────────────────────────────
  Widget _buildFooterActions() {
    if (!_isOtpMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New vendor partner? ',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push(
                '/register',
                extra: _phoneCtrl.text,
              );
            },
            child: Text(
              'Register here →',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFDFBA73),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        _resendSeconds > 0
            ? Text(
                'Resend OTP in 0:${_resendSeconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w600,
                ),
              )
            : GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _isOtpMode = false;
                    _canSubmit = _phoneCtrl.text.length == 10 &&
                        _businessCtrl.text.trim().isNotEmpty;
                  });
                  Future.delayed(const Duration(milliseconds: 100),
                      _handleSendOtp);
                },
                child: Text(
                  'Resend OTP',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFDFBA73),
                  ),
                ),
              ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isOtpMode = false;
              _canSubmit = _phoneCtrl.text.length == 10 &&
                  _businessCtrl.text.trim().isNotEmpty;
            });
          },
          child: Text(
            'Change mobile number',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFFDFBA73),
          letterSpacing: 0.3,
        ),
      );

  Widget _glassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required void Function(String) onChanged,
    bool isPhone = false,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Icon(icon, color: const Color(0xFFDFBA73), size: 18),
          ),
          if (isPhone) ...[
            const Text(
              '+91',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
                width: 1, height: 18, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLength: maxLength,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustBadge(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: GomandapTokens.emeraldGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: GomandapTokens.emeraldGreen.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: GomandapTokens.emeraldGreen),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: GomandapTokens.emeraldGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Animated Background ───────────────────────────────────────────────────
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgRotateCtrl,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.cos(_bgRotateCtrl.value * 2 * math.pi) * 0.4,
                math.sin(_bgRotateCtrl.value * 2 * math.pi) * 0.4,
              ),
              radius: 1.5,
              colors: const [
                Color(0xFF1E293B),
                Color(0xFF0F172A),
                Color(0xFF020617),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

// ─── Garland Painter (top decoration) ────────────────────────────────────────
class _GarlandPainter extends CustomPainter {
  const _GarlandPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final orange = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    final gold = Paint()
      ..color = const Color(0xFFDFBA73)
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += 16) {
      canvas.drawCircle(Offset(x, 6), 4, orange);
      canvas.drawCircle(Offset(x, 6), 2, gold);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
