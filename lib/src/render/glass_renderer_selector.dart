import 'package:flutter/widgets.dart';

import '../accessibility/a11y_resolver.dart';
import '../models/liquid_glass_settings.dart';
import 'device_tier.dart';
import 'glass_capabilities.dart';

/// Which rendering strategy the bar uses.
enum GlassRenderPath {
  /// Hand-rolled fragment shader over a snapshotted backdrop (Impeller).
  shader,

  /// `BackdropFilter` + blur frosted approximation (works everywhere).
  fallback,
}

/// Resolves and propagates the active [GlassRenderPath] down the tree.
///
/// The decision combines engine capability, device tier, accessibility and the
/// requested settings. It is computed once near the top of the bar and exposed
/// via [of] so sub-widgets pick the matching layer.
class GlassRendererSelector extends InheritedWidget {
  /// Wraps [child], advertising the resolved [path].
  const GlassRendererSelector({
    super.key,
    required this.path,
    required super.child,
  });

  /// The resolved path for this subtree.
  final GlassRenderPath path;

  /// The shader path is implemented from milestone M2 onward.
  static const bool _shaderPathImplemented = true;

  /// Resolves the path from capability + tier + accessibility + settings.
  static GlassRenderPath resolve({
    required ResolvedA11y a11y,
    required LiquidGlassSettings settings,
  }) {
    final canUseShader =
        _shaderPathImplemented &&
        GlassCapabilities.supportsShaderFilter &&
        DeviceTier.current.allowsShader &&
        !a11y.reduceTransparency &&
        !settings.prefersFallback;
    final path = canUseShader
        ? GlassRenderPath.shader
        : GlassRenderPath.fallback;
    assert(() {
      _debugLogPath(path, a11y, settings);
      return true;
    }());
    return path;
  }

  // Debug-only: explain the path decision once (deduped) so a silent drop to
  // the fallback is diagnosable. Compiled out of release builds via `assert`.
  static String? _lastLoggedPath;

  static void _debugLogPath(
    GlassRenderPath path,
    ResolvedA11y a11y,
    LiquidGlassSettings settings,
  ) {
    final reasons = <String>[
      if (!_shaderPathImplemented) 'shader path not implemented',
      if (!GlassCapabilities.supportsShaderFilter)
        'ImageFilter.shader unsupported (Impeller disabled?)',
      if (!DeviceTier.current.allowsShader) 'device tier is low',
      if (a11y.reduceTransparency) 'reduceTransparency is on',
      if (settings.prefersFallback) 'settings force the fallback',
    ];
    final message = path == GlassRenderPath.shader
        ? 'LiquidGlass: render path = shader (refraction active)'
        : 'LiquidGlass: render path = fallback — ${reasons.join(', ')}';
    if (message == _lastLoggedPath) return;
    _lastLoggedPath = message;
    debugPrint(message);
  }

  /// The active path for [context], defaulting to [GlassRenderPath.fallback].
  static GlassRenderPath of(BuildContext context) {
    final selector = context
        .dependOnInheritedWidgetOfExactType<GlassRendererSelector>();
    return selector?.path ?? GlassRenderPath.fallback;
  }

  @override
  bool updateShouldNotify(GlassRendererSelector oldWidget) =>
      oldWidget.path != path;
}
