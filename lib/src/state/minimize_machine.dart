import 'package:flutter/rendering.dart' show ScrollDirection;

import '../models/minimize_behavior.dart';

/// Pure mapping from a scroll direction + the configured [MinimizeBehavior] to
/// the desired minimized state. Kept free of widgets so the four-behavior
/// truth table is exhaustively unit tested.
abstract final class MinimizeMachine {
  /// Resolves the next minimized state.
  ///
  /// [direction] is the scroll view's `userScrollDirection`
  /// ([ScrollDirection.reverse] == the user is scrolling content up, i.e. a
  /// downward swipe). [current] is returned unchanged while idle so the bar
  /// holds its state between gestures.
  static bool resolve({
    required ScrollDirection direction,
    required MinimizeBehavior behavior,
    required bool current,
  }) {
    switch (behavior) {
      case MinimizeBehavior.never:
      case MinimizeBehavior.automatic:
        // iOS/iPadOS default does not minimize.
        return false;
      case MinimizeBehavior.onScrollDown:
        return switch (direction) {
          ScrollDirection.reverse => true, // scrolling down → collapse
          ScrollDirection.forward => false, // scrolling up → expand
          ScrollDirection.idle => current,
        };
      case MinimizeBehavior.onScrollUp:
        return switch (direction) {
          ScrollDirection.forward => true,
          ScrollDirection.reverse => false,
          ScrollDirection.idle => current,
        };
    }
  }
}
