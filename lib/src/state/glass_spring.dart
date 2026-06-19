import 'dart:math' as math;

import 'package:flutter/physics.dart';

/// Named spring profiles mirroring SwiftUI's documented presets, expressed as
/// `(response, dampingFraction)` pairs. These drive every Liquid Glass motion;
/// duration-based curves are avoided because they don't survive interruption.
enum LgSpring {
  /// Finger-driven, continuously interruptible (SwiftUI `.interactiveSpring`).
  interactive(0.15, 0.86),

  /// Visible overshoot then settle — used for selection/morph settling.
  bouncy(0.40, 0.65),

  /// Critically damped, no overshoot — used for the minimize collapse.
  smooth(0.40, 1.0),

  /// Slight overshoot, quick — used for the touch glow ramp-in.
  snappy(0.30, 0.85);

  const LgSpring(this.response, this.dampingFraction);

  /// Approximate time (s) for one oscillation of the undamped system.
  final double response;

  /// Damping ratio (1.0 == critically damped).
  final double dampingFraction;

  /// Builds the [SpringDescription] for this preset (unit mass).
  ///
  /// `stiffness = (2π / response)² · m`,
  /// `damping = 2 · ζ · √(stiffness · m)`.
  SpringDescription get description {
    const mass = 1.0;
    final stiffness = math.pow(2 * math.pi / response, 2).toDouble() * mass;
    final damping = 2 * dampingFraction * math.sqrt(stiffness * mass);
    return SpringDescription(
      mass: mass,
      stiffness: stiffness,
      damping: damping,
    );
  }

  /// Creates a [SpringSimulation] from [from] to [to], seeding it with
  /// [velocity] so an interrupted animation continues smoothly.
  SpringSimulation simulation({
    required double from,
    required double to,
    double velocity = 0,
  }) {
    return SpringSimulation(description, from, to, velocity);
  }
}
