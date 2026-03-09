import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/models/admin_child_record.dart';
import 'package:kinder_world/features/admin/auth/admin_auth_provider.dart';
import 'package:kinder_world/features/admin/management/admin_management_repository.dart';
import 'package:kinder_world/features/admin/shared/admin_permission_placeholder.dart';

/// IMPORTANT:
/// All UI text must use AppLocalizations.
/// Hardcoded strings are NOT allowed.

class AdminChildDetailsScreen extends ConsumerStatefulWidget {
  const AdminChildDetailsScreen({
    super.key,
    required this.childId,
  });

  final int childId;

  @override
  ConsumerState<AdminChildDetailsScreen> createState() => _AdminChildDetailsScreenState();
}

class _AdminChildDetailsScreenState extends ConsumerState<AdminChildDetailsScreen> {
  AdminChildRecord? _child;
  Map<String, dynamic>? _progress;
  Map<String, dynamic>? _activityLog;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(adminManagementRepositoryProvider);
      final child = await repo.fetchChildDetail(widget.childId);
      final progress = await repo.fetchChildProgress(widget.childId);
      final activityLog = await repo.fetchChildActivityLog(widget.childId);
      if (!mounted) return;
      setState(() {
        _child = child;
        _progress = progress;
        _activityLog = activityLog;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final admin = ref.watch(currentAdminProvider);
    if (!(admin?.hasPermission('admin.children.view') ?? false)) {
      return const AdminPermissionPlaceholder();
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _child == null) {
      return Center(child: Text(_error ?? l10n.error));
    }

    final summary = Map<String, dynamic>.from(_progress?['summary'] as Map? ?? const {});
    final milestones = List<Map<String, dynamic>>.from(
      (_progress?['milestones'] as List<dynamic>? ?? const []).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );
    final entries = List<Map<String, dynamic>>.from(
      (_activityLog?['entries'] as List<dynamic>? ?? const []).map(
        (item) => Map<String, dynamic>.from(item as Map),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminChildrenDetailTitle(_child!.name),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _CardBlock(
                title: l10n.adminChildrenOverviewCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l10n.adminChildrenNameField}: ${_child!.name}'),
                    Text('${l10n.adminChildrenAgeColumn}: ${_child!.age ?? '—'}'),
                    Text('${l10n.adminChildrenParentColumn}: ${_child!.parent?['email'] ?? _child!.parentId}'),
                    Text('${l10n.adminChildrenStatusColumn}: ${_child!.isActive ? l10n.adminUsersStatusActive : l10n.adminUsersStatusDisabled}'),
                  ],
                ),
              ),
              _CardBlock(
                title: l10n.adminChildrenProgressCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${l10n.adminChildrenProgressDaysMetric}: ${summary['days_since_profile_created'] ?? 0}'),
                    Text('${l10n.adminChildrenProgressEventsMetric}: ${summary['audit_events'] ?? 0}'),
                    Text('${l10n.adminUsersLastUpdatedMetric}: ${summary['last_updated_at'] ?? _child!.updatedAt ?? '—'}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _CardBlock(
            title: l10n.adminChildrenMilestonesSection,
            child: Column(
              children: milestones
                  .map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.flag_outlined),
                      title: Text(entry['title'] as String? ?? '—'),
                      subtitle: Text(entry['timestamp'] as String? ?? ''),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          _CardBlock(
            title: l10n.adminChildrenActivitySection,
            child: Column(
              children: entries
                  .map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        entry['type'] == 'audit' ? Icons.history : Icons.notifications_outlined,
                      ),
                      title: Text(
                        entry['title'] as String? ??
                            entry['action'] as String? ??
                            entry['type'] as String? ??
                            '—',
                      ),
                      subtitle: Text(
                        entry['created_at'] as String? ??
                            entry['timestamp'] as String? ??
                            '',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBlock extends StatelessWidget {
  const _CardBlock({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
