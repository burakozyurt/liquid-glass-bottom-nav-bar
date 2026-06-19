import 'dart:ui' show Color, lerpDouble;

import 'package:flutter/foundation.dart';

/// The Liquid Glass material variant, mirroring Apple's two named materials.
enum GlassVariant {
  /// The default, most versatile material. Fully adaptive to the content
  /// behind it. Used for navigation and controls — this is what the bar uses.
  regular,

  /// A permanently more transparent material for media-rich contexts. Needs a
  /// dimming layer for legibility; use sparingly.
  clear,

  /// Forces the [BackdropFilter]-based fallback rendering path regardless of
  /// shader support. Useful for testing or to opt out of the shader entirely.
  forcedFallback,
}

/// Immutable visual + physical tuning for the Liquid Glass material.
///
/// Every constant Apple has not published (bevel depth, IOR, dispersion, light
/// angle, …) is exposed here so the look can be tuned empirically against real
/// iOS 26 recordings. Defaults are sensible starting points.
@immutable
class LiquidGlassSettings {
  /// Creates a tuning configuration. All values have Apple-flavored defaults.
  const LiquidGlassSettings({
    this.thickness = 6.0,
    this.blur = 2.0,
    this.refractiveIndex = 1.5,
    this.lightAngle = -0.785398, // -45° (top-left), in radians
    this.lightIntensity = 0.3, // subtle edge highlight; raise for more sheen
    this.ambientStrength = 0.3,
    this.glassColor = const Color(0x1AFFFFFF),
    this.saturation = 1.5,
    this.chromaticAberration = 0.0,
    this.outlineIntensity = 0.6,
    this.blend = 24.0,
    this.variant = GlassVariant.regular,
    this.tiltHighlight = false,
    this.reduceTransparency = false,
    this.cornerRadius,
  }) : assert(thickness >= 0),
       assert(blur >= 0),
       assert(refractiveIndex >= 1.0),
       assert(saturation >= 0),
       assert(blend >= 0);

  /// Bevel depth. Drives edge displacement, shadow depth and the dome height
  /// together so a single value reads as a thicker or thinner pane of glass.
  final double thickness;

  /// Gaussian frost sigma applied to the backdrop. Keep modest (~5, < 10).
  final double blur;

  /// Index of refraction used for the Snell-law edge displacement (~1.5 glass).
  final double refractiveIndex;

  /// Direction of the virtual light source, in radians. Default top-left.
  final double lightAngle;

  /// Strength of the specular highlight.
  final double lightIntensity;

  /// Strength of the flat ambient term that keeps the body from going dark.
  final double ambientStrength;

  /// Tint color of the glass. Its alpha channel is the tint strength.
  final Color glassColor;

  /// Vibrancy multiplier applied to the blurred backdrop (Apple ~1.4–1.8×).
  final double saturation;

  /// Edge color-fringing intensity (0 disables it; forced to 0 during
  /// animation and on low-tier devices for performance).
  final double chromaticAberration;

  /// Strength of the Fresnel rim/edge highlight stroke.
  final double outlineIntensity;

  /// Smooth-min radius used to coalesce neighbouring glass shapes (the
  /// metaball threshold). Larger values merge shapes sooner.
  final double blend;

  /// Which Liquid Glass material variant to render.
  final GlassVariant variant;

  /// Whether to shift the highlight with device tilt (opt-in; needs
  /// `sensors_plus` and is disabled when motion is reduced).
  final bool tiltHighlight;

  /// App-level request to drop transparency entirely (there is no
  /// cross-platform `MediaQuery` flag for this). Forces the solid fallback.
  final bool reduceTransparency;

  /// Corner radius of the bar. When null the bar is a full capsule
  /// (radius == height / 2).
  final double? cornerRadius;

  /// Whether the resolved configuration should never attempt the shader path.
  bool get prefersFallback => reduceTransparency || variant == GlassVariant.forcedFallback;

  /// Returns a copy with the given fields replaced.
  LiquidGlassSettings copyWith({
    double? thickness,
    double? blur,
    double? refractiveIndex,
    double? lightAngle,
    double? lightIntensity,
    double? ambientStrength,
    Color? glassColor,
    double? saturation,
    double? chromaticAberration,
    double? outlineIntensity,
    double? blend,
    GlassVariant? variant,
    bool? tiltHighlight,
    bool? reduceTransparency,
    double? cornerRadius,
  }) {
    return LiquidGlassSettings(
      thickness: thickness ?? this.thickness,
      blur: blur ?? this.blur,
      refractiveIndex: refractiveIndex ?? this.refractiveIndex,
      lightAngle: lightAngle ?? this.lightAngle,
      lightIntensity: lightIntensity ?? this.lightIntensity,
      ambientStrength: ambientStrength ?? this.ambientStrength,
      glassColor: glassColor ?? this.glassColor,
      saturation: saturation ?? this.saturation,
      chromaticAberration: chromaticAberration ?? this.chromaticAberration,
      outlineIntensity: outlineIntensity ?? this.outlineIntensity,
      blend: blend ?? this.blend,
      variant: variant ?? this.variant,
      tiltHighlight: tiltHighlight ?? this.tiltHighlight,
      reduceTransparency: reduceTransparency ?? this.reduceTransparency,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  /// Linearly interpolates between two configurations.
  ///
  /// Non-numeric fields ([variant], [tiltHighlight], [reduceTransparency])
  /// snap at the midpoint.
  static LiquidGlassSettings lerp(LiquidGlassSettings a, LiquidGlassSettings b, double t) {
    if (identical(a, b)) return a;
    return LiquidGlassSettings(
      thickness: lerpDouble(a.thickness, b.thickness, t)!,
      blur: lerpDouble(a.blur, b.blur, t)!,
      refractiveIndex: lerpDouble(a.refractiveIndex, b.refractiveIndex, t)!,
      lightAngle: lerpDouble(a.lightAngle, b.lightAngle, t)!,
      lightIntensity: lerpDouble(a.lightIntensity, b.lightIntensity, t)!,
      ambientStrength: lerpDouble(a.ambientStrength, b.ambientStrength, t)!,
      glassColor: Color.lerp(a.glassColor, b.glassColor, t)!,
      saturation: lerpDouble(a.saturation, b.saturation, t)!,
      chromaticAberration: lerpDouble(a.chromaticAberration, b.chromaticAberration, t)!,
      outlineIntensity: lerpDouble(a.outlineIntensity, b.outlineIntensity, t)!,
      blend: lerpDouble(a.blend, b.blend, t)!,
      variant: t < 0.5 ? a.variant : b.variant,
      tiltHighlight: t < 0.5 ? a.tiltHighlight : b.tiltHighlight,
      reduceTransparency: t < 0.5 ? a.reduceTransparency : b.reduceTransparency,
      cornerRadius: lerpDouble(a.cornerRadius, b.cornerRadius, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LiquidGlassSettings &&
        other.thickness == thickness &&
        other.blur == blur &&
        other.refractiveIndex == refractiveIndex &&
        other.lightAngle == lightAngle &&
        other.lightIntensity == lightIntensity &&
        other.ambientStrength == ambientStrength &&
        other.glassColor == glassColor &&
        other.saturation == saturation &&
        other.chromaticAberration == chromaticAberration &&
        other.outlineIntensity == outlineIntensity &&
        other.blend == blend &&
        other.variant == variant &&
        other.tiltHighlight == tiltHighlight &&
        other.reduceTransparency == reduceTransparency &&
        other.cornerRadius == cornerRadius;
  }

  @override
  int get hashCode => Object.hash(
    thickness,
    blur,
    refractiveIndex,
    lightAngle,
    lightIntensity,
    ambientStrength,
    glassColor,
    saturation,
    chromaticAberration,
    outlineIntensity,
    blend,
    variant,
    tiltHighlight,
    reduceTransparency,
    cornerRadius,
  );
}
