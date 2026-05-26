import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gomandap_tokens.dart';

class AntigravityRangeSlider extends StatefulWidget {
  final double min;
  final double max;
  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;
  final String Function(double) labelFormatter;

  const AntigravityRangeSlider({
    super.key,
    required this.min,
    required this.max,
    required this.values,
    required this.onChanged,
    required this.labelFormatter,
  });

  @override
  State<AntigravityRangeSlider> createState() => _AntigravityRangeSliderState();
}

class _AntigravityRangeSliderState extends State<AntigravityRangeSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _scaleAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onDragStart() {
    setState(() => _isDragging = true);
    _springController.forward();
    HapticFeedback.lightImpact();
  }

  void _onDragEnd() {
    setState(() => _isDragging = false);
    _springController.reverse();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Floating Info Badges
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Range Selector',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: GomandapTokens.slateGray,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedScale(
                  scale: _isDragging ? 1.03 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Text(
                    '${widget.labelFormatter(widget.values.start)} - ${widget.labelFormatter(widget.values.end)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: GomandapTokens.royalNavy,
                    ),
                  ),
                ),
              ],
            ),
            if (_isDragging)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 12, color: GomandapTokens.champagneGoldEnd),
                    const SizedBox(width: 4),
                    Text(
                      'Live Updating',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: GomandapTokens.champagneGoldEnd,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Custom Slider Container
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: GomandapTokens.emeraldGreen,
            inactiveTrackColor: GomandapTokens.softMist,
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
            rangeThumbShape: AntigravityRangeThumbShape(
              scaleAnimation: _scaleAnimation,
              isDragging: _isDragging,
            ),
            rangeTrackShape: const AntigravityRangeTrackShape(),
          ),
          child: RangeSlider(
            values: widget.values,
            min: widget.min,
            max: widget.max,
            onChanged: (newValues) {
              if (!_isDragging) _onDragStart();
              widget.onChanged(newValues);
            },
            onChangeStart: (_) => _onDragStart(),
            onChangeEnd: (_) => _onDragEnd(),
          ),
        ),
      ],
    );
  }
}

class AntigravityRangeThumbShape extends RangeSliderThumbShape {
  final Animation<double> scaleAnimation;
  final bool isDragging;

  const AntigravityRangeThumbShape({
    required this.scaleAnimation,
    required this.isDragging,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(24, 24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop = false,
    TextDirection? textDirection,
    required SliderThemeData sliderTheme,
    Thumb? thumb,
    bool isPressed = false,
  }) {
    final Canvas canvas = context.canvas;

    final double scale = isPressed ? scaleAnimation.value : 1.0;
    final double radius = 10.0 * scale;

    // Premium outer ring shadow
    final Paint shadowPaint = Paint()
      ..color = GomandapTokens.royalNavy.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center + const Offset(0, 3), radius, shadowPaint);

    // Premium Gold border
    final Paint borderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [GomandapTokens.champagneGoldStart, GomandapTokens.champagneGoldEnd],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, borderPaint);

    // Innermost white core
    final Paint corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2.5, corePaint);

    // Small active emerald center node
    final Paint activeNodePaint = Paint()
      ..color = GomandapTokens.emeraldGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 6.5, activeNodePaint);
  }
}

class AntigravityRangeTrackShape extends RangeSliderTrackShape {
  const AntigravityRangeTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = true,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 6;
    final double trackLeft = offset.dx + 12;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 24;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset startThumbCenter,
    required Offset endThumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final Canvas canvas = context.canvas;
    // Draw inactive track
    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? GomandapTokens.softMist
      ..style = PaintingStyle.fill;

    // Draw active track with beautiful premium gradient
    final Paint activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [GomandapTokens.emeraldGreen, GomandapTokens.emeraldGreenDark],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(trackRect(parentBox, offset, sliderTheme, isEnabled, isDiscrete))
      ..style = PaintingStyle.fill;

    final Rect trackRectVal = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final RRect leftInactive = RRect.fromLTRBAndCorners(
      trackRectVal.left,
      trackRectVal.top,
      startThumbCenter.dx,
      trackRectVal.bottom,
      topLeft: const Radius.circular(3),
      bottomLeft: const Radius.circular(3),
    );
    canvas.drawRRect(leftInactive, inactivePaint);

    final RRect active = RRect.fromLTRBAndCorners(
      startThumbCenter.dx,
      trackRectVal.top,
      endThumbCenter.dx,
      trackRectVal.bottom,
    );
    canvas.drawRRect(active, activePaint);

    final RRect rightInactive = RRect.fromLTRBAndCorners(
      endThumbCenter.dx,
      trackRectVal.top,
      trackRectVal.right,
      trackRectVal.bottom,
      topRight: const Radius.circular(3),
      bottomRight: const Radius.circular(3),
    );
    canvas.drawRRect(rightInactive, inactivePaint);
  }

  Rect trackRect(
    RenderBox parentBox,
    Offset offset,
    SliderThemeData sliderTheme,
    bool isEnabled,
    bool isDiscrete,
  ) {
    return getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
  }
}
