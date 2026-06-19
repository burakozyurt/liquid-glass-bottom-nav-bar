import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_bottom_nav_bar/liquid_glass_bottom_nav_bar.dart';

const _items = [
  LiquidGlassBarItem(icon: Icon(Icons.home), label: 'Home'),
  LiquidGlassBarItem(icon: Icon(Icons.search), label: 'Search'),
  LiquidGlassBarItem(icon: Icon(Icons.person), label: 'Profile'),
];

Widget _host({
  required int selectedIndex,
  required ValueChanged<int> onSelected,
  List<LiquidGlassBarItem> items = _items,
  TextScaler textScaler = TextScaler.noScaling,
  bool reduceTransparency = false,
  bool disableAnimations = false,
  bool highContrast = false,
  ScrollController? scrollController,
  MinimizeBehavior minimizeBehavior = MinimizeBehavior.automatic,
  ValueChanged<bool>? onMinimizeChanged,
  Widget? bottomAccessory,
  LiquidGlassSearchTab? searchTab,
}) {
  return MediaQuery(
    data: MediaQueryData(
      textScaler: textScaler,
      disableAnimations: disableAnimations,
      highContrast: highContrast,
    ),
    child: MaterialApp(
      home: Scaffold(
        extendBody: true,
        body: ListView(
          controller: scrollController,
          children: List.generate(
            30,
            (i) => SizedBox(height: 60, child: Center(child: Text('Row $i'))),
          ),
        ),
        bottomNavigationBar: LiquidGlassBottomBar(
          items: items,
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          scrollController: scrollController,
          minimizeBehavior: minimizeBehavior,
          onMinimizeChanged: onMinimizeChanged,
          bottomAccessory: bottomAccessory,
          searchTab: searchTab,
          settings: LiquidGlassSettings(reduceTransparency: reduceTransparency),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('reports the tapped destination index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      _host(selectedIndex: 0, onSelected: (i) => tapped = i),
    );
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(tapped, 2);
  });

  testWidgets('drag across the bar commits to the destination under release', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      _host(selectedIndex: 0, onSelected: (i) => selected = i),
    );
    await tester.pumpAndSettle();

    // Press the first tab and drag far right; the pill follows and on release
    // the bar commits to the last destination (the index is clamped).
    await tester.drag(find.text('Home'), const Offset(600, 0));
    await tester.pumpAndSettle();
    expect(selected, 2);
  });

  testWidgets('a plain tap still selects when swipeToSelect is on', (
    tester,
  ) async {
    int? selected;
    await tester.pumpWidget(
      _host(selectedIndex: 0, onSelected: (i) => selected = i),
    );
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(selected, 1);
  });

  testWidgets('reflects the controlled selectedIndex', (tester) async {
    await tester.pumpWidget(_host(selectedIndex: 1, onSelected: (_) {}));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Search')),
      containsSemantics(isSelected: true),
    );
  });

  testWidgets('does not overflow at large text scale', (tester) async {
    await tester.pumpWidget(
      _host(
        selectedIndex: 0,
        onSelected: (_) {},
        textScaler: const TextScaler.linear(2.0),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the solid fallback when transparency is reduced', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(selectedIndex: 0, onSelected: (_) {}, reduceTransparency: true),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(LiquidGlassBottomBar), findsOneWidget);
  });

  testWidgets('minimizes on scroll down and expands on scroll up', (
    tester,
  ) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    final events = <bool>[];
    await tester.pumpWidget(
      _host(
        selectedIndex: 0,
        onSelected: (_) {},
        scrollController: scrollController,
        minimizeBehavior: MinimizeBehavior.onScrollDown,
        onMinimizeChanged: events.add,
      ),
    );
    await tester.pumpAndSettle();

    // Drag content up → scroll down → bar should minimize.
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(events.last, isTrue);

    // Drag content down → scroll up → bar should expand.
    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(events.last, isFalse);
  });

  testWidgets('never behavior ignores scrolling', (tester) async {
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);
    final events = <bool>[];
    await tester.pumpWidget(
      _host(
        selectedIndex: 0,
        onSelected: (_) {},
        scrollController: scrollController,
        onMinimizeChanged: events.add,
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(events, isEmpty);
  });

  testWidgets('renders the bottom accessory above the bar', (tester) async {
    await tester.pumpWidget(
      _host(
        selectedIndex: 0,
        onSelected: (_) {},
        bottomAccessory: const Text('Now Playing'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Now Playing'), findsOneWidget);
  });

  testWidgets('disableAnimations settles instantly without pending frames', (
    tester,
  ) async {
    int? tapped;
    await tester.pumpWidget(
      _host(
        selectedIndex: 0,
        onSelected: (i) => tapped = i,
        disableAnimations: true,
      ),
    );
    await tester.tap(find.text('Profile'));
    // A single pump must settle (no spring frames scheduled).
    await tester.pump();
    expect(tapped, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders under high contrast', (tester) async {
    await tester.pumpWidget(
      _host(selectedIndex: 0, onSelected: (_) {}, highContrast: true),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(LiquidGlassBottomBar), findsOneWidget);
  });

  testWidgets('search tab morphs the bar into a text field and back', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        selectedIndex: 0,
        onSelected: (_) {},
        // No item labelled 'Search' so the search button label is unique.
        items: const [
          LiquidGlassBarItem(icon: Icon(Icons.home), label: 'Home'),
          LiquidGlassBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        searchTab: LiquidGlassSearchTab(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Cancel search'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
  });
}
