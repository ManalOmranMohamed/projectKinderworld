import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/widgets/child_header.dart';
import 'package:kinder_world/features/child_mode/learn/coloring_page_screen.dart';
import 'package:kinder_world/features/child_mode/learn/coloring_progress_storage.dart';

class ColoringGalleryScreen extends StatefulWidget {
  const ColoringGalleryScreen({super.key});

  @override
  State<ColoringGalleryScreen> createState() => _ColoringGalleryScreenState();
}

class _ColoringGalleryScreenState extends State<ColoringGalleryScreen> {
  String _selectedLevel = 'All';
  final Map<String, ColoringProgressData> _progressBySvgPath = {};
  final Map<String, SvgColoringTemplate> _templateBySvgPath = {};

  static const List<String> _levels = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  static const List<Map<String, String>> _items = [
    {
      'title': 'Coloring Page 1',
      'image': 'assets/images/coloring/kids_coloring_20zones.svg',
      'svg': 'assets/images/coloring/kids_coloring_20zones.svg',
      'level': 'Beginner',
    },
        {
      'title': 'Coloring Page 2',
      'image': 'assets/images/coloring/house_coloring_17regions.svg',
      'svg': 'assets/images/coloring/house_coloring_17regions.svg',
      'level': 'Beginner',
    },
  ];

  List<Map<String, String>> get _filteredItems {
    if (_selectedLevel == 'All') return _items;
    return _items.where((item) => item['level'] == _selectedLevel).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadGalleryProgress();
  }

  Future<void> _loadGalleryProgress() async {
    final progressMap = <String, ColoringProgressData>{};
    final templateMap = <String, SvgColoringTemplate>{};

    for (final item in _items) {
      final svgPath = item['svg'];
      if (svgPath == null || svgPath.isEmpty) continue;
      progressMap[svgPath] = await ColoringProgressStorage.load(svgPath);

      try {
        final rawSvg = await rootBundle.loadString(svgPath);
        templateMap[svgPath] = SvgColoringTemplate.fromRawSvg(rawSvg);
      } catch (_) {
        // Keep gallery resilient if one SVG fails to parse.
      }
    }

    if (!mounted) return;
    setState(() {
      _progressBySvgPath
        ..clear()
        ..addAll(progressMap);
      _templateBySvgPath
        ..clear()
        ..addAll(templateMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Coloring',
          style: TextStyle(
            color: Color(0xFF1D4E89),
            fontWeight: FontWeight.w900,
            fontFamily: 'Comic Sans MS',
          ),
        ),
      ),
      body: Stack(
        children: [
          const _PlayfulBackground(),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ChildHeader(compact: true),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _levels.length,
                  itemBuilder: (context, index) {
                    final level = _levels[index];
                    final selected = level == _selectedLevel;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () => setState(() => _selectedLevel = level),
                        borderRadius: BorderRadius.circular(26),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFFF9CC9)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFFFF7AB4)
                                  : Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (selected
                                        ? const Color(0xFFFF9CC9)
                                        : const Color(0xFF9EDCFF))
                                    .withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              level,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Comic Sans MS',
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF1D4E89),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9EDCFF)
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Text(
                            'No coloring pages available',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Comic Sans MS',
                              color: Color(0xFF1D4E89),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final svgPath = item['svg']!;
                          final progress = _progressBySvgPath[svgPath];
                          final template = _templateBySvgPath[svgPath];
                          return _ColoringItemCard(
                            title: item['title']!,
                            imagePath: item['image']!,
                            previewTemplate: template,
                            previewColors:
                                progress?.colors ?? const <String, Color>{},
                            isCompleted: progress?.isCompleted ?? false,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ColoringPageScreen(
                                    svgAssetPath: item['svg']!,
                                    title: item['title']!,
                                  ),
                                ),
                              );
                              if (!mounted) return;
                              await _loadGalleryProgress();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColoringItemCard extends StatefulWidget {
  const _ColoringItemCard({
    required this.title,
    required this.imagePath,
    required this.previewColors,
    required this.isCompleted,
    required this.onTap,
    this.previewTemplate,
  });

  final String title;
  final String imagePath;
  final SvgColoringTemplate? previewTemplate;
  final Map<String, Color> previewColors;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  State<_ColoringItemCard> createState() => _ColoringItemCardState();
}

class _ColoringItemCardState extends State<_ColoringItemCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isSvg = widget.imagePath.toLowerCase().endsWith('.svg');
    final hasPreviewSvg = isSvg && widget.previewTemplate != null;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 130),
        scale: _pressed ? 0.97 : 1,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 122,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFFFF7D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF95D5FF).withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                  child: Container(
                    width: 126,
                    color: const Color(0xFFDDF3FF),
                    child: hasPreviewSvg
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SvgPicture.string(
                                    widget.previewTemplate!
                                        .buildAreasSvg(widget.previewColors),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SvgPicture.string(
                                    widget.previewTemplate!.outlineSvg,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : isSvg
                            ? Padding(
                                padding: const EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                  widget.imagePath,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Image.asset(
                                widget.imagePath,
                                width: 126,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 126,
                                    color: Colors.teal.shade50,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported_rounded,
                                      color: AppColors.skillful,
                                      size: 34,
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Comic Sans MS',
                                  color: Color(0xFF0B4A75),
                                ),
                              ),
                            ),
                            if (widget.isCompleted)
                              const _GallerySunStarBadge(),
                          ],
                        ),
                        if (widget.isCompleted) ...[
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(
                                Icons.wb_sunny_rounded,
                                size: 18,
                                color: Color(0xFFFFB300),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Great job!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2E7D32),
                                  fontFamily: 'Comic Sans MS',
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA5E17F),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFA5E17F)
                                    .withValues(alpha: 0.55),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Tap to Color',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Comic Sans MS',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD66B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD66B).withValues(alpha: 0.7),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF8B4E00),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayfulBackground extends StatelessWidget {
  const _PlayfulBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD5F1FF), Color(0xFFFFF9C9)],
              ),
            ),
          ),
        ),
        Positioned(
          top: 24,
          left: 20,
          child: Icon(Icons.star_rounded,
              color: Colors.white.withValues(alpha: 0.8), size: 18),
        ),
        Positioned(
          top: 58,
          right: 36,
          child: Icon(Icons.star_rounded,
              color: const Color(0xFFFFD54F).withValues(alpha: 0.9), size: 20),
        ),
      ],
    );
  }
}

class _GallerySunStarBadge extends StatelessWidget {
  const _GallerySunStarBadge();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: const [
        Icon(
          Icons.wb_sunny_rounded,
          color: Color(0xFFFFC107),
          size: 22,
        ),
        Positioned(
          right: -3,
          top: -4,
          child: Icon(
            Icons.star_rounded,
            color: Color(0xFFFF8F00),
            size: 12,
          ),
        ),
      ],
    );
  }
}
