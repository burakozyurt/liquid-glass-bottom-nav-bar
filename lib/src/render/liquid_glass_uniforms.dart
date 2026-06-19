import 'dart:ui' as ui;

import '../models/liquid_glass_settings.dart';
import 'glass_field.dart';

/// The single source of truth for the fragment shader's uniform layout.
///
/// `liquid_glass.frag` declares, in order: `vec2 uSize` (floats 0–1, set by the
/// engine for `ImageFilter.shader`), then the floats packed here from index 2,
/// then `float uShapeData[48]`, for [floatCount] floats total. The packing
/// walks a running index and asserts it lands exactly on [floatCount] so the
/// Dart and GLSL sides can never silently drift (see uniform_packing_test).
///
/// Geometry coordinate space: when a fragment shader is used as a
/// [ui.ImageFilter.shader] in a `BackdropFilter`, `FlutterFragCoord()` and
/// `uSize` cover the **whole backdrop** (≈ the screen), not the bar — so the
/// bar's local shapes would never line up. To stay independent of both the
/// device pixel ratio and that origin, geometry is packed as a *fraction* of
/// the backdrop: the bar's local shapes are shifted by its on-screen [origin]
/// and divided by the screen size here, and the shader rebuilds pixels with
/// `fraction * uSize`.
abstract final class LiquidGlassUniforms {
  /// Maximum number of SDF shapes the shader blends in one pass.
  static const int kMaxShapes = 8;

  /// Number of floats per shape: kind, cx, cy, halfW, halfH, cornerR.
  static const int floatsPerShape = 6;

  /// First float index the packer writes (0–1 are `uSize`, set by the engine).
  static const int firstWritableIndex = 2;

  /// Total float uniform count declared by the shader.
  static const int floatCount =
      17 + kMaxShapes * floatsPerShape; // uSize + 15 scalars (17) + 48 = 65

  /// Packs [field] + [settings] into [shader] as backdrop fractions.
  ///
  /// [origin] is the bar's top-left in the backdrop's coordinate space (its
  /// global on-screen offset) and [screen] is the backdrop (screen) size; both
  /// in the same logical units. Lengths along x are divided by [screen.width]
  /// and along y by [screen.height] (the per-axis ratio is identical, so scalar
  /// lengths use the width). See the class doc for why.
  static void pack(
    ui.FragmentShader shader,
    GlassField field,
    LiquidGlassSettings settings,
    ui.Offset origin,
    ui.Size screen,
  ) => packInto(shader.setFloat, field, settings, origin, screen);

  /// Same as [pack] but writes through a [setFloat] callback so the layout can
  /// be unit tested without a real shader (see uniform_packing_test).
  static void packInto(
    void Function(int index, double value) setFloat,
    GlassField field,
    LiquidGlassSettings settings,
    ui.Offset origin,
    ui.Size screen,
  ) {
    final sx = screen.width <= 0 ? 1.0 : screen.width;
    final sy = screen.height <= 0 ? 1.0 : screen.height;

    var i = firstWritableIndex;
    void f(double v) => setFloat(i++, v);

    f(settings.thickness / sx); // 2  uThickness (fraction of width)
    f(settings.refractiveIndex); // 3  uRefractiveIndex
    f(settings.lightAngle); // 4  uLightAngle
    f(settings.lightIntensity); // 5  uLightIntensity
    f(settings.ambientStrength); // 6  uAmbient

    final c = settings.glassColor;
    f(c.r); // 7
    f(c.g); // 8
    f(c.b); // 9
    f(c.a); // 10  uGlassColor

    f(settings.saturation); // 11
    f(settings.outlineIntensity); // 12
    f(settings.chromaticAberration); // 13
    f(field.shapes.length.toDouble()); // 14  uShapeCount
    f(settings.blend / sx); // 15  uBlend (fraction of width)
    f(settings.blur / sx); // 16  uBlur (frosted radius, fraction of width)

    for (var s = 0; s < kMaxShapes; s++) {
      if (s < field.shapes.length) {
        final shape = field.shapes[s];
        f(shape.kind.toDouble());
        f((origin.dx + shape.center.dx) / sx); // backdrop-relative fraction
        f((origin.dy + shape.center.dy) / sy);
        f(shape.halfExtent.width / sx);
        f(shape.halfExtent.height / sy);
        f(shape.cornerRadius / sx);
      } else {
        f(0);
        f(0);
        f(0);
        f(0);
        f(0);
        f(0);
      }
    }

    assert(
      i == floatCount,
      'Uniform packing drifted: wrote $i floats, expected $floatCount.',
    );
  }
}
