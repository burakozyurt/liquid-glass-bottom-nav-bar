import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_navbar_plus/liquid_glass_bottom_navbar_plus.dart';

import '../widgets/demo_background.dart';
import '../widgets/demo_items.dart';

/// Live sliders for every glass parameter — the primary surface for tuning
/// fidelity against real iOS 26 recordings.
class SettingsPlaygroundPage extends StatefulWidget {
  /// Creates the settings playground.
  const SettingsPlaygroundPage({super.key});

  @override
  State<SettingsPlaygroundPage> createState() => _SettingsPlaygroundPageState();
}

class _SettingsPlaygroundPageState extends State<SettingsPlaygroundPage> {
  int _index = 0;
  LiquidGlassSettings _settings = const LiquidGlassSettings();

  void _update(LiquidGlassSettings next) => setState(() => _settings = next);

  @override
  Widget build(BuildContext context) {
    final s = _settings;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Settings playground'),
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          const DemoBackground(),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 380,
                  maxWidth: 520,
                ),
                child: Card(
                  margin: const EdgeInsets.all(12),
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.92),
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      _slider(
                        'Thickness',
                        s.thickness,
                        0,
                        30,
                        (v) => _update(s.copyWith(thickness: v)),
                      ),
                      _slider(
                        'Blur',
                        s.blur,
                        0,
                        15,
                        (v) => _update(s.copyWith(blur: v)),
                      ),
                      _slider(
                        'Refractive index',
                        s.refractiveIndex,
                        1,
                        2,
                        (v) => _update(s.copyWith(refractiveIndex: v)),
                      ),
                      _slider(
                        'Light angle',
                        s.lightAngle,
                        -math.pi,
                        math.pi,
                        (v) => _update(s.copyWith(lightAngle: v)),
                      ),
                      _slider(
                        'Saturation',
                        s.saturation,
                        0,
                        3,
                        (v) => _update(s.copyWith(saturation: v)),
                      ),
                      _slider(
                        'Chromatic aberration',
                        s.chromaticAberration,
                        0,
                        0.05,
                        (v) => _update(s.copyWith(chromaticAberration: v)),
                      ),
                      _slider(
                        'Outline',
                        s.outlineIntensity,
                        0,
                        1,
                        (v) => _update(s.copyWith(outlineIntensity: v)),
                      ),
                      _slider(
                        'Blend',
                        s.blend,
                        0,
                        60,
                        (v) => _update(s.copyWith(blend: v)),
                      ),
                      SwitchListTile(
                        dense: true,
                        title: const Text('Reduce transparency'),
                        value: s.reduceTransparency,
                        onChanged: (v) =>
                            _update(s.copyWith(reduceTransparency: v)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: LiquidGlassBottomBar(
        items: demoItems,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        settings: _settings,
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label  ${value.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}
