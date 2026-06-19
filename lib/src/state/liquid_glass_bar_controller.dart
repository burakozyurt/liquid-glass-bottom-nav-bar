import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../models/accessory_placement.dart';

/// Orchestrates the bar's runtime state: selection, minimize, accessory
/// placement, search activation and the current touch-glow point.
///
/// The widget creates one internally when none is supplied. Advanced callers
/// can pass their own to drive or observe the bar imperatively. The individual
/// pieces are exposed as [ValueListenable]s so only the affected sub-widget
/// rebuilds.
class LiquidGlassBarController extends ChangeNotifier {
  /// Creates a controller starting at [initialIndex].
  LiquidGlassBarController({int initialIndex = 0})
    : _selectedIndex = ValueNotifier<int>(initialIndex),
      _minimized = ValueNotifier<bool>(false),
      _accessoryPlacement = ValueNotifier<AccessoryPlacement>(
        AccessoryPlacement.expanded,
      ),
      _searchActive = ValueNotifier<bool>(false),
      _pressGlow = ValueNotifier<Offset?>(null);

  final ValueNotifier<int> _selectedIndex;
  final ValueNotifier<bool> _minimized;
  final ValueNotifier<AccessoryPlacement> _accessoryPlacement;
  final ValueNotifier<bool> _searchActive;
  final ValueNotifier<Offset?> _pressGlow;

  /// The currently selected destination index.
  ValueListenable<int> get selectedIndex => _selectedIndex;

  /// Whether the bar is collapsed to its compact pill.
  ValueListenable<bool> get minimized => _minimized;

  /// Where the bottom accessory is currently placed.
  ValueListenable<AccessoryPlacement> get accessoryPlacement =>
      _accessoryPlacement;

  /// Whether the search field is active.
  ValueListenable<bool> get searchActive => _searchActive;

  /// The local position of the active press (null when not pressed). Drives
  /// the touch-glow highlight.
  ValueListenable<Offset?> get pressGlow => _pressGlow;

  /// Selects [index]. No-op if already selected.
  void select(int index) {
    if (_selectedIndex.value == index) return;
    _selectedIndex.value = index;
    notifyListeners();
  }

  /// Sets the minimized state.
  void setMinimized(bool value) {
    if (_minimized.value == value) return;
    _minimized.value = value;
    notifyListeners();
  }

  /// Sets the accessory placement.
  void setAccessoryPlacement(AccessoryPlacement placement) {
    if (_accessoryPlacement.value == placement) return;
    _accessoryPlacement.value = placement;
    notifyListeners();
  }

  /// Activates or dismisses the search field.
  void activateSearch(bool active) {
    if (_searchActive.value == active) return;
    _searchActive.value = active;
    notifyListeners();
  }

  /// Records a press-down at [localPosition] for the touch glow.
  void onPressDown(Offset localPosition) => _pressGlow.value = localPosition;

  /// Clears the active press.
  void onPressUp() => _pressGlow.value = null;

  @override
  void dispose() {
    _selectedIndex.dispose();
    _minimized.dispose();
    _accessoryPlacement.dispose();
    _searchActive.dispose();
    _pressGlow.dispose();
    super.dispose();
  }
}
