import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'onboarding_notifier.dart';
import '../auth/location_notifier.dart';
import '../../core/i18n/language_info.dart';
import '../../core/i18n/tr_widget.dart';
import 'package:gomandap_common/presentation/widgets/pincode_location_field.dart';

class ClientOnboardingWizard extends ConsumerStatefulWidget {
  const ClientOnboardingWizard({super.key});

  @override
  ConsumerState<ClientOnboardingWizard> createState() => _ClientOnboardingWizardState();
}

class _ClientOnboardingWizardState extends ConsumerState<ClientOnboardingWizard> {
  bool _locationReady = false;
  bool _showManualPincode = false;

  @override
  void initState() {
    super.initState();
    // Do not auto-trigger location, let the user trigger it to comply with Android 11+ policies
  }

  void _completeOnboarding() {
    HapticFeedback.heavyImpact();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final locationState = ref.watch(locationNotifierProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ── Background Ambient Luxury Glow ────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: GomandapTokens.royalNavy,
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
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
            bottom: -80,
            left: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content ──────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Brand header
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.celebration_rounded, color: GomandapTokens.champagneGoldStart, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'GoMandap',
                        style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'India\'s Premium Event Planning Portal',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45), letterSpacing: 0.5),
                  ),
                ),

                const SizedBox(height: 32),

                // Language Selection
                Expanded(
                  child: _buildLanguageStage(onboardingState),
                ),

                // Location status bar + continue button
                _buildBottomSection(locationState, onboardingState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageStage(OnboardingUiState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tr('onboarding.greeting', placeholders: {'name': state.userName.isNotEmpty ? state.userName : 'Guest'},
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Tr('onboarding.select_language',
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.6), height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              itemCount: LanguageInfo.all.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.95,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final lang = LanguageInfo.all[index];
                final isSel = state.selectedLanguage == lang.name;

                return _LiquidGlassLanguageTile(
                  info: lang,
                  isSelected: isSel,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(onboardingNotifierProvider.notifier).setLanguage(lang.name);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(LocationState locationState, OnboardingUiState onboardingState) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location status badge or Manual Pincode
              if (_showManualPincode)
                Theme(
                  data: ThemeData.dark(),
                  child: PincodeLocationField(
                    onLocationSelected: (village, district, state) {
                      setState(() => _locationReady = true);
                    },
                  ),
                )
              else if (locationState is LocationLoading)
                _buildLocationLoadingBadge()
              else if (locationState is LocationSuccess)
                _buildLocationSuccessBadge(locationState)
              else
                _buildLocationFallbackBadge(),

              const SizedBox(height: 16),

              // Continue button
              GestureDetector(
                onTap: _locationReady ? _completeOnboarding : null,
                child: AnimatedOpacity(
                  opacity: _locationReady ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          GomandapTokens.emeraldGreen,
                          Color(0xFF059669),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        if (_locationReady)
                          BoxShadow(
                            color: GomandapTokens.emeraldGreen.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tr('onboarding.start_planning',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationLoadingBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: GomandapTokens.champagneGoldStart,
          ),
        ),
        const SizedBox(width: 10),
        Tr('onboarding.detecting_location',
          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildLocationSuccessBadge(LocationSuccess location) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: GomandapTokens.emeraldGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GomandapTokens.emeraldGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded, size: 14, color: GomandapTokens.emeraldGreen),
          const SizedBox(width: 6),
          Text(
            '📍 ${location.locality}, ${location.city}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: GomandapTokens.emeraldGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('DETECTED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFallbackBadge() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded, size: 14, color: Colors.white38),
            const SizedBox(width: 8),
            Tr('onboarding.location_fallback',
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
                final locNotifier = ref.read(locationNotifierProvider.notifier);
                await locNotifier.detectCurrentLocation();
                if (mounted) {
                  setState(() => _locationReady = ref.read(locationNotifierProvider) is LocationSuccess);
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: GomandapTokens.champagneGoldStart.withValues(alpha: 0.2),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('📍 Detect Location', style: TextStyle(color: GomandapTokens.champagneGoldStart, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => setState(() => _showManualPincode = true),
              child: const Text('Enter PIN Code', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Liquid Glass Language Tile ────────────────────────────────────────────────

class _LiquidGlassLanguageTile extends StatefulWidget {
  final LanguageInfo info;
  final bool isSelected;
  final VoidCallback onTap;

  const _LiquidGlassLanguageTile({
    required this.info,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_LiquidGlassLanguageTile> createState() => _LiquidGlassLanguageTileState();
}

class _LiquidGlassLanguageTileState extends State<_LiquidGlassLanguageTile>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    
    if (widget.isSelected) {
      _scaleController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _LiquidGlassLanguageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _scaleController.forward();
      } else {
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MouseRegion(
      onEnter: (_) => _scaleController.forward(),
      onExit: (_) {
        if (!widget.isSelected) _scaleController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [
                    // Liquid glass base — coloured gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.info.primaryColor.withValues(alpha: 0.35),
                            widget.info.accentColor.withValues(alpha: 0.20),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: widget.isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.20),
                          width: widget.isSelected ? 2 : 0.8,
                        ),
                      ),
                    ),

                    // Glass blur overlay
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                      ),
                    ),

                    // Animated glow ring
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: widget.isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.info.primaryColor.withValues(alpha: _glowAnimation.value * 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: widget.info.accentColor.withValues(alpha: _glowAnimation.value * 0.3),
                                  blurRadius: 40,
                                  spreadRadius: -4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Flag + shimmer
                            Text(widget.info.flag, style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 6),
                            Text(
                              widget.info.name,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.info.nativeName,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.6),
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Selected accent dot
                    if (widget.isSelected)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: widget.info.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: widget.info.primaryColor.withValues(alpha: 0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
