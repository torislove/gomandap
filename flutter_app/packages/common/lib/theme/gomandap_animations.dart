import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Central animation durations, curves, and helpers for GoMandap's premium
/// Indian-market experience. Inspired by the warmth of festivals, the
/// elegance of gold, and the vibrancy of marigolds.
class GomandapAnimations {
  // ─── Durations ────────────────────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration stagger = Duration(milliseconds: 600);

  // ─── Curves ───────────────────────────────────────────────────────────────
  static const Curve springOut = Curves.fastOutSlowIn;
  static const Curve bouncy = Curves.elasticOut;
  static const Curve smoothEase = Curves.easeInOutCubic;
  static const Curve goldEase = Cubic(0.34, 1.56, 0.64, 1.0); // premium spring

  // ─── Spring Simulation ────────────────────────────────────────────────────
  static SpringDescription get spring => const SpringDescription(
        mass: 1.0,
        stiffness: 300,
        damping: 22,
      );

  static SpringDescription get bouncySpring => const SpringDescription(
        mass: 0.8,
        stiffness: 400,
        damping: 14,
      );

  static SpringDescription get gentleSpring => const SpringDescription(
        mass: 1.2,
        stiffness: 180,
        damping: 20,
      );

  // ─── Staggered List Animation ─────────────────────────────────────────────
  /// Returns a combined [Animate] effect for list items. Use with flutter_animate.
  static List<Effect<dynamic>> get staggeredFadeSlide => const [
        FadeEffect(
          begin: 0.0,
          end: 1.0,
          duration: normal,
          curve: springOut,
        ),
        SlideEffect(
          begin: Offset(0, 24),
          end: Offset.zero,
          duration: normal,
          curve: springOut,
        ),
      ];

  static List<Effect<dynamic>> get staggeredScaleFade => const [
        FadeEffect(
          begin: 0.0,
          end: 1.0,
          duration: normal,
          curve: springOut,
        ),
        ScaleEffect(
          begin: Offset(0.9, 0.9),
          end: Offset(1.0, 1.0),
          duration: normal,
          curve: springOut,
        ),
      ];

  // ─── Page Transitions ─────────────────────────────────────────────────────
  static Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
      get fadeTransition => _fadeTransition;

  static Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
      get slideUpTransition => _slideUpTransition;

  static Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
      get slideRightTransition => _slideRightTransition;

  static Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
      get scaleFadeTransition => _scaleFadeTransition;

  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  static Widget _slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: springOut)),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: springOut),
        child: child,
      ),
    );
  }

  static Widget _slideRightTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: springOut)),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: springOut),
        child: child,
      ),
    );
  }

  static Widget _scaleFadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: springOut),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: springOut),
        child: child,
      ),
    );
  }

  // ─── Shimmer Configuration ────────────────────────────────────────────────
  static Gradient shimmerGradient(Color base) => LinearGradient(
        colors: [
          base.withValues(alpha: 0.3),
          base.withValues(alpha: 0.6),
          base.withValues(alpha: 0.3),
        ],
        stops: const [0.3, 0.5, 0.7],
        begin: const Alignment(-1, -0.3),
        end: const Alignment(1, 0.3),
      );
}

/// Extension on [int] to easily apply staggered delays in list views.
extension StaggeredDelay on int {
  Duration get staggerDelay => Duration(milliseconds: this * 60);
}

/// Extension on [Widget] for quick micro-interaction animations.
extension MicroInteractionExtension on Widget {
  /// Subtle hover-like scale on tap-down via GestureDetector.
  Widget withTapScale({
    double scale = 0.96,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return _TapScaleWrapper(
      scale: scale,
      duration: duration,
      child: this,
    );
  }
}

class _TapScaleWrapper extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;

  const _TapScaleWrapper({
    required this.child,
    required this.scale,
    required this.duration,
  });

  @override
  State<_TapScaleWrapper> createState() => _TapScaleWrapperState();
}

class _TapScaleWrapperState extends State<_TapScaleWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0,
      lowerBound: widget.scale,
      upperBound: 1.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _controller.reverse(),
      onPointerUp: (_) => _controller.forward(),
      onPointerCancel: (_) => _controller.forward(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Transform.scale(
          scale: _animation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
