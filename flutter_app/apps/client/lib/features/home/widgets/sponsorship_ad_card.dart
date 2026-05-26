import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';

class SponsorshipAdCard extends ConsumerStatefulWidget {
  const SponsorshipAdCard({super.key});

  @override
  ConsumerState<SponsorshipAdCard> createState() => _SponsorshipAdCardState();
}

class _SponsorshipAdCardState extends ConsumerState<SponsorshipAdCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campaignAsyncValue = ref.watch(activeCampaignFutureProvider);
    final campaign = campaignAsyncValue.value ?? {
      'title': 'GoMandap Elite Events',
      'description': 'Crafting grand memories, managing full sangeet packages, sound setups & catering.',
      'action_label': 'Book Consult',
      'svg_animation_speed': 1.0,
      'glow_color': '#DFBA73',
    };
    final double animationSpeed = double.tryParse(campaign['svg_animation_speed']?.toString() ?? '1.0') ?? 1.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showConsultationDialog(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Vector Dynamic SVG Canvas (Underlay)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: AnimatedSvgPainter(
                      progress: (_animationController.value * animationSpeed) % 1.0,
                    ),
                    size: Size.infinite,
                  );
                },
              ),

              // Elegant Glassmorphic Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        GomandapTokens.royalNavy.withValues(alpha: 0.85),
                        GomandapTokens.royalNavy.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // UI Text and Interactive Labels
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.5)),
                          ),
                          child: const Text(
                            'SPONSORED ELITE 👑',
                            style: TextStyle(
                              color: GomandapTokens.champagneGoldEnd,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: GomandapTokens.champagneGoldStart,
                          size: 20,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      campaign['title']?.toString() ?? 'GoMandap Elite Events',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      campaign['description']?.toString() ?? 'Crafting grand memories, managing full sangeet packages, sound setups & catering.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Get 25% Off Full Sangeet Planning',
                          style: TextStyle(
                            color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.95),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [GomandapTokens.champagneGoldStart, GomandapTokens.champagneGoldEnd],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                campaign['action_label']?.toString() ?? 'Book Consult',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConsultationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.celebration_rounded, color: GomandapTokens.champagneGoldStart),
              SizedBox(width: 10),
              Text(
                'Book Consultation',
                style: TextStyle(fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
              ),
            ],
          ),
          content: const Text(
            'Connect with GoMandap Elite Event managers to co-create your Sangeet, Haldi, or reception details. Get custom mock packages with full escrow safety guarantee.',
            style: TextStyle(fontSize: 13, height: 1.45, color: GomandapTokens.royalNavy),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later', style: TextStyle(fontWeight: FontWeight.w700, color: GomandapTokens.slateGray)),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request logged successfully! Our Elite Event Planner will dial you back in 15 mins 📞'),
                    backgroundColor: GomandapTokens.emeraldGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GomandapTokens.royalNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Register Call', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── High-Fidelity Custom Animated SVG Vector Painter ──────────────────────────

class AnimatedSvgPainter extends CustomPainter {
  final double progress;

  AnimatedSvgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Royal Navy base gradient
    final Paint bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [GomandapTokens.royalNavy, Color(0xFF1E293B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 2. Draw Golden rising dome arch
    final double archProg = (progress * 1.5).clamp(0.0, 1.0);
    final Paint archPaint = Paint()
      ..shader = const LinearGradient(
        colors: [GomandapTokens.champagneGoldStart, GomandapTokens.champagneGoldEnd],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final Path archPath = Path();
    archPath.moveTo(size.width * 0.1, size.height * 0.9);
    // Draw parabolic dome curve
    archPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * (-0.1),
      size.width * 0.9,
      size.height * 0.9,
    );

    // Animate arch opening stroke-dash effect
    final PathMetric metric = archPath.computeMetrics().first;
    final Path extract = metric.extractPath(0, metric.length * archProg);
    canvas.drawPath(extract, archPaint);

    // 3. Draw Dancers silhouette rotating dynamically
    final double rotateAngle = math.sin(progress * 2 * math.pi) * 0.08;
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.55);
    canvas.rotate(rotateAngle);

    // Draw bride dress (emerald green)
    final Paint bridePaint = Paint()
      ..color = GomandapTokens.emeraldGreen.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final Path bridePath = Path();
    bridePath.moveTo(-15, 30);
    bridePath.quadraticBezierTo(-8, -10, 0, -20);
    bridePath.quadraticBezierTo(8, -10, 15, 30);
    bridePath.close();
    canvas.drawPath(bridePath, bridePaint);

    // Draw groom (gold suit)
    final Paint groomPaint = Paint()
      ..color = GomandapTokens.champagneGoldStart.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    const Rect groomRect = Rect.fromLTWH(-5, -20, 10, 50);
    canvas.drawRect(groomRect, groomPaint);

    canvas.restore();

    // 4. Draw Twinkling Gold / White sparkles flashing
    final Paint sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: math.sin(progress * math.pi * 3).abs() * 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 3, sparklePaint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.35), 4, sparklePaint);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.2), 2.5, sparklePaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.25), 3.5, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant AnimatedSvgPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
