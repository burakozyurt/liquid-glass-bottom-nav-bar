import 'package:flutter/material.dart';

import 'accessory_page.dart';
import 'minimize_behaviors_page.dart';
import 'refraction_page.dart';
import 'search_morph_page.dart';
import 'settings_playground_page.dart';

/// Menu of the individual Liquid Glass demos.
class HomePage extends StatelessWidget {
  /// Creates the demo menu.
  const HomePage({super.key, required this.onToggleBrightness});

  /// Toggles the app's light/dark theme.
  final VoidCallback onToggleBrightness;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final demos = <(String, String, Widget)>[
      ('Refraction', 'Glass over scrollable color', const RefractionPage()),
      (
        'Scroll-minimize',
        'All four minimize behaviors',
        const MinimizeBehaviorsPage(),
      ),
      ('Bottom accessory', 'Mini-player shelf', const AccessoryPage()),
      ('Search morph', 'Capsule → search field', const SearchMorphPage()),
      (
        'Settings playground',
        'Tune every glass parameter',
        const SettingsPlaygroundPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquid Glass Bottom Bar'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleBrightness,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final (title, subtitle, page) = demos[i];
          return Card(
            child: ListTile(
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => page)),
            ),
          );
        },
      ),
    );
  }
}
