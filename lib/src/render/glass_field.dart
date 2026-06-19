import 'package:flutter/foundation.dart';

import 'glass_shape.dart';
import 'liquid_glass_uniforms.dart';

/// The set of SDF shapes that share one shader pass, blended by [blend] (the
/// smooth-min radius). Keeping the bar, selection pill, accessory and search
/// field in one field is what lets them coalesce/separate like liquid.
@immutable
class GlassField {
  /// Creates a field from [shapes] (at most [LiquidGlassUniforms.kMaxShapes]).
  const GlassField({required this.shapes, required this.blend})
    : assert(
        shapes.length <= LiquidGlassUniforms.kMaxShapes,
        'At most ${LiquidGlassUniforms.kMaxShapes} shapes are supported.',
      );

  /// The active shapes (first one is the base bar).
  final List<GlassShape> shapes;

  /// Smooth-min radius in logical pixels (the metaball threshold).
  final double blend;

  @override
  bool operator ==(Object other) =>
      other is GlassField &&
      listEquals(other.shapes, shapes) &&
      other.blend == blend;

  @override
  int get hashCode => Object.hash(Object.hashAll(shapes), blend);
}
