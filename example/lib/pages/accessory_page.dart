import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_nav_bar/liquid_glass_bottom_nav_bar.dart';

import '../widgets/demo_background.dart';
import '../widgets/demo_items.dart';

/// Shows a persistent now-playing accessory shelf above the bar that collapses
/// to inline when the bar minimizes.
class AccessoryPage extends StatefulWidget {
  /// Creates the accessory demo.
  const AccessoryPage({super.key});

  @override
  State<AccessoryPage> createState() => _AccessoryPageState();
}

class _AccessoryPageState extends State<AccessoryPage> {
  final ScrollController _scroll = ScrollController();
  int _index = 0;

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
        title: const Text('Bottom accessory'),
        backgroundColor: Colors.transparent,
      ),
      body: DemoBackground(scrollController: _scroll),
      bottomNavigationBar: LiquidGlassBottomBar(
        items: demoItems,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        scrollController: _scroll,
        minimizeBehavior: MinimizeBehavior.onScrollDown,
        bottomAccessory: const _MiniPlayer(),
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.album, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Now Playing — Liquid Dreams',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          Icon(Icons.play_arrow_rounded, color: color),
        ],
      ),
    );
  }
}
