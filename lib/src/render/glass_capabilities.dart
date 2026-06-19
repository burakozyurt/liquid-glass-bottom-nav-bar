import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

/// Probes whether the current engine can run fragment-shader image filters
/// (Impeller-only). Cached after the first query.
abstract final class GlassCapabilities {
  static bool? _cached;

  /// Whether `ImageFilter.shader`-based rendering is supported.
  static bool get supportsShaderFilter => _cached ??= _probe();

  static bool _probe() {
    try {
      return ui.ImageFilter.isShaderFilterSupported;
    } catch (_) {
      return false;
    }
  }

  /// Test hook: override the probed value (pass null to reset).
  @visibleForTesting
  static set debugSupportsShaderFilter(bool? value) => _cached = value;
}
