import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_bottom_navbar_plus/src/state/glass_spring.dart';

void main() {
  group('GlassSpring', () {
    test('stiffness follows (2π/response)²', () {
      final d = LgSpring.smooth.description; // response 0.40
      final expected = math.pow(2 * math.pi / 0.40, 2).toDouble();
      expect(d.stiffness, closeTo(expected, 1e-6));
      expect(d.mass, 1.0);
    });

    test('critically damped preset satisfies c² ≈ 4·k·m', () {
      final d = LgSpring.smooth.description; // dampingFraction 1.0
      expect(d.damping * d.damping, closeTo(4 * d.stiffness * d.mass, 1e-3));
    });

    test('underdamped preset has c² < 4·k·m', () {
      final d = LgSpring.bouncy.description; // dampingFraction 0.65
      expect(d.damping * d.damping, lessThan(4 * d.stiffness * d.mass));
    });

    test('simulation seeds initial velocity', () {
      final sim = LgSpring.interactive.simulation(from: 0, to: 1, velocity: 5);
      expect(sim.dx(0), closeTo(5, 1e-6));
      expect(sim.x(0), closeTo(0, 1e-6));
    });
  });
}
