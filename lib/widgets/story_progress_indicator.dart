import 'package:flutter/material.dart';

/// Custom progress bar. Supposed to be lighter than the
/// original [ProgressIndicator], and rounded at the sides.
class StoryProgressIndicator extends StatelessWidget {
  /// From `0.0` to `1.0`, determines the progress of the indicator
  final double value;
  final double indicatorHeight;
  final Color? indicatorColor;
  final Color? indicatorForegroundColor;
  final bool isRtl;

  const StoryProgressIndicator(
    this.value, {
    super.key,
    required this.isRtl,
    this.indicatorHeight = 5,
    this.indicatorColor,
    this.indicatorForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(indicatorHeight),
      foregroundPainter: IndicatorOval(
        color: indicatorForegroundColor ?? Colors.white.withValues(alpha: 0.8),
        widthFactor: value,
        isRtl: isRtl,
      ),
      painter: IndicatorOval(
        color: indicatorColor ?? Colors.white.withValues(alpha: 0.4),
        widthFactor: 1.0,
        isRtl: isRtl,
      ),
    );
  }
}

class IndicatorOval extends CustomPainter {
  final Color color;
  final double widthFactor;
  final bool isRtl;

  IndicatorOval({
    required this.color,
    required this.widthFactor,
    required this.isRtl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final double dx = isRtl ? size.width * (1 - widthFactor) : 0.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(dx, 0, size.width * widthFactor, size.height),
        Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
