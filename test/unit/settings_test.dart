import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_bottom_nav_bar/liquid_glass_bottom_nav_bar.dart';

void main() {
  group('LiquidGlassSettings', () {
    test('copyWith replaces only the given field', () {
      const base = LiquidGlassSettings();
      final next = base.copyWith(blur: 12);
      expect(next.blur, 12);
      expect(next.thickness, base.thickness);
      expect(next.refractiveIndex, base.refractiveIndex);
    });

    test('equality and hashCode are value-based', () {
      const a = LiquidGlassSettings(blur: 8);
      const b = LiquidGlassSettings(blur: 8);
      const c = LiquidGlassSettings(blur: 9);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('lerp interpolates numeric fields and snaps enums', () {
      const a = LiquidGlassSettings(blur: 0, variant: GlassVariant.regular);
      const b = LiquidGlassSettings(blur: 10, variant: GlassVariant.clear);
      final mid = LiquidGlassSettings.lerp(a, b, 0.5);
      expect(mid.blur, 5);
      expect(mid.variant, GlassVariant.clear); // snaps at >= 0.5
      expect(
        LiquidGlassSettings.lerp(a, b, 0.49).variant,
        GlassVariant.regular,
      );
    });

    test('prefersFallback when transparency reduced or forced', () {
      expect(const LiquidGlassSettings().prefersFallback, isFalse);
      expect(
        const LiquidGlassSettings(reduceTransparency: true).prefersFallback,
        isTrue,
      );
      expect(
        const LiquidGlassSettings(
          variant: GlassVariant.forcedFallback,
        ).prefersFallback,
        isTrue,
      );
    });

    test('glassColor alpha carries tint strength', () {
      const s = LiquidGlassSettings(glassColor: Color(0x40FF0000));
      expect(s.glassColor.a, closeTo(0x40 / 0xFF, 1e-3));
    });
  });
}
