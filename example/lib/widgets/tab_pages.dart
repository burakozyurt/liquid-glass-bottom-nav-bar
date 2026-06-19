import 'package:flutter/material.dart';

/// Designed content for each bottom-bar destination, used by `RefractionPage`
/// so every tab is a distinct, app-like screen (not the same grid). The content
/// stays vibrant on purpose, so the Liquid Glass bar's blur, tint and (on
/// Impeller) refraction read clearly over real color.

const _palettes = <List<Color>>[
  [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
  [Color(0xFF6BCB77), Color(0xFF4D96FF)],
  [Color(0xFF9D4EDD), Color(0xFFFF5DA2)],
  [Color(0xFF00C2FF), Color(0xFF33FF8C)],
  [Color(0xFFFF8C42), Color(0xFFFF3CAC)],
  [Color(0xFF2AF598), Color(0xFF009EFD)],
  [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
  [Color(0xFFF6D365), Color(0xFFFDA085)],
];

LinearGradient _grad(int i) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: _palettes[i % _palettes.length],
);

/// Clearance below the scrollable content so it doesn't hide behind the
/// floating glass bar.
const double _kBottomGap = 132;

/// A rounded gradient block — the demo's stand-in for cover art.
class _Cover extends StatelessWidget {
  const _Cover({
    required this.index,
    this.size,
    this.radius = 18,
    this.label,
  });

  final int index;
  final double? size;
  final double radius;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        gradient: _grad(index),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: label == null
          ? null
          : Text(
              label!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.action});
  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          if (action != null)
            Text(
              action!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

/// Home — a feed: featured hero, a "jump back in" carousel and a grid.
class HomeTab extends StatelessWidget {
  /// Creates the Home tab.
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: _kBottomGap),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _grad(2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR DAILY MIX',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Evening Chill',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  right: 16,
                  bottom: 16,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const _SectionHeader('Jump back in', action: 'See all'),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 8,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => SizedBox(
              width: 132,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Cover(index: i + 1, size: 132),
                  const SizedBox(height: 8),
                  Text(
                    'Mix No. ${i + 1}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
        const _SectionHeader('Made for you'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: 6,
          itemBuilder: (context, i) =>
              _Cover(index: i + 3, label: 'Playlist ${i + 1}'),
        ),
      ],
    );
  }
}

/// Discover — search field, category chips and a trending grid.
class DiscoverTab extends StatelessWidget {
  /// Creates the Discover tab.
  const DiscoverTab({super.key});

  static const _genres = [
    'Pop',
    'Hip-Hop',
    'Chill',
    'Focus',
    'Workout',
    'Jazz',
    'Rock',
    'Mood',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.only(bottom: _kBottomGap),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search artists, songs, podcasts',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: scheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _genres.length; i++)
                Chip(
                  label: Text(_genres[i]),
                  backgroundColor: _palettes[i % _palettes.length].first
                      .withValues(alpha: 0.22),
                  side: BorderSide.none,
                ),
            ],
          ),
        ),
        const _SectionHeader('Trending now'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: 8,
          itemBuilder: (context, i) =>
              _Cover(index: i, label: '#${_genres[i % _genres.length]}'),
        ),
      ],
    );
  }
}

/// Library — filter chips, a recently-played row and a saved list.
class LibraryTab extends StatelessWidget {
  /// Creates the Library tab.
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: _kBottomGap),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Wrap(
            spacing: 8,
            children: [
              for (final f in ['Playlists', 'Artists', 'Albums', 'Podcasts'])
                Chip(label: Text(f), side: BorderSide.none),
            ],
          ),
        ),
        const _SectionHeader('Recently played'),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _Cover(index: i + 2, size: 120),
          ),
        ),
        const _SectionHeader('Your playlists'),
        for (var i = 0; i < 7; i++)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: _Cover(index: i + 1, size: 56, radius: 12),
            title: Text(
              'Playlist ${i + 1}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Playlist · ${8 + i * 3} songs'),
            trailing: const Icon(Icons.more_vert_rounded),
          ),
      ],
    );
  }
}

/// Profile — a header with avatar + stats, then a settings list.
class ProfileTab extends StatelessWidget {
  /// Creates the Profile tab.
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.only(bottom: _kBottomGap),
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: _grad(2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 52),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Ada Lovelace',
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Center(
          child: Text(
            '@ada_dev',
            style: text.bodyMedium?.copyWith(color: text.bodySmall?.color),
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Stat(value: '128', label: 'Playlists'),
            _Stat(value: '2.3k', label: 'Followers'),
            _Stat(value: '312', label: 'Following'),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 32),
        for (final (icon, title) in const [
          (Icons.account_circle_outlined, 'Account'),
          (Icons.notifications_none_rounded, 'Notifications'),
          (Icons.lock_outline_rounded, 'Privacy'),
          (Icons.download_outlined, 'Downloads'),
          (Icons.tune_rounded, 'Playback'),
          (Icons.info_outline_rounded, 'About'),
        ])
          ListTile(
            leading: Icon(icon),
            title: Text(title),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(label, style: text.bodySmall),
      ],
    );
  }
}
