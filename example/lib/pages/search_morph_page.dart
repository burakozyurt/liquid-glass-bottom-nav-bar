import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_navbar_plus/liquid_glass_bottom_navbar_plus.dart';

import '../widgets/demo_background.dart';
import '../widgets/demo_items.dart';

/// Demonstrates the search tab morphing the capsule into a search field.
class SearchMorphPage extends StatefulWidget {
  /// Creates the search-morph demo.
  const SearchMorphPage({super.key});

  @override
  State<SearchMorphPage> createState() => _SearchMorphPageState();
}

class _SearchMorphPageState extends State<SearchMorphPage> {
  final TextEditingController _search = TextEditingController();
  int _index = 0;
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_query.isEmpty ? 'Search morph' : 'Searching “$_query”'),
        backgroundColor: Colors.transparent,
      ),
      body: const DemoBackground(),
      bottomNavigationBar: LiquidGlassBottomBar(
        items: demoItems,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        searchTab: LiquidGlassSearchTab(
          controller: _search,
          placeholder: 'Search the library',
          icon: const Icon(CupertinoIcons.search),
          onChanged: (q) => setState(() => _query = q),
        ),
      ),
    );
  }
}
