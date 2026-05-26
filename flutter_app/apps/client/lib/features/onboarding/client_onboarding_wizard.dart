import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'onboarding_notifier.dart';

class ClientOnboardingWizard extends ConsumerStatefulWidget {
  const ClientOnboardingWizard({super.key});

  @override
  ConsumerState<ClientOnboardingWizard> createState() => _ClientOnboardingWizardState();
}

class _ClientOnboardingWizardState extends ConsumerState<ClientOnboardingWizard> {
  final PageController _pageController = PageController();
  int _currentStage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStage() {
    HapticFeedback.mediumImpact();
    if (_currentStage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Completed onboarding onboarding - save state and launch dashboard
      HapticFeedback.heavyImpact();
      context.go('/home');
    }
  }

  void _prevStage() {
    HapticFeedback.lightImpact();
    if (_currentStage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingNotifierProvider);

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      body: Stack(
        children: [
          // ── Background Ambient Luxury Glow ────────────────────────────────
          Positioned(
            top: -100, right: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: GomandapTokens.champagneGoldStart.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: -80, left: -100,
            child: CircleAvatar(
              radius: 180,
              backgroundColor: GomandapTokens.emeraldGreen.withValues(alpha: 0.06),
            ),
          ),

          // ── Main Page Content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Glassmorphic Top Progress Bar
                _buildTopProgress(),

                // Scrollable walkthrough stages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (stage) {
                      setState(() => _currentStage = stage);
                    },
                    children: [
                      _buildLanguageStage(onboardingState),
                      _buildEventStage(onboardingState),
                      _buildLocationStage(onboardingState),
                      _buildCalibrationStage(onboardingState),
                    ],
                  ),
                ),

                // Bottom Action buttons
                _buildBottomControls(onboardingState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProgress() {
    final titles = ['Language', 'Event Type', 'Auto-Location', 'Calibrate'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stage ${_currentStage + 1} of 4: ${titles[_currentStage]}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: GomandapTokens.royalNavy,
                  letterSpacing: 0.5,
                ),
              ),
              const Icon(
                Icons.workspace_premium_rounded,
                color: GomandapTokens.champagneGoldStart,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Multi-stage visual linear indicator
          Row(
            children: List.generate(4, (index) {
              final isCompleted = index < _currentStage;
              final isActive = index == _currentStage;

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6,
                  margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? GomandapTokens.emeraldGreen
                        : isActive
                            ? GomandapTokens.royalNavy
                            : GomandapTokens.softMist,
                    borderRadius: BorderRadius.circular(3),
                    border: isActive
                        ? Border.all(color: GomandapTokens.champagneGoldStart, width: 1)
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(OnboardingUiState state) {
    final isFirst = _currentStage == 0;
    final isLast = _currentStage == 3;

    // Validation conditions for continuing
    bool canProceed = true;
    if (_currentStage == 2) {
      canProceed = state.isLocationSuccess;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: GomandapTokens.lightSlate)),
      ),
      child: Row(
        children: [
          if (!isFirst) ...[
            GestureDetector(
              onTap: _prevStage,
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: GomandapTokens.softMist,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GomandapTokens.lightSlate),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: GomandapTokens.royalNavy,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: GestureDetector(
              onTap: canProceed ? _nextStage : null,
              child: AnimatedOpacity(
                opacity: canProceed ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [GomandapTokens.emeraldGreen, GomandapTokens.emeraldGreenDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (canProceed)
                        BoxShadow(
                          color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      isLast ? 'Complete & Plan! 🚀' : 'Continue →',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
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

  // ─── Stage 1: Languages Selection ─────────────────────────────────────────

  Widget _buildLanguageStage(OnboardingUiState state) {
    final languages = [
      {'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
      {'name': 'Telugu', 'native': 'తెలుగు', 'flag': '🇮🇳'},
      {'name': 'Hindi', 'native': 'हिन्दी', 'flag': '🇮🇳'},
      {'name': 'Tamil', 'native': 'தமிழ்', 'flag': '🇮🇳'},
      {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
      {'name': 'Malayalam', 'native': 'മലയാളം', 'flag': '🇮🇳'},
      {'name': 'Bengali', 'native': 'বাংলা', 'flag': '🇮🇳'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Namaste ${state.userName.isNotEmpty ? state.userName : ""}! 🙏',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select your preferred language to customize your planning interfaces and support modules.',
                style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: languages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final lang = languages[index];
              final isSel = state.selectedLanguage == lang['name'];

              return _AnimatedLanguageCard(
                name: lang['name']!,
                nativeName: lang['native']!,
                flag: lang['flag']!,
                isSelected: isSel,
                onTap: () {
                  ref.read(onboardingNotifierProvider.notifier).setLanguage(lang['name']!);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Stage 2: Event Type Selection ────────────────────────────────────────

  Widget _buildEventStage(OnboardingUiState state) {
    final eventTypes = [
      {
        'type': 'Wedding / Muhurtham',
        'desc': 'Traditional Kalyanam, Grand Marriages & Ceremonies',
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFEF4444),
      },
      {
        'type': 'Sangeet / Mehendi',
        'desc': 'Pre-wedding dancing nights, Haldi, & Engagement parties',
        'icon': Icons.celebration_rounded,
        'color': GomandapTokens.champagneGoldEnd,
      },
      {
        'type': 'Birthday Celebration',
        'desc': 'Kids themed parties, milestone birthdays & milestones',
        'icon': Icons.cake_rounded,
        'color': const Color(0xFF06B6D4),
      },
      {
        'type': 'Corporate Gathering',
        'desc': 'Conferences, elegant gala dinners & AV audio Truss panels',
        'icon': Icons.business_center_rounded,
        'color': GomandapTokens.royalNavy,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What celebration are you planning? 🎉',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
          ),
          const SizedBox(height: 6),
          const Text(
            'Surfaces specific vendor directories, tailored menus, and layout checklists.',
            style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray, height: 1.4),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: eventTypes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = eventTypes[index];
                final isSel = state.eventType == item['type'];

                return _AnimatedEventCard(
                  type: item['type'] as String,
                  desc: item['desc'] as String,
                  icon: item['icon'] as IconData,
                  accentColor: item['color'] as Color,
                  isSelected: isSel,
                  onTap: () {
                    ref.read(onboardingNotifierProvider.notifier).setEventType(item['type'] as String);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stage 3: Auto-Location Radar Geofencing ──────────────────────────────

  Widget _buildLocationStage(OnboardingUiState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Auto-Location & Geolocator 🛰',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
          ),
          const SizedBox(height: 6),
          const Text(
            'GoMandap uses geofencing limits to filter nearby banquet halls, caterers, and live support teams.',
            style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray, height: 1.4),
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (state.isLocationSearching) const _LocationRadarPulse(),
                  GestureDetector(
                    onTap: state.isLocationSearching
                        ? null
                        : () async {
                            final notifier = ref.read(onboardingNotifierProvider.notifier);
                            notifier.startLocationSearch();
                            // Simulate coordinate resolving over 2.5s
                            await Future.delayed(const Duration(milliseconds: 2500));
                            if (!mounted) return;
                            notifier.setLocation('Hyderabad', 'Jubilee Hills');
                          },
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: state.isLocationSuccess
                          ? GomandapTokens.emeraldGreen
                          : GomandapTokens.royalNavy,
                      child: Icon(
                        state.isLocationSuccess
                            ? Icons.location_on_rounded
                            : Icons.gps_fixed_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                if (!state.isLocationSearching && !state.isLocationSuccess)
                  const Text(
                    'Tap target icon to fetch current GPS coordinates',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GomandapTokens.slateGray),
                  )
                else if (state.isLocationSearching)
                  const Column(
                    children: [
                      Text(
                        'Pinging regional satellites...',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pulsing concentric signals...',
                        style: TextStyle(fontSize: 11, color: GomandapTokens.slateGray),
                      ),
                    ],
                  )
                else if (state.isLocationSuccess)
                  Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: GomandapTokens.emeraldGreen, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'GEOFENCED COORDINATES FIXED ✅',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: GomandapTokens.emeraldGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${state.detectedLocality}, ${state.detectedCity}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Stage 4: Calibration (Pax & Budget Range) ───────────────────────────

  Widget _buildCalibrationStage(OnboardingUiState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calibrate Your Search Preferences 💎',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sets up estimated filters so your home dashboard shelves are instantly customized.',
            style: TextStyle(fontSize: 13, color: GomandapTokens.slateGray, height: 1.4),
          ),
          const SizedBox(height: 32),

          // Guest capacity estimation slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Guest Count (PAX)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
              ),
              Text(
                '${state.guestCount.toInt()} Guest PAX',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: GomandapTokens.emeraldGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            min: 50,
            max: 2500,
            value: state.guestCount,
            activeColor: GomandapTokens.emeraldGreen,
            inactiveColor: GomandapTokens.softMist,
            onChanged: (val) {
              ref.read(onboardingNotifierProvider.notifier).setGuestCount(val.roundToDouble());
            },
          ),
          const SizedBox(height: 32),

          // Total target package budget planning slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Target Event Budget Package',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
              ),
              Text(
                '₹${(state.estimatedBudget / 100000).toStringAsFixed(1)} Lakhs',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: GomandapTokens.champagneGoldEnd,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            min: 100000,
            max: 5000000,
            value: state.estimatedBudget,
            activeColor: GomandapTokens.champagneGoldEnd,
            inactiveColor: GomandapTokens.softMist,
            onChanged: (val) {
              ref.read(onboardingNotifierProvider.notifier).setBudget(val.roundToDouble());
            },
          ),
        ],
      ),
    );
  }
}

// ─── Stage 1 Animated Language Card ──────────────────────────────────────────

class _AnimatedLanguageCard extends StatefulWidget {
  final String name;
  final String nativeName;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedLanguageCard({
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedLanguageCard> createState() => _AnimatedLanguageCardState();
}

class _AnimatedLanguageCardState extends State<_AnimatedLanguageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => widget.isSelected ? null : _controller.reverse(),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isSelected ? Colors.white : GomandapTokens.softMist,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected
                    ? GomandapTokens.champagneGoldStart
                    : GomandapTokens.lightSlate,
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (widget.isSelected)
                  BoxShadow(
                    color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.flag, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: GomandapTokens.royalNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.nativeName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: GomandapTokens.slateGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stage 2 Animated Event Card ─────────────────────────────────────────────

class _AnimatedEventCard extends StatefulWidget {
  final String type;
  final String desc;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedEventCard({
    required this.type,
    required this.desc,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedEventCard> createState() => _AnimatedEventCardState();
}

class _AnimatedEventCardState extends State<_AnimatedEventCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => widget.isSelected ? null : _controller.reverse(),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected ? widget.accentColor : GomandapTokens.lightSlate,
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? widget.accentColor.withValues(alpha: 0.1)
                      : GomandapTokens.royalNavy.withValues(alpha: 0.04),
                  blurRadius: widget.isSelected ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? widget.accentColor.withValues(alpha: 0.15)
                        : GomandapTokens.softMist,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.isSelected ? widget.accentColor : GomandapTokens.royalNavy,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.type,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w700,
                          color: GomandapTokens.royalNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.desc,
                        style: const TextStyle(
                          fontSize: 11,
                          color: GomandapTokens.slateGray,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  widget.isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: widget.isSelected ? widget.accentColor : GomandapTokens.lightSlate,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stage 3 Concentric Location Radar Pulse Animation ───────────────────────

class _LocationRadarPulse extends StatefulWidget {
  const _LocationRadarPulse();

  @override
  State<_LocationRadarPulse> createState() => _LocationRadarPulseState();
}

class _LocationRadarPulseState extends State<_LocationRadarPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _RadarPulsePainter(progress: _controller.value),
        );
      },
    );
  }
}

class _RadarPulsePainter extends CustomPainter {
  final double progress;

  _RadarPulsePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width / 2, size.height / 2);

    final paint1 = Paint()
      ..color = GomandapTokens.champagneGoldStart.withValues(alpha: (1.0 - progress) * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final paint2 = Paint()
      ..color = GomandapTokens.emeraldGreen.withValues(alpha: (1.0 - (progress + 0.5) % 1.0) * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw 2 concentric visual expanding pulses
    canvas.drawCircle(center, maxRadius * progress, paint1);
    canvas.drawCircle(center, maxRadius * ((progress + 0.5) % 1.0), paint2);
  }

  @override
  bool shouldRepaint(covariant _RadarPulsePainter oldDelegate) => true;
}
