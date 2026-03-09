import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/models/admin_parent_user.dart';
import 'package:kinder_world/features/admin/auth/admin_auth_provider.dart';
import 'package:kinder_world/features/admin/management/admin_management_repository.dart';
import 'package:kinder_world/features/admin/shared/admin_permission_placeholder.dart';
import 'package:kinder_world/router.dart';

/// IMPORTANT:
/// All UI text must use AppLocalizations.
/// Hardcoded strings are NOT allowed.

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String _status = 'all';
  int _page = 1;
  bool _loading = true;
  String? _error;
  List<AdminParentUser> _users = const [];
  Map<String, dynamic> _pagination = const {};

  List<DropdownMenuItem<String>> _planItems(AppLocalizations l10n) => [
        DropdownMenuItem(
          value: 'FREE',
          child: Text(l10n.adminPlanFree),
        ),
        DropdownMenuItem(
          value: 'PREMIUM',
          child: Text(l10n.adminPlanPremium),
        ),
        DropdownMenuItem(
          value: 'FAMILY_PLUS',
          child: Text(l10n.adminPlanFamilyPlus),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response =
          await ref.read(adminManagementRepositoryProvider).fetchUsers(
                search: _searchController.text,
                status: _status,
                page: _page,
              );
      if (!mounted) return;
      setState(() {
        _users = response.items;
        _pagination = response.pagination;
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

  Future<void> _showEditDialog(AdminParentUser user) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    String plan = user.plan;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.adminUsersEditTitle),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.adminUsersNameField,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: l10n.adminUsersEmailField,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: plan,
                    items: _planItems(l10n),
                    onChanged: (value) => setState(() => plan = value ?? plan),
                    decoration: InputDecoration(
                      labelText: l10n.adminUsersPlanField,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (saved != true) return;

    await ref.read(adminManagementRepositoryProvider).updateUser(
          user.id,
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          plan: plan,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              l10n.adminUsersUpdatedMessage)),
    );
    await _loadUsers();
  }

  Future<void> _toggleEnabled(AdminParentUser user, bool enabled) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              enabled
                  ? l10n.adminUsersEnableTitle
                  : l10n.adminUsersDisableTitle,
            ),
            content: Text(
              enabled
                  ? l10n.adminUsersEnableConfirm
                  : l10n.adminUsersDisableConfirm,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  enabled
                      ? l10n.adminUsersEnableAction
                      : l10n.adminUsersDisableAction,
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    await ref
        .read(adminManagementRepositoryProvider)
        .setUserEnabled(user.id, enabled);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? l10n.adminUsersEnabledMessage
              : l10n.adminUsersDisabledMessage,
        ),
      ),
    );
    await _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final admin = ref.watch(currentAdminProvider);
    if (!(admin?.hasPermission('admin.users.view') ?? false)) {
      return const AdminPermissionPlaceholder();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminUsersTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(l10n.adminUsersSubtitle),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: l10n.adminUsersSearchLabel,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onSubmitted: (_) {
                    _page = 1;
                    _loadUsers();
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: InputDecoration(
                    labelText: l10n.adminUsersStatusFilter,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text(l10n.adminUsersStatusAll),
                    ),
                    DropdownMenuItem(
                      value: 'active',
                      child: Text(l10n.adminUsersStatusActive),
                    ),
                    DropdownMenuItem(
                      value: 'disabled',
                      child: Text(l10n.adminUsersStatusDisabled),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _status = value ?? 'all';
                      _page = 1;
                    });
                    _loadUsers();
                  },
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ))
          else if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!),
              ),
            )
          else
            Card(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                        label: Text(l10n.adminUsersNameColumn)),
                    DataColumn(
                        label: Text(l10n.adminUsersEmailColumn)),
                    DataColumn(
                        label: Text(l10n.adminUsersPlanColumn)),
                    DataColumn(
                        label:
                            Text(l10n.adminUsersChildrenColumn)),
                    DataColumn(
                        label: Text(l10n.adminUsersStatusColumn)),
                    DataColumn(
                        label:
                            Text(l10n.adminUsersActionsColumn)),
                  ],
                  rows: _users
                      .map(
                        (user) => DataRow(
                          cells: [
                            DataCell(Text(user.name.isEmpty ? '—' : user.name)),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.plan)),
                            DataCell(Text('${user.childCount}')),
                            DataCell(
                              Chip(
                                label: Text(
                                  user.isActive
                                      ? (l10n.adminUsersStatusActive)
                                      : (l10n.adminUsersStatusDisabled),
                                ),
                              ),
                            ),
                            DataCell(
                              Wrap(
                                spacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: () => context
                                        .go('${Routes.adminUsers}/${user.id}'),
                                    child: Text(
                                        l10n.adminUsersViewAction),
                                  ),
                                  TextButton(
                                    onPressed: () => _showEditDialog(user),
                                    child: Text(l10n.edit),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _toggleEnabled(user, !user.isActive),
                                    child: Text(
                                      user.isActive
                                          ? (l10n.adminUsersDisableAction)
                                          : (l10n.adminUsersEnableAction),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.adminPaginationSummary(
                      (_pagination['page'] as int?) ?? _page,
                      (_pagination['total_pages'] as int?) ?? 1,
                      (_pagination['total'] as int?) ?? _users.length,
                    ),
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: ((_pagination['has_previous'] as bool?) ?? false)
                        ? () {
                            setState(() => _page -= 1);
                            _loadUsers();
                          }
                        : null,
                    child: Text(l10n.adminPaginationPrevious),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: ((_pagination['has_next'] as bool?) ?? false)
                        ? () {
                            setState(() => _page += 1);
                            _loadUsers();
                          }
                        : null,
                    child: Text(l10n.adminPaginationNext),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
