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

  StoryProgressIndicator(
    this.value, {
    required this.isRtl,
    this.indicatorHeight = 5,
    this.indicatorColor,
    this.indicatorForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromHeight(this.indicatorHeight),
      foregroundPainter: IndicatorOval(
        color:
            this.indicatorForegroundColor ??
            Colors.white.withValues(alpha: 0.8),
        widthFactor: this.value,
        isRtl: isRtl,
      ),
      painter: IndicatorOval(
        color: this.indicatorColor ?? Colors.white.withValues(alpha: 0.4),
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
    final paint = Paint()..color = this.color;
    final double dx = isRtl ? size.width * (1 - widthFactor) : 0.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(dx, 0, size.width * this.widthFactor, size.height),
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
