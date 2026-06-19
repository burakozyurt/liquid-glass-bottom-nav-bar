import 'package:flutter/widgets.dart';

import '../models/liquid_glass_bar_item.dart';

/// A single tappable destination slot: icon (+ optional label), press feedback
/// and screen-reader semantics. Carries no glass math — it sits above the
/// shared glass body.
class BarItemView extends StatefulWidget {
  /// Creates an item view.
  const BarItemView({
    super.key,
    required this.item,
    required this.selected,
    required this.showLabel,
    required this.iconColor,
    required this.selectedIconColor,
    required this.labelStyle,
    required this.selectedLabelStyle,
    required this.onTap,
    required this.disableAnimations,
    this.onPressDown,
    this.onPressUp,
    this.scale = 1.0,
  });

  /// The destination data.
  final LiquidGlassBarItem item;

  /// Whether this destination is currently selected.
  final bool selected;

  /// Whether the label is shown beneath the icon.
  final bool showLabel;

  /// Color applied to the unselected icon/label.
  final Color iconColor;

  /// Color applied to the selected icon/label.
  final Color selectedIconColor;

  /// Style for the unselected label.
  final TextStyle labelStyle;

  /// Style for the selected label.
  final TextStyle selectedLabelStyle;

  /// Called when the item is tapped.
  final VoidCallback onTap;

  /// Whether press/elastic animation is suppressed for accessibility.
  final bool disableAnimations;

  /// Reports press-down at the bar-local position (for the touch glow).
  final ValueChanged<Offset>? onPressDown;

  /// Reports press release/cancel.
  final VoidCallback? onPressUp;

  /// External scale multiplier applied on top of the press feedback. Used by
  /// the drag-to-select gesture to "lift" (grow) the item under the pill as the
  /// finger slides across the bar. 1.0 leaves the item at its natural size.
  final double scale;

  @override
  State<BarItemView> createState() => _BarItemViewState();
}

class _BarItemViewState extends State<BarItemView> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.selected ? widget.selectedIconColor : widget.iconColor;
    final style = widget.selected
        ? widget.selectedLabelStyle
        : widget.labelStyle;
    final icon = widget.selected
        ? (widget.item.selectedIcon ?? widget.item.icon)
        : widget.item.icon;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconTheme.merge(
          data: IconThemeData(color: color, size: 24),
          child: icon,
        ),
        if (widget.showLabel) ...[
          const SizedBox(height: 2),
          Text(
            widget.item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.copyWith(color: color),
          ),
        ],
      ],
    );

    if (!widget.disableAnimations) {
      content = AnimatedScale(
        scale: (_pressed ? 0.92 : 1.0) * widget.scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: content,
      );
    }

    return Semantics(
      label: widget.item.semanticLabel ?? widget.item.label,
      selected: widget.selected,
      button: true,
      inMutuallyExclusiveGroup: true,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          _setPressed(true);
          widget.onPressDown?.call(details.localPosition);
        },
        onTapUp: (_) {
          _setPressed(false);
          widget.onPressUp?.call();
        },
        onTapCancel: () {
          _setPressed(false);
          widget.onPressUp?.call();
        },
        onTap: widget.onTap,
        child: Center(child: content),
      ),
    );
  }
}
