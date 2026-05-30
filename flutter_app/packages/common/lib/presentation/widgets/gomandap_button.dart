import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gomandap_tokens.dart';

class GomandapButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLoading;
  final Widget? icon;

  const GomandapButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<GomandapButton> createState() => _GomandapButtonState();
}

class _GomandapButtonState extends State<GomandapButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      HapticFeedback.lightImpact();
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      widget.onPressed();
    }
  }

  void _handleTapCancel() {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            gradient: widget.isPrimary ? GomandapTokens.goldLeafGradient : null,
            color: widget.isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            border: widget.isPrimary ? null : Border.all(color: GomandapTokens.royalNavy, width: 1.5),
            boxShadow: widget.isPrimary ? GomandapTokens.goldGlowShadow : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: GomandapTokens.spacingXs),
                      ],
                      Text(
                        widget.label,
                        style: GomandapTokens.outfitTitle.copyWith(
                          color: widget.isPrimary ? Colors.white : GomandapTokens.royalNavy,
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
