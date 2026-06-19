import 'package:flutter/cupertino.dart';

/// Configuration for an optional trailing search tab that morphs the bar into
/// a search field, mirroring SwiftUI's `Tab(role: .search)` + `.searchable`.
///
/// Wiring lands in milestone M5; the type is defined now so the public API is
/// stable from the start.
@immutable
class LiquidGlassSearchTab {
  /// Creates a search tab configuration.
  const LiquidGlassSearchTab({
    required this.controller,
    this.placeholder = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.automaticallyActivatesSearch = false,
    this.icon = const Icon(CupertinoIcons.search),
  });

  /// The text controller backing the search field.
  final TextEditingController controller;

  /// Placeholder text shown when the field is empty.
  final String placeholder;

  /// Called as the query text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the query is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Whether selecting the search tab immediately focuses the field.
  final bool automaticallyActivatesSearch;

  /// The icon shown for the collapsed search tab.
  final Widget icon;
}
