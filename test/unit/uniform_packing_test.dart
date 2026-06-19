import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_bottom_nav_bar/liquid_glass_bottom_nav_bar.dart';
import 'package:liquid_glass_bottom_nav_bar/src/render/glass_field.dart';
import 'package:liquid_glass_bottom_nav_bar/src/render/glass_shape.dart';
import 'package:liquid_glass_bottom_nav_bar/src/render/liquid_glass_uniforms.dart';

void main() {
  group('LiquidGlassUniforms.packInto', () {
    final field = GlassField(
      shapes: [GlassShape.roundedRect(const Rect.fromLTWH(0, 0, 200, 56), 28)],
      blend: 24,
    );
    const settings = LiquidGlassSettings();
    // The bar sits at (20, 700) within a 400×800 backdrop; geometry is packed
    // as a fraction of that backdrop (x ÷ 400, y ÷ 800).
    const origin = Offset(20, 700);
    const screen = Size(400, 800);

    Map<int, double> pack() {
      final recorded = <int, double>{};
      LiquidGlassUniforms.packInto(
        (i, v) => recorded[i] = v,
        field,
        settings,
        origin,
        screen,
      );
      return recorded;
    }

    test('leaves uSize (0,1) to the engine and fills 2..64', () {
      final r = pack();
      expect(r.containsKey(0), isFalse);
      expect(r.containsKey(1), isFalse);
      expect(r.keys.reduce((a, b) => a < b ? a : b), 2);
      expect(
        r.keys.reduce((a, b) => a > b ? a : b),
        LiquidGlassUniforms.floatCount - 1,
      );
      expect(r.length, LiquidGlassUniforms.floatCount - 2);
    });

    test('scalar fields land at their declared indices', () {
      final r = pack();
      expect(r[2], settings.thickness / screen.width); // uThickness (fraction)
      expect(r[3], settings.refractiveIndex); // uRefractiveIndex
      expect(r[4], settings.lightAngle); // uLightAngle
      expect(r[11], settings.saturation); // uSaturation
      expect(r[13], settings.chromaticAberration); // uChromatic
      expect(r[14], 1.0); // uShapeCount
      expect(r[15], settings.blend / screen.width); // uBlend (fraction)
      expect(r[16], settings.blur / screen.width); // uBlur (fraction)
    });

    test('glassColor occupies indices 7..10 as RGBA', () {
      final r = pack();
      expect(r[7], closeTo(settings.glassColor.r, 1e-6));
      expect(r[10], closeTo(settings.glassColor.a, 1e-6));
    });

    test('shape 0 geometry is packed as backdrop fractions at 17..22', () {
      final r = pack();
      // Shape is shifted by origin (20, 700) then divided by screen (400, 800).
      expect(r[17], 0); // kind
      expect(r[18], closeTo((20 + 100) / 400, 1e-9)); // cx: (origin+100)/width
      expect(r[19], closeTo((700 + 28) / 800, 1e-9)); // cy: (origin+28)/height
      expect(r[20], closeTo(100 / 400, 1e-9)); // halfW / width
      expect(r[21], closeTo(28 / 800, 1e-9)); // halfH / height
      expect(r[22], closeTo(28 / 400, 1e-9)); // cornerR / width
    });

    test('inactive shape slots are zero-filled', () {
      final r = pack();
      for (var idx = 23; idx < LiquidGlassUniforms.floatCount; idx++) {
        expect(r[idx], 0, reason: 'index $idx should be zero');
      }
    });
  });
}
