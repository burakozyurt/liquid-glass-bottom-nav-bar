import 'package:flutter/widgets.dart';

import '../accessibility/a11y_resolver.dart';
import '../models/liquid_glass_settings.dart';
import 'glass_field_layer.dart';

/// A standalone Liquid Glass surface (shadow + glass body + specular rim) that
/// sizes itself to [child]. Use it to build panels, mini-players or buttons
/// that match the bar's material. Mirrors the bar's fallback chrome so custom
/// surfaces stay visually consistent.
class FakeGlass extends StatelessWidget {
  /// Wraps [child] in a glass surface.
  const FakeGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.settings = const LiquidGlassSettings(),
  });

  /// Content rendered above the glass.
  final Widget child;

  /// Corner radius of the surface.
  final BorderRadius borderRadius;

  /// Visual tuning of the glass.
  final LiquidGlassSettings settings;

  @override
  Widget build(BuildContext context) {
    final a11y = A11yResolver.resolve(MediaQuery.of(context), settings);
    return GlassFieldLayer(
      borderRadius: borderRadius,
      settings: settings,
      a11y: a11y,
      child: child,
    );
  }
}
