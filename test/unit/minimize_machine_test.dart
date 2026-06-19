import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_bottom_nav_bar/liquid_glass_bottom_nav_bar.dart';
import 'package:liquid_glass_bottom_nav_bar/src/state/minimize_machine.dart';

void main() {
  group('MinimizeMachine.resolve', () {
    bool run(MinimizeBehavior b, ScrollDirection d, {bool current = false}) =>
        MinimizeMachine.resolve(direction: d, behavior: b, current: current);

    test('never / automatic never minimize', () {
      for (final b in [MinimizeBehavior.never, MinimizeBehavior.automatic]) {
        for (final d in ScrollDirection.values) {
          expect(run(b, d, current: true), isFalse, reason: '$b $d');
        }
      }
    });

    test('onScrollDown collapses on reverse, expands on forward', () {
      const b = MinimizeBehavior.onScrollDown;
      expect(run(b, ScrollDirection.reverse), isTrue);
      expect(run(b, ScrollDirection.forward, current: true), isFalse);
    });

    test('onScrollUp collapses on forward, expands on reverse', () {
      const b = MinimizeBehavior.onScrollUp;
      expect(run(b, ScrollDirection.forward), isTrue);
      expect(run(b, ScrollDirection.reverse, current: true), isFalse);
    });

    test('idle holds the current state for scroll-driven behaviors', () {
      for (final b in [
        MinimizeBehavior.onScrollDown,
        MinimizeBehavior.onScrollUp,
      ]) {
        expect(run(b, ScrollDirection.idle, current: true), isTrue);
        expect(run(b, ScrollDirection.idle), isFalse);
      }
    });
  });
}
