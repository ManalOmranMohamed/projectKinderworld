// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/models/activity.dart';
import 'package:kinder_world/core/providers/content_controller.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/utils/color_compat.dart';
import 'package:kinder_world/core/widgets/child_header.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/features/child_mode/learn/data/learn_catalog.dart';
import 'package:kinder_world/features/child_mode/learn/coloring_gallery_screen.dart';
import 'package:kinder_world/routing/route_paths.dart';

part 'widgets/learn_screen_sections.dart';
part 'learn_support_screens.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  String _searchQuery = '';

  List<Map<String, dynamic>> get _categories => learnCategories;
  List<Map<String, String>> get _searchItems => learnSearchItems;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentState = ref.watch(contentControllerProvider);
    final searchEntries = _buildSearchEntries(contentState.activities);
    final results =
        _filterSearchResults(contentState.activities, searchEntries);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _slideAnimation.value,
          child: child,
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LearnSearchField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  onSubmitted: (value) =>
                      _handleSubmittedQuery(context, value, searchEntries),
                ),
                const SizedBox(height: 16),
                if (contentState.isLoading && contentState.activities.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(),
                  ),
                if (contentState.error != null &&
                    contentState.activities.isEmpty) ...[
                  _LearnContentErrorCard(
                    errorText: contentState.error!,
                    onRetry: () {
                      ref
                          .read(contentControllerProvider.notifier)
                          .loadAllActivities();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                const ChildHeader(
                  padding: EdgeInsets.only(bottom: 24),
                ),
                _LearnIntroBanner(
                  activityCount: contentState.activities.length,
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: _LearnResultsGrid(
                    results: results,
                    activities: contentState.activities,
                    localizedTitleBuilder: (title) =>
                        _localizedSearchTitle(context, title),
                    onOpenSearchResult: (result) =>
                        _openSearchResult(context, result),
                    onOpenCategory: (route) => _openCategory(context, route),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmittedQuery(
    BuildContext context,
    String value,
    List<Map<String, dynamic>> searchEntries,
  ) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) return;

    final match = searchEntries.firstWhere(
      (entry) => (entry['title'] as String).toLowerCase() == query,
      orElse: () => <String, dynamic>{},
    );
    if (match.isNotEmpty) {
      _openSearchResult(context, match);
    }
  }

  List<Map<String, dynamic>> _filterSearchResults(
    List<Activity> activities,
    List<Map<String, dynamic>> searchEntries,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _categories;
    }
    return searchEntries
        .where(
            (entry) => (entry['title'] as String).toLowerCase().contains(query))
        .toList();
  }

  void _openCategory(BuildContext context, String route) {
    Widget? screen;
    switch (route) {
      case 'educational':
        screen = const EducationalScreen();
        break;
      case 'behavioral':
        screen = const BehavioralScreen();
        break;
      case 'skillful':
        screen = const SkillfulScreen();
        break;
      case 'entertaining':
        screen = const EntertainingScreen();
        break;
    }
    if (screen == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen!),
    );
  }

  void _openSearchResult(BuildContext context, Map<String, dynamic> result) {
    final lessonId = result['lessonId']?.toString();
    if (lessonId != null && lessonId.isNotEmpty) {
      context.push('${Routes.childLearn}/lesson/$lessonId');
      return;
    }
    _openCategory(context, result['route'] as String);
  }

  List<Map<String, dynamic>> _buildSearchEntries(List<Activity> activities) {
    final entries = _searchItems
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: true);
    for (final activity in activities) {
      entries.add({
        'title': activity.title,
        'route': activity.aspect,
        if (activity.type == ActivityTypes.lesson) 'lessonId': activity.id,
      });
    }
    return entries;
  }

  String _localizedSearchTitle(BuildContext context, String title) {
    final l10n = AppLocalizations.of(context)!;
    switch (title) {
      case 'Behavioral':
        return l10n.categoryBehavioral;
      case 'Educational':
        return l10n.categoryEducational;
      case 'Skillful':
        return l10n.categorySkillful;
      case 'Entertaining':
        return l10n.categoryEntertaining;
      default:
        return title;
    }
  }
}
