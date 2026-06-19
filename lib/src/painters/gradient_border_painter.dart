import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Paints the 1px Fresnel/specular rim of the glass: a gradient stroke that is
/// brightest where the virtual light hits the edge and fades to the opposite
/// side. Shared by both the shader and fallback paths.
class GradientBorderPainter extends CustomPainter {
  /// Creates a rim painter.
  GradientBorderPainter({
    required this.borderRadius,
    required this.lightAngle,
    required this.intensity,
    required this.highContrast,
    this.strokeWidth = 1.0,
  });

  /// Corner radius of the glass shape.
  final BorderRadius borderRadius;

  /// Direction of the virtual light, in radians.
  final double lightAngle;

  /// Rim strength (0..1-ish).
  final double intensity;

  /// When true, the rim is opaque and uniform for legibility.
  final bool highContrast;

  /// Stroke width of the rim.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect).deflate(strokeWidth / 2);

    if (highContrast) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 0.5
        ..color = const Color(0xCCFFFFFF);
      canvas.drawRRect(rrect, paint);
      return;
    }

    final dx = math.cos(lightAngle);
    final dy = math.sin(lightAngle);
    final bright = (0.65 * intensity).clamp(0.0, 1.0);
    final dim = (0.10 * intensity).clamp(0.0, 1.0);

    final gradient = LinearGradient(
      begin: Alignment(-dx, -dy),
      end: Alignment(dx, dy),
      colors: [
        Color.fromRGBO(255, 255, 255, bright),
        Color.fromRGBO(255, 255, 255, dim),
        Color.fromRGBO(255, 255, 255, bright * 0.4),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(GradientBorderPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.lightAngle != lightAngle ||
      oldDelegate.intensity != intensity ||
      oldDelegate.highContrast != highContrast ||
      oldDelegate.strokeWidth != strokeWidth;
}
