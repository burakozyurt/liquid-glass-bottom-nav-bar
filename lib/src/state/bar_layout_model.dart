import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Pure geometry for the bar: where each item slot sits and where the
/// selection pill should be drawn. Kept free of widgets so it can be unit
/// tested across sizes, item counts and text scaling.
@immutable
class BarLayoutModel {
  /// Creates a layout model for a content area of [size] split into
  /// [itemCount] equal slots.
  const BarLayoutModel({
    required this.size,
    required this.itemCount,
    this.pillHorizontalInset = 10.0,
    this.pillVerticalInset = 6.0,
  }) : assert(itemCount > 0);

  /// The content area the items are laid out within (inside the bar padding).
  final Size size;

  /// Number of equally sized item slots.
  final int itemCount;

  /// Horizontal inset of the pill within a slot.
  final double pillHorizontalInset;

  /// Vertical inset of the pill within the bar height.
  final double pillVerticalInset;

  /// Width of a single slot.
  double get slotWidth => size.width / itemCount;

  /// The rectangle occupied by the item at [index].
  Rect slotRect(int index) =>
      Rect.fromLTWH(index * slotWidth, 0, slotWidth, size.height);

  /// The selection-pill rectangle for a (possibly fractional) [index].
  ///
  /// A fractional index lets the pill slide continuously between slots
  /// (used by the morph controller in M4).
  Rect pillRect(double index) {
    final left = index * slotWidth + pillHorizontalInset;
    return Rect.fromLTWH(
      left,
      pillVerticalInset,
      slotWidth - 2 * pillHorizontalInset,
      size.height - 2 * pillVerticalInset,
    );
  }

  /// The compact width the bar collapses to when minimized — just enough to
  /// hold the selected item's pill plus padding (used by M3).
  double compactWidth() => slotWidth + 2 * pillHorizontalInset;

  @override
  bool operator ==(Object other) =>
      other is BarLayoutModel &&
      other.size == size &&
      other.itemCount == itemCount &&
      other.pillHorizontalInset == pillHorizontalInset &&
      other.pillVerticalInset == pillVerticalInset;

  @override
  int get hashCode =>
      Object.hash(size, itemCount, pillHorizontalInset, pillVerticalInset);
}
