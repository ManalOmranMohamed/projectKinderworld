import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/providers/auth_controller.dart';
import 'package:kinder_world/core/providers/profile_controller.dart';
import 'package:kinder_world/core/widgets/parent_design_system.dart';

class ParentProfileScreen extends ConsumerStatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  ConsumerState<ParentProfileScreen> createState() =>
      _ParentProfileScreenState();
}

class _ParentProfileScreenState extends ConsumerState<ParentProfileScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(AppLocalizations l10n) async {
    final name = _nameController.text.trim();

    if (name.isEmpty || name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterName),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(name: name);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdated),
            backgroundColor: ParentColors.parentGreen,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final meState = ref.watch(meProvider);
    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState.isLoading;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: colors.onSurface),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/parent/settings');
            }
          },
        ),
        title: Text(
          l10n.editProfile,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      body: SafeArea(
        child: meState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: ParentColors.alertRed),
                const SizedBox(height: 16),
                Text(l10n.error,
                    style: TextStyle(color: colors.onSurfaceVariant)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(meProvider),
                  style: FilledButton.styleFrom(
                      backgroundColor: ParentColors.parentGreen),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
          data: (user) {
            if (user == null) {
              return Center(child: Text(l10n.error));
            }
            if (_nameController.text.isEmpty && user.name != null) {
              _nameController.text = user.name!;
            }

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  // ── Avatar header ─────────────────────────────────────
                  ParentCard(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ParentColors.parentGreen,
                                ParentColors.parentGreenLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (user.name?.isNotEmpty == true)
                                  ? user.name![0].toUpperCase()
                                  : 'P',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name ?? '',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (user.email?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.email!,
                            style: TextStyle(
                                fontSize: 13,
                                color: colors.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Name field ────────────────────────────────────────
                  ParentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParentSectionHeader(title: l10n.nameLabel),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: l10n.enterYourName,
                            prefixIcon: const Icon(Icons.person_rounded,
                                color: ParentColors.parentGreen, size: 20),
                            filled: true,
                            fillColor: colors.surfaceContainerLowest,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: colors.outlineVariant),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: colors.outlineVariant),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: ParentColors.parentGreen, width: 2),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: colors.outlineVariant),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Email field (read-only) ────────────────────────────
                  ParentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParentSectionHeader(title: l10n.email),
                        const SizedBox(height: 12),
                        TextField(
                          controller:
                              TextEditingController(text: user.email ?? ''),
                          enabled: false,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email_rounded,
                                color: colors.onSurfaceVariant, size: 20),
                            filled: true,
                            fillColor: colors.surfaceContainerHighest,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Save button ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: isLoading ? null : () => _handleSave(l10n),
                      style: FilledButton.styleFrom(
                        backgroundColor: ParentColors.parentGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              l10n.save,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
