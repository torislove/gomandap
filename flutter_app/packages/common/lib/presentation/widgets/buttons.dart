import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gomandap_tokens.dart';

// ─── Primary Button ───────────────────────────────────────────────────────────

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leadingIcon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    return AnimatedOpacity(
      opacity: isDisabled ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed!();
              },
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : const LinearGradient(
                    colors: [GomandapTokens.emeraldGreen, GomandapTokens.emeraldGreenDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDisabled ? GomandapTokens.slateGray : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 8)],
                      Text(text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        )),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Secondary Button ─────────────────────────────────────────────────────────

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const SecondaryButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: GomandapTokens.softMist,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GomandapTokens.lightSlate),
        ),
        child: Center(
          child: Text(text,
            style: const TextStyle(
              color: GomandapTokens.royalNavy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            )),
        ),
      ),
    );
  }
}

// ─── Ghost Button ─────────────────────────────────────────────────────────────

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const GhostButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: GomandapTokens.slateGray,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      child: Text(text),
    );
  }
}

// ─── Gold Outline Button ──────────────────────────────────────────────────────

class GoldOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const GoldOutlineButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GomandapTokens.champagneGoldStart, width: 1.5),
        ),
        child: Center(
          child: Text(text,
            style: const TextStyle(
              color: GomandapTokens.champagneGoldEnd,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            )),
        ),
      ),
    );
  }
}

