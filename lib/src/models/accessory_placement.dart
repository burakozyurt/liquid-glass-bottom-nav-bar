/// Where the optional bottom accessory (e.g. a now-playing shelf) is currently
/// rendered relative to the bar.
///
/// Mirrors SwiftUI's `TabViewBottomAccessoryPlacement` (`.expanded` / `.inline`).
enum AccessoryPlacement {
  /// The accessory floats as a full-width shelf above the expanded bar.
  expanded,

  /// The accessory has collapsed to sit inline with the minimized bar.
  inline,
}
