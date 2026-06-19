import 'package:flutter/widgets.dart';

import '../models/liquid_glass_settings.dart';
import 'fake_glass.dart';

/// Hosts the optional persistent accessory (e.g. a now-playing shelf) as its
/// own floating glass capsule above the bar. It animates between the
/// `expanded` (full-width shelf) and `inline` (compact, sitting with the
/// minimized bar) placements, driven by [placementT] (0 = expanded, 1 = inline).
class BottomAccessoryHost extends StatelessWidget {
  /// Creates an accessory host.
  const BottomAccessoryHost({
    super.key,
    required this.child,
    required this.placementT,
    required this.settings,
    this.height = 52.0,
    this.inlineWidthFactor = 0.62,
  });

  /// The accessory content.
  final Widget child;

  /// 0 == expanded (full width), 1 == inline (compact).
  final double placementT;

  /// Glass tuning shared with the bar.
  final LiquidGlassSettings settings;

  /// Height of the accessory shelf.
  final double height;

  /// Fraction of the available width the shelf shrinks to when inline.
  final double inlineWidthFactor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        final inlineWidth = fullWidth * inlineWidthFactor;
        final width = fullWidth + (inlineWidth - fullWidth) * placementT;
        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: width,
            height: height,
            child: FakeGlass(
              borderRadius: BorderRadius.circular(height / 2),
              settings: settings,
              child: ClipRect(child: child),
            ),
          ),
        );
      },
    );
  }
}
