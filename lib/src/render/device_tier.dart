import 'package:flutter/foundation.dart';

/// Coarse performance tier used to decide whether a device can afford the
/// shader path. The real heuristic (a one-off micro-benchmark) is wired in M6;
/// until then every device is treated as [high].
enum DeviceTier {
  /// Weak device — downshift to the [BackdropFilter] fallback.
  low(allowsShader: false),

  /// Capable device — the shader path is allowed.
  high(allowsShader: true);

  const DeviceTier({required this.allowsShader});

  /// Whether the shader path may run on this tier.
  final bool allowsShader;

  static DeviceTier? _override;

  /// The detected tier for the current device.
  static DeviceTier get current => _override ?? DeviceTier.high;

  /// Test hook: pin the reported tier (pass null to reset).
  @visibleForTesting
  static set debugTier(DeviceTier? tier) => _override = tier;
}
