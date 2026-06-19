import 'package:flutter/widgets.dart';

/// The translucent capsule drawn behind the selected item. Positioned by the
/// parent; this widget is just the fill. In M4 it becomes a registered SDF
/// shape so it can coalesce with the bar in the shader path.
class SelectionPill extends StatelessWidget {
  /// Creates a selection pill fill.
  const SelectionPill({
    super.key,
    required this.color,
    required this.borderRadius,
  });

  /// Fill color of the pill.
  final Color color;

  /// Corner radius of the pill (typically a full capsule).
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
    );
  }
}
