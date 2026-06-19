import 'package:flutter/widgets.dart';

import '../models/liquid_glass_settings.dart';

/// The accessibility decisions distilled from [MediaQueryData] + settings.
///
/// Pure value object so the render and animation layers never touch
/// [MediaQuery] directly and the resolution logic stays unit-testable.
@immutable
class ResolvedA11y {
  /// Creates a resolved accessibility configuration.
  const ResolvedA11y({
    required this.disableAnimations,
    required this.highContrast,
    required this.reduceTransparency,
    required this.platformBrightness,
    required this.textScaler,
  });

  /// When true, elastic/liquid motion, highlight travel and tilt are disabled
  /// and springs settle instantly/critically.
  final bool disableAnimations;

  /// When true, borders and outlines are strengthened and tint is more opaque.
  final bool highContrast;

  /// When true, the bar forces the solid fallback fill (no refraction).
  final bool reduceTransparency;

  /// The ambient platform brightness, used as the tint/legibility baseline.
  final Brightness platformBrightness;

  /// The text scaler applied to labels.
  final TextScaler textScaler;

  @override
  bool operator ==(Object other) =>
      other is ResolvedA11y &&
      other.disableAnimations == disableAnimations &&
      other.highContrast == highContrast &&
      other.reduceTransparency == reduceTransparency &&
      other.platformBrightness == platformBrightness &&
      other.textScaler == textScaler;

  @override
  int get hashCode => Object.hash(
    disableAnimations,
    highContrast,
    reduceTransparency,
    platformBrightness,
    textScaler,
  );
}

/// Resolves platform accessibility state + package settings into a
/// [ResolvedA11y]. Stateless and pure.
abstract final class A11yResolver {
  /// Combines [media] with [settings]. [settings.reduceTransparency] is an
  /// app-level request OR'd with any future platform signal.
  static ResolvedA11y resolve(
    MediaQueryData media,
    LiquidGlassSettings settings,
  ) {
    return ResolvedA11y(
      disableAnimations: media.disableAnimations,
      highContrast: media.highContrast,
      reduceTransparency: settings.reduceTransparency,
      platformBrightness: media.platformBrightness,
      textScaler: media.textScaler,
    );
  }
}
