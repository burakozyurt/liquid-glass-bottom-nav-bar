import 'package:flutter/material.dart';

import '../models/liquid_glass_search_tab.dart';

/// The content the bar capsule morphs into when the search tab is active: a
/// leading search icon, the text field, and a trailing dismiss button. Sits in
/// the same glass capsule as the tabs (a within-capsule morph, not a separate
/// blob), so no extra SDF shape is needed.
class SearchFieldMorph extends StatelessWidget {
  /// Creates the active-search content.
  const SearchFieldMorph({
    super.key,
    required this.searchTab,
    required this.onCancel,
    required this.color,
    this.autofocus = true,
  });

  /// Search configuration (controller, placeholder, callbacks, icon).
  final LiquidGlassSearchTab searchTab;

  /// Called when the user dismisses search.
  final VoidCallback onCancel;

  /// Foreground color for the icon, text and cursor.
  final Color color;

  /// Whether the field grabs focus when it appears.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          IconTheme.merge(
            data: IconThemeData(color: color, size: 20),
            child: searchTab.icon,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchTab.controller,
              autofocus: autofocus,
              onChanged: searchTab.onChanged,
              onSubmitted: searchTab.onSubmitted,
              cursorColor: color,
              style: TextStyle(color: color, fontSize: 16),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: searchTab.placeholder,
                hintStyle: TextStyle(color: color.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Cancel search',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCancel,
              child: Icon(Icons.close_rounded, color: color, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
