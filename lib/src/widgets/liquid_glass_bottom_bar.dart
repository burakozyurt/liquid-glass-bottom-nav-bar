import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../accessibility/a11y_resolver.dart';
import '../models/accessory_placement.dart';
import '../models/liquid_glass_bar_item.dart';
import '../models/liquid_glass_search_tab.dart';
import '../models/liquid_glass_settings.dart';
import '../models/minimize_behavior.dart';
import '../render/glass_field.dart';
import '../render/glass_renderer_selector.dart';
import '../render/glass_shape.dart';
import '../state/bar_layout_model.dart';
import '../state/glass_spring.dart';
import '../state/liquid_glass_bar_controller.dart';
import '../state/minimize_machine.dart';
import 'bar_item_view.dart';
import 'bottom_accessory_host.dart';
import 'glass_field_layer.dart';
import 'liquid_glass_bar_theme.dart';
import 'search_field_morph.dart';
import 'selection_pill.dart';

/// A floating, capsule-shaped bottom navigation bar rendered with Apple's
/// iOS 26 "Liquid Glass" material.
///
/// Drop-in analog to Flutter's [NavigationBar]: supply [items], the
/// [selectedIndex] and an [onDestinationSelected] callback. Place it in
/// `Scaffold.bottomNavigationBar` together with `Scaffold(extendBody: true)`
/// so the body scrolls underneath and is refracted through the glass.
///
/// Milestone note: M1 renders the universal fallback (frosted) glass with an
/// animated selection pill. Real shader refraction (M2), scroll-minimize (M3),
/// liquid selection morph (M4) and accessory/search merge (M5) build on this
/// same API without breaking it.
class LiquidGlassBottomBar extends StatefulWidget {
  /// Creates a Liquid Glass bottom bar.
  ///
  /// Apple's HIG recommends 3–5 stable, top-level destinations.
  const LiquidGlassBottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onDestinationSelected,
    this.settings = const LiquidGlassSettings(),
    this.minimizeBehavior = MinimizeBehavior.automatic,
    this.bottomAccessory,
    this.searchTab,
    this.controller,
    this.scrollController,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 12),
    this.height = 56.0,
    this.theme,
    this.onMinimizeChanged,
    this.swipeToSelect = true,
  }) : assert(items.length >= 2, 'Provide at least two destinations.'),
       assert(
         selectedIndex >= 0 && selectedIndex < items.length,
         'selectedIndex must be within items range.',
       );

  /// Cupertino-flavored alias using `currentIndex` / `onTap` naming.
  const LiquidGlassBottomBar.legacy({
    Key? key,
    required List<LiquidGlassBarItem> items,
    required int currentIndex,
    ValueChanged<int>? onTap,
    LiquidGlassSettings settings = const LiquidGlassSettings(),
    MinimizeBehavior minimizeBehavior = MinimizeBehavior.automatic,
    Widget? bottomAccessory,
    LiquidGlassSearchTab? searchTab,
    LiquidGlassBarController? controller,
    ScrollController? scrollController,
    EdgeInsets margin = const EdgeInsets.fromLTRB(16, 0, 16, 12),
    double height = 56.0,
    LiquidGlassBarTheme? theme,
    ValueChanged<bool>? onMinimizeChanged,
    bool swipeToSelect = true,
  }) : this(
         key: key,
         items: items,
         selectedIndex: currentIndex,
         onDestinationSelected: onTap,
         settings: settings,
         minimizeBehavior: minimizeBehavior,
         bottomAccessory: bottomAccessory,
         searchTab: searchTab,
         controller: controller,
         scrollController: scrollController,
         margin: margin,
         height: height,
         theme: theme,
         onMinimizeChanged: onMinimizeChanged,
         swipeToSelect: swipeToSelect,
       );

  /// The destinations shown in the bar.
  final List<LiquidGlassBarItem> items;

  /// Index of the currently selected destination.
  final int selectedIndex;

  /// Called when a destination is tapped.
  final ValueChanged<int>? onDestinationSelected;

  /// Visual + physical tuning of the glass.
  final LiquidGlassSettings settings;

  /// How the bar reacts to scrolling (wired in M3).
  final MinimizeBehavior minimizeBehavior;

  /// Optional persistent shelf above the bar (wired in M5).
  final Widget? bottomAccessory;

  /// Optional trailing search tab (wired in M5).
  final LiquidGlassSearchTab? searchTab;

  /// Optional external controller; one is created internally when null.
  final LiquidGlassBarController? controller;

  /// Optional scroll source driving the minimize behavior (wired in M3).
  final ScrollController? scrollController;

  /// Transparent inset around the floating capsule.
  final EdgeInsets margin;

  /// Height of the capsule (excluding margin and safe-area inset).
  final double height;

  /// Optional style override; otherwise resolved from the ambient theme.
  final LiquidGlassBarTheme? theme;

  /// Called when the minimized state changes (wired in M3).
  final ValueChanged<bool>? onMinimizeChanged;

  /// Whether a horizontal drag across the bar moves the selection pill under
  /// the finger and commits to the nearest destination on release. Taps still
  /// select normally. Defaults to true.
  final bool swipeToSelect;

  @override
  State<LiquidGlassBottomBar> createState() => _LiquidGlassBottomBarState();
}

class _LiquidGlassBottomBarState extends State<LiquidGlassBottomBar>
    with TickerProviderStateMixin {
  LiquidGlassBarController? _internalController;
  late final AnimationController _minimize;
  late final AnimationController _pill;
  late final AnimationController _search;
  bool _reduceMotion = false;

  /// True while the user is dragging across the bar to pick a destination.
  /// Drives the live pill follow and the per-item "lift" (grow) feedback.
  bool _dragging = false;

  LiquidGlassBarController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = LiquidGlassBarController(
        initialIndex: widget.selectedIndex,
      );
    }
    _minimize = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1),
    );
    // Unbounded so the spring can carry the (fractional) selected-slot index
    // across the full 0..n-1 range with overshoot.
    _pill = AnimationController.unbounded(vsync: this)
      ..value = widget.selectedIndex.toDouble();
    _search = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1),
    );
    _attachScroll(widget.scrollController);
  }

  @override
  void didUpdateWidget(LiquidGlassBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && _internalController == null) {
      _internalController = LiquidGlassBarController(
        initialIndex: widget.selectedIndex,
      );
    } else if (widget.controller != null && _internalController != null) {
      _internalController!.dispose();
      _internalController = null;
    }
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _controller.select(widget.selectedIndex);
      _animatePill();
    }
    if (widget.scrollController != oldWidget.scrollController) {
      _detachScroll(oldWidget.scrollController);
      _attachScroll(widget.scrollController);
    }
  }

  @override
  void dispose() {
    _detachScroll(widget.scrollController);
    _minimize.dispose();
    _pill.dispose();
    _search.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  /// Springs the selection pill to the current [LiquidGlassBottomBar.selectedIndex],
  /// seeding the simulation with the live velocity so an interrupted slide
  /// continues smoothly.
  void _animatePill() {
    final target = widget.selectedIndex.toDouble();
    if (_reduceMotion) {
      _pill.value = target;
      return;
    }
    _pill.animateWith(
      LgSpring.bouncy.simulation(
        from: _pill.value,
        to: target,
        velocity: _pill.velocity,
      ),
    );
  }

  void _attachScroll(ScrollController? controller) =>
      controller?.addListener(_onScroll);

  void _detachScroll(ScrollController? controller) =>
      controller?.removeListener(_onScroll);

  void _onScroll() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;
    final target = MinimizeMachine.resolve(
      direction: controller.position.userScrollDirection,
      behavior: widget.minimizeBehavior,
      current: _controller.minimized.value,
    );
    if (target != _controller.minimized.value) _setMinimized(target);
  }

  void _setMinimized(bool minimized) {
    _controller.setMinimized(minimized);
    _controller.setAccessoryPlacement(
      minimized ? AccessoryPlacement.inline : AccessoryPlacement.expanded,
    );
    widget.onMinimizeChanged?.call(minimized);
    final to = minimized ? 1.0 : 0.0;
    if (_reduceMotion) {
      _minimize.value = to;
    } else {
      _minimize.animateWith(
        LgSpring.smooth.simulation(from: _minimize.value, to: to),
      );
    }
  }

  void _activateSearch(bool active) {
    if (active) _setMinimized(false); // search uses the expanded capsule
    _controller.activateSearch(active);
    final to = active ? 1.0 : 0.0;
    if (_reduceMotion) {
      _search.value = to;
    } else {
      _search.animateWith(
        LgSpring.smooth.simulation(from: _search.value, to: to),
      );
    }
  }

  void _handleTap(int index) {
    _controller.select(index);
    widget.onDestinationSelected?.call(index);
  }

  // --- Drag-to-select ---------------------------------------------------------

  /// Converts a bar-local x (in logical px) to a fractional slot index, the
  /// inverse of [BarLayoutModel.pillRect] so the pill centres under the finger.
  double _indexForDx(double dx, double slotWidth) {
    final n = widget.items.length;
    return (dx / slotWidth - 0.5).clamp(0.0, (n - 1).toDouble());
  }

  void _onDragStart(double index) {
    _pill.stop();
    setState(() => _dragging = true);
    _pill.value = index;
  }

  void _onDragUpdate(double index) => _pill.value = index;

  void _onDragEnd(double velocityIndexPerSec) {
    final n = widget.items.length;
    final target = _pill.value.round().clamp(0, n - 1);
    setState(() => _dragging = false);
    if (_reduceMotion) {
      _pill.value = target.toDouble();
    } else {
      _pill.animateWith(
        LgSpring.bouncy.simulation(
          from: _pill.value,
          to: target.toDouble(),
          velocity: velocityIndexPerSec,
        ),
      );
    }
    _handleTap(target);
  }

  void _onDragCancel() {
    if (!_dragging) return; // a plain tap can fire cancel; ignore it
    setState(() => _dragging = false);
    // Settle the pill back to the live selection (no commit).
    final target = widget.selectedIndex.toDouble();
    if (_reduceMotion) {
      _pill.value = target;
    } else {
      _pill.animateWith(
        LgSpring.bouncy.simulation(
          from: _pill.value,
          to: target,
          velocity: _pill.velocity,
        ),
      );
    }
  }

  /// Per-item "lift": the item under the pill grows while dragging; neighbours
  /// interpolate. Returns 1.0 (no lift) when not dragging.
  double _itemScale(int i, double animatedIndex) {
    if (!_dragging) return 1.0;
    final proximity = (1.0 - (i - animatedIndex).abs()).clamp(0.0, 1.0);
    return 1.0 + 0.14 * proximity;
  }

  /// Wraps the expanded items in a horizontal-drag detector (when
  /// [LiquidGlassBottomBar.swipeToSelect] is on). The detector coexists with
  /// the per-item taps via the gesture arena: a still press selects via the
  /// item, a horizontal move grabs the pill. [slotWidth] maps the finger's
  /// bar-local x to a fractional index.
  Widget _wrapWithDrag({required double slotWidth, required Widget child}) {
    if (!widget.swipeToSelect) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (d) =>
          _onDragStart(_indexForDx(d.localPosition.dx, slotWidth)),
      onHorizontalDragUpdate: (d) =>
          _onDragUpdate(_indexForDx(d.localPosition.dx, slotWidth)),
      onHorizontalDragEnd: (d) =>
          _onDragEnd(d.velocity.pixelsPerSecond.dx / slotWidth),
      onHorizontalDragCancel: _onDragCancel,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final a11y = A11yResolver.resolve(media, widget.settings);
    _reduceMotion = a11y.disableAnimations;
    final theme = LiquidGlassBarTheme.resolve(context, widget.theme);
    final bottomInset = media.viewPadding.bottom;
    final renderPath = GlassRendererSelector.resolve(
      a11y: a11y,
      settings: widget.settings,
    );

    return GlassRendererSelector(
      path: renderPath,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          widget.margin.left,
          widget.margin.top,
          widget.margin.right,
          widget.margin.bottom + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.bottomAccessory != null) ...[
              AnimatedBuilder(
                animation: _minimize,
                builder: (context, _) => BottomAccessoryHost(
                  placementT: _minimize.value,
                  settings: widget.settings,
                  child: widget.bottomAccessory!,
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              height: widget.height,
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedBuilder(
                      animation: Listenable.merge([_pill, _minimize, _search]),
                      builder: (context, _) => _buildBar(
                        constraints: constraints,
                        animatedIndex: _pill.value,
                        pillVelocity: _pill.velocity,
                        minimizeT: _minimize.value,
                        searchT: _search.value,
                        theme: theme,
                        a11y: a11y,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar({
    required BoxConstraints constraints,
    required double animatedIndex,
    required double pillVelocity,
    required double minimizeT,
    required double searchT,
    required LiquidGlassBarTheme theme,
    required ResolvedA11y a11y,
  }) {
    final fullWidth = constraints.maxWidth;
    final fullSize = Size(fullWidth, widget.height);
    final layout = BarLayoutModel(
      size: fullSize,
      itemCount: widget.items.length,
    );
    final radius = widget.settings.cornerRadius ?? widget.height / 2;
    final borderRadius = BorderRadius.circular(radius);

    // Capsule contracts toward a compact pill as it minimizes.
    final compactWidth = math.max(layout.compactWidth(), widget.height + 24);
    final effWidth = fullWidth + (compactWidth - fullWidth) * minimizeT;
    final effSize = Size(effWidth, widget.height);
    final field = GlassField(
      shapes: [GlassShape.roundedRect(Offset.zero & effSize, radius)],
      blend: widget.settings.blend,
    );

    final searchClamp = searchT.clamp(0.0, 1.0);
    final expandedOpacity =
        (1.0 - minimizeT / 0.5).clamp(0.0, 1.0) * (1.0 - searchClamp);
    final compactOpacity = ((minimizeT - 0.5) / 0.5).clamp(0.0, 1.0);
    // Elongate along travel + slightly squash vertically for a liquid feel.
    final basePill = layout.pillRect(animatedIndex);
    final stretch = (pillVelocity.abs() * 0.03).clamp(0.0, 0.18);
    final pillRect = stretch == 0
        ? basePill
        : Rect.fromCenter(
            center: basePill.center,
            width: basePill.width * (1 + stretch),
            height: basePill.height * (1 - stretch * 0.5),
          );
    final selected = widget.items[widget.selectedIndex];
    final searchTab = widget.searchTab;

    final expandedLayer = IgnorePointer(
      ignoring: minimizeT > 0.5 || searchClamp > 0.5,
      child: Opacity(
        opacity: expandedOpacity,
        child: OverflowBox(
          minWidth: fullWidth,
          maxWidth: fullWidth,
          alignment: Alignment.center,
          child: _wrapWithDrag(
            slotWidth: layout.slotWidth,
            child: SizedBox(
              width: fullWidth,
              height: widget.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fromRect(
                    rect: pillRect,
                    child: SelectionPill(
                      color: theme.pillColor!,
                      borderRadius: BorderRadius.circular(pillRect.height / 2),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < widget.items.length; i++)
                        Expanded(
                          child: BarItemView(
                            item: widget.items[i],
                            selected: i == widget.selectedIndex,
                            showLabel: theme.showLabels,
                            iconColor: theme.iconColor!,
                            selectedIconColor: theme.selectedIconColor!,
                            labelStyle: theme.labelStyle!,
                            selectedLabelStyle: theme.selectedLabelStyle!,
                            disableAnimations: a11y.disableAnimations,
                            onTap: () => _handleTap(i),
                            onPressDown: _controller.onPressDown,
                            onPressUp: _controller.onPressUp,
                            scale: _itemScale(i, animatedIndex),
                          ),
                        ),
                      if (searchTab != null)
                        SizedBox(
                          width: 48,
                          child: Semantics(
                            button: true,
                            label: 'Search',
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _activateSearch(true),
                              child: IconTheme.merge(
                                data: IconThemeData(
                                  color: theme.iconColor,
                                  size: 24,
                                ),
                                child: Center(child: searchTab.icon),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final compactLayer = IgnorePointer(
      ignoring: minimizeT <= 0.5,
      child: Opacity(
        opacity: compactOpacity,
        child: Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _setMinimized(false),
            child: IconTheme.merge(
              data: IconThemeData(color: theme.selectedIconColor, size: 24),
              child: selected.selectedIcon ?? selected.icon,
            ),
          ),
        ),
      ),
    );

    final layers = <Widget>[expandedLayer, compactLayer];
    if (searchTab != null && searchClamp > 0.01) {
      layers.add(
        IgnorePointer(
          ignoring: searchClamp < 0.5,
          child: Opacity(
            opacity: searchClamp,
            child: SearchFieldMorph(
              searchTab: searchTab,
              color: theme.selectedIconColor!,
              onCancel: () => _activateSearch(false),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.center,
      child: SizedBox.fromSize(
        size: effSize,
        child: GlassFieldLayer(
          borderRadius: borderRadius,
          field: field,
          settings: widget.settings,
          a11y: a11y,
          child: Stack(fit: StackFit.expand, children: layers),
        ),
      ),
    );
  }
}
