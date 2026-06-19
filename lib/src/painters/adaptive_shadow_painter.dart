import 'package:flutter/widgets.dart';

/// Paints the soft drop shadow that makes the glass appear to float.
///
/// [opacity] is expected to be driven by backdrop "busyness" (more opaque over
/// text/detail, lighter over flat surfaces). M1 passes a sensible constant;
/// the adaptive computation lands in M6.
class AdaptiveShadowPainter extends CustomPainter {
  /// Creates a shadow painter.
  AdaptiveShadowPainter({
    required this.borderRadius,
    required this.opacity,
    this.blurSigma = 16.0,
    this.offset = const Offset(0, 6),
    this.color = const Color(0xFF000000),
  });

  /// Corner radius of the casting shape.
  final BorderRadius borderRadius;

  /// Shadow opacity (0..1).
  final double opacity;

  /// Gaussian blur sigma of the shadow.
  final double blurSigma;

  /// Offset of the shadow from the shape.
  final Offset offset;

  /// Base shadow color (its alpha is replaced by [opacity]).
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final rrect = borderRadius.toRRect(Offset.zero & size).shift(offset);
    final paint = Paint()
      ..color = color.withValues(alpha: opacity.clamp(0.0, 1.0))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(AdaptiveShadowPainter oldDelegate) =>
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.opacity != opacity ||
      oldDelegate.blurSigma != blurSigma ||
      oldDelegate.offset != offset ||
      oldDelegate.color != color;
}
