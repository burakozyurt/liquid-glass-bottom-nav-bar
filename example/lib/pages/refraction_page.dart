import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_nav_bar/liquid_glass_bottom_nav_bar.dart';

import '../widgets/demo_items.dart';
import '../widgets/tab_pages.dart';

/// The floating glass bar over four distinct, designed destinations — each tab
/// is its own screen (feed, discover, library, profile), so the frosted glass,
/// tint and (on Impeller) refraction read clearly over real, varied content.
class RefractionPage extends StatefulWidget {
  /// Creates the refraction demo page.
  const RefractionPage({super.key});

  @override
  State<RefractionPage> createState() => _RefractionPageState();
}

class _RefractionPageState extends State<RefractionPage> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeTab(),
    DiscoverTab(),
    LibraryTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(demoItems[_index].label),
        backgroundColor: Colors.transparent,
      ),
      // IndexedStack keeps each tab's scroll position alive across switches.
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: LiquidGlassBottomBar(
        items: demoItems,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
