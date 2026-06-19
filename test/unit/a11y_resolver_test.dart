import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_bottom_navbar_plus/liquid_glass_bottom_navbar_plus.dart';
import 'package:liquid_glass_bottom_navbar_plus/src/accessibility/a11y_resolver.dart';

void main() {
  group('A11yResolver', () {
    test('passes through platform flags', () {
      const media = MediaQueryData(
        disableAnimations: true,
        highContrast: true,
        platformBrightness: Brightness.dark,
      );
      final resolved = A11yResolver.resolve(media, const LiquidGlassSettings());
      expect(resolved.disableAnimations, isTrue);
      expect(resolved.highContrast, isTrue);
      expect(resolved.platformBrightness, Brightness.dark);
      expect(resolved.reduceTransparency, isFalse);
    });

    test('reduceTransparency comes from settings', () {
      const media = MediaQueryData();
      final resolved = A11yResolver.resolve(
        media,
        const LiquidGlassSettings(reduceTransparency: true),
      );
      expect(resolved.reduceTransparency, isTrue);
    });

    test('value equality', () {
      const media = MediaQueryData(highContrast: true);
      final a = A11yResolver.resolve(media, const LiquidGlassSettings());
      final b = A11yResolver.resolve(media, const LiquidGlassSettings());
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
