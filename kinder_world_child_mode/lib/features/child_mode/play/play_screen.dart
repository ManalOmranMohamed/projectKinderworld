import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/widgets/child_header.dart';
import 'package:kinder_world/features/child_mode/profile/child_profile_screen.dart';

class PlayScreen extends ConsumerStatefulWidget {
  const PlayScreen({super.key});

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  int _selectedTab = 0;
  String _searchQuery = '';

  static const _tabs = [
    {'label': 'All', 'icon': Icons.waves},
    {'label': 'Kindness', 'icon': Icons.favorite},
    {'label': 'Learning', 'icon': Icons.school},
    {'label': 'Skills', 'icon': Icons.handyman},
    {'label': 'Music', 'icon': Icons.music_note},
  ];

  static const _cards = [
    {
      'title': 'Tom & Jerry | Keep Calm',
      'duration': '1:27:03',
      'image': 'assets/images/ent_tomjerry.png',
      'tag': 'Entertaining',
    },
    {
      'title': 'Momo & Mimi | Arabic',
      'duration': '3:39',
      'image': 'assets/images/ent_momo.png',
      'tag': 'Entertaining',
    },
    {
      'title': 'Kindness Challenge',
      'duration': '7:00',
      'image': 'assets/images/behavior_kindness.png',
      'tag': 'Behavioral',
    },
    {
      'title': 'Build & Create',
      'duration': '5:20',
      'image': 'assets/images/skill_handcrafts.png',
      'tag': 'Skillful',
    },
    {
      'title': 'Math Basics | Fun',
      'duration': '8:10',
      'image': 'assets/images/educational_main.png',
      'tag': 'Educational',
    },
    {
      'title': 'Science Wonders',
      'duration': '6:45',
      'image': 'assets/images/edu_science.png',
      'tag': 'Educational',
    },
    {
      'title': 'Story Time',
      'duration': '4:12',
      'image': 'assets/images/behavior_love.png',
      'tag': 'Behavioral',
    },
    {
      'title': 'Coloring Fun',
      'duration': '5:05',
      'image': 'assets/images/skill_coloring.png',
      'tag': 'Skillful',
    },
    {
      'title': 'Alphabet Song',
      'duration': '2:30',
      'image': 'assets/images/edu_english.png',
      'tag': 'Educational',
    },
    {
      'title': 'Animal Friends',
      'duration': '3:55',
      'image': 'assets/images/edu_animals.png',
      'tag': 'Educational',
    },
    {
      'title': 'Dance Party',
      'duration': '4:20',
      'image': 'assets/images/ent_clips.png',
      'tag': 'Entertaining',
    },
    {
      'title': 'Sharing Time',
      'duration': '6:10',
      'image': 'assets/images/behavior_giving.png',
      'tag': 'Behavioral',
    },
    {
      'title': 'Puzzle Play',
      'duration': '5:40',
      'image': 'assets/images/skill_handcrafts.png',
      'tag': 'Skillful',
    },
  ];

  List<Map<String, String>> get _suggestedCards {
    final query = _searchQuery.trim().toLowerCase();
    final label = _tabs[_selectedTab]['label'] as String;
    final tag = switch (label) {
      'Kindness' => 'Behavioral',
      'Learning' => 'Educational',
      'Skills' => 'Skillful',
      'Music' => 'Entertaining',
      _ => label,
    };
    final base = label == 'All'
        ? _cards
        : _cards.where((card) => card['tag'] == tag).toList();
    final filtered = query.isEmpty
        ? base
        : base
            .where((card) =>
                (card['title'] ?? '').toLowerCase().contains(query))
            .toList();
    final seed = query.hashCode ^ _selectedTab.hashCode;
    final list = filtered.toList()..shuffle(Random(seed));
    return list.cast<Map<String, String>>();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        context.go('/child/home');
                      }
                    },
                  ),
                  const ChildHeader(compact: true),
                  const Spacer(),
                  _iconBubble(Icons.cast, onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cast coming soon')),
                    );
                  }),
                  const SizedBox(width: 10),
                  _iconBubble(Icons.shield_outlined, onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Safe mode enabled')),
                    );
                  }),
                  const SizedBox(width: 10),
                  _iconBubble(Icons.settings, onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChildSettingsScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTabs(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search videos...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                itemBuilder: (context, index) {
                  final card = _suggestedCards[index];
                  return _buildMediaCard(card);
                },
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemCount: _suggestedCards.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTab == index;
          final colors = Theme.of(context).colorScheme;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 18,
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? colors.onPrimary : colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaCard(Map<String, String> card) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Image.asset(
                  card['image'] ?? '',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: colors.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.play_circle, size: 40)),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      card['duration'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              card['title'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBubble(IconData icon, {VoidCallback? onTap}) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: colors.onSurface),
      ),
    );
  }
}
