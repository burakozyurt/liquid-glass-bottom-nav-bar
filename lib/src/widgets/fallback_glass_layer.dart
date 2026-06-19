import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../accessibility/a11y_resolver.dart';
import '../models/liquid_glass_settings.dart';

/// The universal, Impeller-free glass body: a clipped [BackdropFilter] blur
/// with a saturation boost, a translucent tint and a faint top sheen. Renders
/// [child] (the bar contents) on top. Refraction is not possible here — this is
/// the honest frosted-glass approximation used everywhere the shader path is
/// unavailable.
class FallbackGlassLayer extends StatelessWidget {
  /// Creates a fallback glass body.
  const FallbackGlassLayer({
    super.key,
    required this.borderRadius,
    required this.settings,
    required this.a11y,
    required this.child,
  });

  /// Corner radius / capsule shape of the body.
  final BorderRadius borderRadius;

  /// Visual tuning.
  final LiquidGlassSettings settings;

  /// Resolved accessibility decisions.
  final ResolvedA11y a11y;

  /// The bar contents drawn above the glass.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduce = a11y.reduceTransparency;
    final blurSigma = reduce ? 0.0 : settings.blur;
    final saturation = reduce ? 1.0 : settings.saturation;

    final filter = ui.ImageFilter.compose(
      outer: ui.ColorFilter.matrix(_saturationMatrix(saturation)),
      inner: ui.ImageFilter.blur(
        sigmaX: blurSigma,
        sigmaY: blurSigma,
        tileMode: TileMode.mirror,
      ),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: filter,
              child: ColoredBox(color: _tint(reduce)),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x14FFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Color _tint(bool reduce) {
    if (reduce) {
      final isDark = a11y.platformBrightness == Brightness.dark;
      return isDark ? const Color(0xF21C1C1E) : const Color(0xF2FFFFFF);
    }
    return settings.glassColor;
  }

  /// Standard luminance-preserving saturation matrix (4×5, row-major).
  static List<double> _saturationMatrix(double s) {
    const lr = 0.2126, lg = 0.7152, lb = 0.0722;
    final sr = (1 - s) * lr;
    final sg = (1 - s) * lg;
    final sb = (1 - s) * lb;
    return <double>[
      sr + s, sg, sb, 0, 0, //
      sr, sg + s, sb, 0, 0, //
      sr, sg, sb + s, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
  }
}
