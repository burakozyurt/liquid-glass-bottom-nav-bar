import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_navbar_plus/liquid_glass_bottom_navbar_plus.dart';

import '../widgets/demo_background.dart';
import '../widgets/demo_items.dart';

/// Lets you switch between all four [MinimizeBehavior]s and scroll to see them.
class MinimizeBehaviorsPage extends StatefulWidget {
  /// Creates the scroll-minimize demo.
  const MinimizeBehaviorsPage({super.key});

  @override
  State<MinimizeBehaviorsPage> createState() => _MinimizeBehaviorsPageState();
}

class _MinimizeBehaviorsPageState extends State<MinimizeBehaviorsPage> {
  final ScrollController _scroll = ScrollController();
  int _index = 0;
  MinimizeBehavior _behavior = MinimizeBehavior.onScrollDown;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Scroll-minimize'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          DemoBackground(scrollController: _scroll),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedButton<MinimizeBehavior>(
                segments: const [
                  ButtonSegment(
                    value: MinimizeBehavior.onScrollDown,
                    label: Text('Down'),
                  ),
                  ButtonSegment(
                    value: MinimizeBehavior.onScrollUp,
                    label: Text('Up'),
                  ),
                  ButtonSegment(
                    value: MinimizeBehavior.never,
                    label: Text('Never'),
                  ),
                ],
                selected: {_behavior},
                onSelectionChanged: (s) => setState(() => _behavior = s.first),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: LiquidGlassBottomBar(
        items: demoItems,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        scrollController: _scroll,
        minimizeBehavior: _behavior,
      ),
    );
  }
}
