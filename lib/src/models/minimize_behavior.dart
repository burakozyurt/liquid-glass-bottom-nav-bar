/// Controls whether and how the [LiquidGlassBottomBar] collapses into a
/// compact pill as the user scrolls the underlying content.
///
/// Mirrors UIKit's `UITabBarController.MinimizeBehavior` / SwiftUI's
/// `tabBarMinimizeBehavior` semantics introduced in iOS 26.
enum MinimizeBehavior {
  /// Platform default. On iOS/iPadOS the system tab bar does **not** minimize
  /// by default, so this behaves like [never] until a future opt-in default.
  automatic,

  /// The bar never minimizes; it always stays fully expanded.
  never,

  /// The bar collapses when the user scrolls **down** (content moving up /
  /// [ScrollDirection.reverse]) and re-expands when they scroll back up.
  onScrollDown,

  /// The bar collapses when the user scrolls **up** (content moving down /
  /// [ScrollDirection.forward]) and re-expands when they scroll down. Intended
  /// for bottom-anchored or inverted content.
  onScrollUp,
}
