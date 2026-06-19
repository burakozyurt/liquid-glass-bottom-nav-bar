import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

// Dart mirror of shaders/include/sdf.glsl. Fragment shaders can't run under the
// software test renderer, so we validate the math here: SDF sign/zero-crossing
// and smooth-min properties. Keep this in lockstep with the GLSL.

double _mix(double x, double y, double a) => x * (1 - a) + y * a;

double sdRoundedBox(double px, double py, double bx, double by, double r) {
  final qx = px.abs() - bx + r;
  final qy = py.abs() - by + r;
  final inner = math.min(math.max(qx, qy), 0.0);
  final ox = math.max(qx, 0.0);
  final oy = math.max(qy, 0.0);
  return inner + math.sqrt(ox * ox + oy * oy) - r;
}

double sminPoly(double a, double b, double k) {
  if (k <= 0) return math.min(a, b);
  final h = (0.5 + 0.5 * (b - a) / k).clamp(0.0, 1.0);
  return _mix(b, a, h) - k * h * (1 - h);
}

void main() {
  group('sdRoundedBox (capsule 200×56, r=28)', () {
    const bx = 100.0, by = 28.0, r = 28.0;

    test('is negative deep inside', () {
      expect(sdRoundedBox(0, 0, bx, by, r), closeTo(-28, 1e-6));
    });

    test('is ~zero on the boundary', () {
      expect(sdRoundedBox(100, 0, bx, by, r), closeTo(0, 1e-6));
    });

    test('is positive outside', () {
      expect(sdRoundedBox(150, 0, bx, by, r), greaterThan(0));
    });

    test('refraction concentrates at the rim (|sd| smaller near edge)', () {
      final deep = sdRoundedBox(0, 0, bx, by, r).abs();
      final nearEdge = sdRoundedBox(95, 0, bx, by, r).abs();
      expect(nearEdge, lessThan(deep));
    });
  });

  group('sminPoly', () {
    test('falls back to hard min when k <= 0', () {
      expect(sminPoly(1, 2, 0), 1);
      expect(sminPoly(5, -3, 0), -3);
    });

    test('never exceeds the hard min (shapes fuse, not grow)', () {
      expect(sminPoly(1, 2, 10), lessThanOrEqualTo(math.min(1, 2)));
      expect(sminPoly(-2, -1, 5), lessThanOrEqualTo(math.min(-2.0, -1.0)));
    });
  });
}
