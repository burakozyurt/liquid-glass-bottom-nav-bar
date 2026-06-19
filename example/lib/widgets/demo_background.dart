import 'package:flutter/material.dart';

/// Shared vibrant, scrollable content so the glass bar's blur, tint and (on
/// Impeller) refraction are clearly visible over rich color.
class DemoBackground extends StatelessWidget {
  /// Creates the demo background.
  const DemoBackground({
    super.key,
    this.scrollController,
    this.title,
    this.actions,
    this.itemCount = 24,
    this.bottomPadding = 140,
  });

  /// Optional scroll source (used by the scroll-minimize demo).
  final ScrollController? scrollController;

  /// Optional app-bar title.
  final String? title;

  /// Optional app-bar actions.
  final List<Widget>? actions;

  /// Number of gradient cards.
  final int itemCount;

  /// Padding below the grid so content clears the floating bar.
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        if (title != null)
          SliverAppBar(
            floating: true,
            title: Text(title!),
            backgroundColor: Colors.transparent,
            actions: actions,
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => GradientCard(index: i),
              childCount: itemCount,
            ),
          ),
        ),
      ],
    );
  }
}

/// A single vibrant gradient card.
class GradientCard extends StatelessWidget {
  /// Creates a gradient card for [index].
  const GradientCard({super.key, required this.index});

  /// Card position, used to pick a palette.
  final int index;

  static const _palettes = <List<Color>>[
    [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
    [Color(0xFF6BCB77), Color(0xFF4D96FF)],
    [Color(0xFF9D4EDD), Color(0xFFFF5DA2)],
    [Color(0xFF00C2FF), Color(0xFF33FF8C)],
    [Color(0xFFFF8C42), Color(0xFFFF3CAC)],
    [Color(0xFF2AF598), Color(0xFF009EFD)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _palettes[index % _palettes.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
