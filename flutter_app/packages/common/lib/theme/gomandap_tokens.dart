import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GomandapTokens {
  // ─── Premium Typography ────────────────────────────────────────────────────
  static TextStyle get outfitHeader => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: royalNavy,
      );

  static TextStyle get outfitTitle => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: royalNavy,
      );

  static TextStyle get outfitSubtitle => GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: slateGray,
      );

  static TextStyle get interBody => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: slateGray,
      );

  static TextStyle get interCaption => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: royalNavy,
      );

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

  // ─── India Event Portal Gradients ──────────────────────────────────────────
  static Gradient get goldLeafGradient => const LinearGradient(
        colors: [champagneGoldStart, champagneGoldEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Gradient get luxuryNavyGradient => const LinearGradient(
        colors: [royalNavy, royalNavyLight],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static Gradient get crimsonEventGradient => const LinearGradient(
        colors: [Color(0xFF881337), royalNavy],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static Gradient get emeraldEscrowGradient => const LinearGradient(
        colors: [emeraldGreen, emeraldGreenDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ─── Spring Motion parameters ──────────────────────────────────────────────
  static const double springTension = 180.0;
  static const double springFriction = 0.72;
}

// ─── Ethnic Artistry Custom Painters ─────────────────────────────────────────

class EthnicFiligreePainter extends CustomPainter {
  final Color color;

  EthnicFiligreePainter({this.color = const Color(0x33DFBA73)}); // 20% Champagne Gold

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw luxury corner loops
    final double pad = 8.0;
    final double loopRadius = 14.0;

    // Top-Left corner filigree
    final pathTL = Path()
      ..moveTo(pad, pad + 30)
      ..lineTo(pad, pad + loopRadius)
      ..arcToPoint(
        Offset(pad + loopRadius, pad),
        radius: Radius.circular(loopRadius),
        clockwise: true,
      )
      ..lineTo(pad + 30, pad)
      ..moveTo(pad, pad + loopRadius)
      ..arcToPoint(
        Offset(pad + loopRadius, pad + loopRadius),
        radius: Radius.circular(loopRadius / 2),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(pad + loopRadius, pad),
        radius: Radius.circular(loopRadius / 2),
        clockwise: false,
      );
    canvas.drawPath(pathTL, paint);

    // Bottom-Right corner filigree
    final pathBR = Path()
      ..moveTo(size.width - pad, size.height - pad - 30)
      ..lineTo(size.width - pad, size.height - pad - loopRadius)
      ..arcToPoint(
        Offset(size.width - pad - loopRadius, size.height - pad),
        radius: Radius.circular(loopRadius),
        clockwise: true,
      )
      ..lineTo(size.width - pad - 30, size.height - pad)
      ..moveTo(size.width - pad, size.height - pad - loopRadius)
      ..arcToPoint(
        Offset(size.width - pad - loopRadius, size.height - pad - loopRadius),
        radius: Radius.circular(loopRadius / 2),
        clockwise: false,
      )
      ..arcToPoint(
        Offset(size.width - pad - loopRadius, size.height - pad),
        radius: Radius.circular(loopRadius / 2),
        clockwise: false,
      );
    canvas.drawPath(pathBR, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MarigoldGarlandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintOrange = Paint()
      ..color = const Color(0xFFF97316) // Vibrant Orange
      ..style = PaintingStyle.fill;

    final paintGold = Paint()
      ..color = const Color(0xFFFBBF24) // Golden Yellow
      ..style = PaintingStyle.fill;

    final paintGreen = Paint()
      ..color = const Color(0xFF10B981) // Mango Leaf Green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw delicate sweeping mango leaf threads with orange/gold marigold flowers
    final double step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      // Sweeping string
      final double y = 2.0 + (x % 40 == 0 ? 3.0 : 0.0);
      
      // Marigold flower 1 (Orange base)
      canvas.drawCircle(Offset(x, y), 3.0, paintOrange);
      // Marigold flower 2 (Yellow core)
      canvas.drawCircle(Offset(x, y), 1.5, paintGold);

      // Draw green mango leaves hanging in gaps
      if (x % 40 == 0) {
        final pathLeaf = Path()
          ..moveTo(x, y)
          ..quadraticBezierTo(x - 3, y + 8, x, y + 14)
          ..quadraticBezierTo(x + 3, y + 8, x, y);
        canvas.drawPath(pathLeaf, paintGreen);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

