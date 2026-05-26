import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gomandap_tokens.dart';

class AntigravityBouncySwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String? subtitle;
  final IconData? icon;

  const AntigravityBouncySwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  State<AntigravityBouncySwitch> createState() => _AntigravityBouncySwitchState();
}

class _AntigravityBouncySwitchState extends State<AntigravityBouncySwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _toggleAnimation;
  late Animation<double> _stretchAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _toggleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );

    _stretchAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.25), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.25, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AntigravityBouncySwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            // Icon Indicator
            if (widget.icon != null) ...[
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: widget.value
                      ? GomandapTokens.emeraldGreen.withValues(alpha: 0.08)
                      : GomandapTokens.softMist,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: widget.value ? GomandapTokens.emeraldGreen : GomandapTokens.royalNavy,
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Text Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: GomandapTokens.royalNavy,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: GomandapTokens.slateGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Premium Animated Bouncy Toggle Switch
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double toggleVal = _toggleAnimation.value;
                final double stretchVal = _stretchAnimation.value;

                return Container(
                  width: 54, height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: widget.value
                          ? [GomandapTokens.emeraldGreen, GomandapTokens.emeraldGreenDark]
                          : [GomandapTokens.lightSlate, GomandapTokens.softMist],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: widget.value
                        ? [
                            BoxShadow(
                              color: GomandapTokens.emeraldGreen.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 2 + (toggleVal * 20),
                        top: 2,
                        child: Transform.scale(
                          scaleX: stretchVal,
                          scaleY: 1.0,
                          alignment: Alignment.center,
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: GomandapTokens.royalNavy.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedRotation(
                                turns: toggleVal * 0.5,
                                duration: const Duration(milliseconds: 250),
                                child: Icon(
                                  widget.value ? Icons.done : Icons.close,
                                  size: 14,
                                  color: widget.value
                                      ? GomandapTokens.emeraldGreen
                                      : GomandapTokens.slateGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

