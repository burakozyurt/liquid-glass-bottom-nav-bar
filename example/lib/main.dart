import 'package:flutter/material.dart';

import 'pages/home_page.dart';

void main() => runApp(const LiquidGlassDemoApp());

/// Demo app: a menu of Liquid Glass demos with a light/dark toggle.
class LiquidGlassDemoApp extends StatefulWidget {
  /// Creates the demo app.
  const LiquidGlassDemoApp({super.key});

  @override
  State<LiquidGlassDemoApp> createState() => _LiquidGlassDemoAppState();
}

class _LiquidGlassDemoAppState extends State<LiquidGlassDemoApp> {
  ThemeMode _mode = ThemeMode.dark;

  void _toggleBrightness() {
    setState(() {
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF0A84FF);
    return MaterialApp(
      title: 'Liquid Glass Bottom Bar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light, colorSchemeSeed: seed),
      darkTheme: ThemeData(brightness: Brightness.dark, colorSchemeSeed: seed),
      themeMode: _mode,
      home: HomePage(onToggleBrightness: _toggleBrightness),
    );
  }
}
