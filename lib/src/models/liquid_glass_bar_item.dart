import 'package:flutter/widgets.dart';

/// A single destination in a [LiquidGlassBottomBar].
///
/// Modeled after Flutter's [NavigationDestination] so migration is familiar.
@immutable
class LiquidGlassBarItem {
  /// Creates a destination.
  const LiquidGlassBarItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    this.tooltip,
    this.tint,
    this.semanticLabel,
  });

  /// The icon shown for this destination in its unselected state.
  final Widget icon;

  /// Optional icon shown when this destination is selected. Falls back to
  /// [icon] when null.
  final Widget? selectedIcon;

  /// The text label shown beneath/next to the icon.
  final String label;

  /// Optional tooltip; defaults to [label] when null.
  final String? tooltip;

  /// Optional accent applied to the selection pill when this item is active.
  /// Use sparingly — Apple tints only the primary action.
  final Color? tint;

  /// Optional override for the semantic label announced by screen readers.
  /// Defaults to [label].
  final String? semanticLabel;
}
