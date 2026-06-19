import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_bottom_navbar_plus/src/state/bar_layout_model.dart';

void main() {
  group('BarLayoutModel', () {
    const layout = BarLayoutModel(size: Size(300, 56), itemCount: 5);

    test('splits width into equal slots', () {
      expect(layout.slotWidth, 60);
      expect(layout.slotRect(0), const Rect.fromLTWH(0, 0, 60, 56));
      expect(layout.slotRect(2), const Rect.fromLTWH(120, 0, 60, 56));
    });

    test('pill is inset within the selected slot', () {
      final pill = layout.pillRect(0);
      expect(pill.left, 10);
      expect(pill.top, 6);
      expect(pill.width, 40);
      expect(pill.height, 44);
    });

    test('fractional index slides the pill between slots', () {
      final mid = layout.pillRect(0.5);
      expect(mid.left, closeTo(40, 1e-6)); // 0.5*60 + 10
    });

    test('compact width holds one slot plus padding', () {
      expect(layout.compactWidth(), 80);
    });
  });
}
