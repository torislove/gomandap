import 'package:flutter/material.dart';

class GomandapTokens {
  // ─── Primary ──────────────────────────────────────────────────────────────
  static const Color royalNavy = Color(0xFF0F172A);
  static const Color royalNavyLight = Color(0xFF1E293B);
  static const Color royalNavySurface = Color(0xFF334155);

  // ─── Accent ───────────────────────────────────────────────────────────────
  static const Color champagneGoldStart = Color(0xFFDFBA73);
  static const Color champagneGoldEnd = Color(0xFFC59A48);
  static const Color champagneGoldLight = Color(0xFFF5E6C8);

  // ─── Success / CTA ────────────────────────────────────────────────────────
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color emeraldGreenDark = Color(0xFF059669);
  static const Color emeraldGreenLight = Color(0xFFD1FAE5);

  // ─── Neutrals ─────────────────────────────────────────────────────────────
  static const Color pearlWhite = Color(0xFFF8F9FA);
  static const Color softMist = Color(0xFFF1F5F9);
  static const Color iceCreamGray = Color(0xFFFBFAEE);
  static const Color slateGray = Color(0xFF64748B);
  static const Color lightSlate = Color(0xFFE2E8F0);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─── Legacy aliases (backward compat) ────────────────────────────────────
  static const Color textSecondary = slateGray;

  // ─── Spacing ──────────────────────────────────────────────────────────────
  static const double spacingXxs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 20.0;
  static const double spacingXl = 24.0;
  static const double spacingXxl = 32.0;
  static const double spacingXxxl = 48.0;

  // ─── Shadows ──────────────────────────────────────────────────────────────
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: royalNavy.withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: royalNavy.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get goldGlowShadow => [
    BoxShadow(
      color: champagneGoldStart.withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

