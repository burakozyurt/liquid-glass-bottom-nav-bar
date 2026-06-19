import 'package:flutter/widgets.dart';

import '../accessibility/a11y_resolver.dart';
import '../models/liquid_glass_settings.dart';
import '../painters/adaptive_shadow_painter.dart';
import '../painters/gradient_border_painter.dart';
import '../render/glass_field.dart';
import '../render/glass_renderer_selector.dart';
import '../render/shader_glass_layer.dart';
import 'fallback_glass_layer.dart';

/// Hosts the shared glass body for the bar: an adaptive drop shadow beneath,
/// the resolved glass layer (shader or fallback) in the middle, and the
/// specular rim on top. [child] is the bar contents (pill + items) that ride
/// above the glass.
///
/// In M1 only the fallback path is wired; the shader path is added in M2.
class GlassFieldLayer extends StatelessWidget {
  /// Creates the field layer.
  const GlassFieldLayer({
    super.key,
    required this.borderRadius,
    required this.settings,
    required this.a11y,
    required this.child,
    this.field,
  });

  /// Shape of the glass body.
  final BorderRadius borderRadius;

  /// The SDF field sampled by the shader path. When null the shader path is
  /// skipped (the fallback is used) — e.g. for [FakeGlass], which wraps content
  /// of unknown size.
  final GlassField? field;

  /// Visual tuning.
  final LiquidGlassSettings settings;

  /// Resolved accessibility decisions.
  final ResolvedA11y a11y;

  /// Bar contents drawn above the glass.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final field = this.field;
    final useShader =
        field != null &&
        GlassRendererSelector.of(context) == GlassRenderPath.shader;

    final Widget glassBody = useShader
        ? ShaderGlassLayer(
            borderRadius: borderRadius,
            field: field,
            settings: settings,
            a11y: a11y,
            child: child,
          )
        : FallbackGlassLayer(
            borderRadius: borderRadius,
            settings: settings,
            a11y: a11y,
            child: child,
          );

    final shadowOpacity = a11y.highContrast ? 0.10 : 0.20;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: AdaptiveShadowPainter(
                borderRadius: borderRadius,
                opacity: shadowOpacity,
              ),
            ),
          ),
        ),
        glassBody,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: GradientBorderPainter(
                borderRadius: borderRadius,
                lightAngle: settings.lightAngle,
                intensity: settings.outlineIntensity,
                highContrast: a11y.highContrast,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
