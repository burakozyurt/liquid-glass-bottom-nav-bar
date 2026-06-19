import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_navbar_plus/liquid_glass_bottom_navbar_plus.dart';

/// Shared destinations used across the demo pages.
const demoItems = <LiquidGlassBarItem>[
  LiquidGlassBarItem(
    icon: Icon(Icons.home_outlined),
    selectedIcon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  LiquidGlassBarItem(
    icon: Icon(Icons.explore_outlined),
    selectedIcon: Icon(Icons.explore_rounded),
    label: 'Discover',
  ),
  LiquidGlassBarItem(
    icon: Icon(Icons.library_music_outlined),
    selectedIcon: Icon(Icons.library_music_rounded),
    label: 'Library',
  ),
  LiquidGlassBarItem(
    icon: Icon(Icons.person_outline_rounded),
    selectedIcon: Icon(Icons.person_rounded),
    label: 'Profile',
  ),
];
