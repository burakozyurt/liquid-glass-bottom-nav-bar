import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// A single SDF shape contributed to the shared glass field. Coordinates are in
/// the bar's local logical space; [LiquidGlassUniforms] scales them to device
/// pixels when packing.
@immutable
class GlassShape {
  /// Creates a shape from its centre, half-extents and corner radius.
  const GlassShape({
    required this.center,
    required this.halfExtent,
    required this.cornerRadius,
    this.kind = 0,
  });

  /// Rounded-rectangle shape covering [rect] with [radius] corners.
  factory GlassShape.roundedRect(Rect rect, double radius) => GlassShape(
    center: rect.center,
    halfExtent: Size(rect.width / 2, rect.height / 2),
    cornerRadius: radius,
  );

  /// Capsule (pill) shape covering [rect] — corner radius is half the shorter
  /// side.
  factory GlassShape.capsule(Rect rect) =>
      GlassShape.roundedRect(rect, math.min(rect.width, rect.height) / 2);

  /// Centre of the shape, local logical coordinates.
  final Offset center;

  /// Half-extents (half width/height) of the shape's bounding box.
  final Size halfExtent;

  /// Corner radius.
  final double cornerRadius;

  /// Shape family discriminator (reserved; 0 == rounded box).
  final int kind;

  @override
  bool operator ==(Object other) =>
      other is GlassShape &&
      other.center == center &&
      other.halfExtent == halfExtent &&
      other.cornerRadius == cornerRadius &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(center, halfExtent, cornerRadius, kind);
}
