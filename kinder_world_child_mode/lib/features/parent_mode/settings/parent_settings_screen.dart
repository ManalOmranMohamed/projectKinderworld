import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/providers/auth_controller.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';
import 'package:kinder_world/router.dart';

class ParentSettingsScreen extends ConsumerWidget {
  const ParentSettingsScreen({super.key});

  void _safeNavigate(VoidCallback action) {
    Future.microtask(action);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.go(Routes.parentDashboard);
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 8),

            // Account Section
            _buildSectionHeader(context, l10n.accountSection),
            _buildSettingItem(
              context,
              l10n.profileLabel,
              Icons.person,
              onTap: () {
                _safeNavigate(
                  () => context.push(Routes.parentProfile),
                );
              },
            ),
            _buildSettingItem(
              context,
              l10n.changePassword,
              Icons.lock,
              onTap: () {
                _safeNavigate(
                  () => context.push(Routes.parentChangePassword),
                );
              },
            ),
                _buildSettingItem(
                  context,
                  l10n.notifications,
                  Icons.notifications,
                  onTap: () {
                    _safeNavigate(
                      () => context.push(Routes.parentNotifications),
                    );
                  },
                ),

            const SizedBox(height: 24),

            // Family Section
            _buildSectionHeader(context, l10n.familySection),
              _buildSettingItem(
                context,
                l10n.childProfiles,
                Icons.child_care,
                onTap: () {
                  _safeNavigate(
                    () => context.push(Routes.parentChildManagement),
                  );
                },
              ),
              _buildSettingItem(
                context,
                l10n.subscription,
                Icons.payment,
                onTap: () {
                  _safeNavigate(
                    () => context.push(Routes.parentSubscription),
                  );
                },
              ),
              _buildSettingItem(
                context,
                l10n.parentalControls,
                Icons.security,
                onTap: () {
                  _safeNavigate(
                    () => context.push(Routes.parentControls),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionHeader(context, l10n.preferencesSection),
            _buildSettingItem(
              context,
              l10n.language,
              Icons.language,
              onTap: () {
                _safeNavigate(
                  () => context.push(Routes.parentLanguage),
                );
              },
            ),
            _buildSettingItem(
              context,
              l10n.theme,
              Icons.palette,
              onTap: () {
                _safeNavigate(
                  () => context.push(Routes.parentTheme),
                );
              },
            ),
            _buildSettingItem(
              context,
              l10n.privacySettings,
              Icons.privacy_tip,
              onTap: () {
                _safeNavigate(
                  () => context.push(Routes.parentPrivacySettings),
                );
              },
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader(context, l10n.supportSection),
            _buildSettingItem(
              context,
              l10n.helpFaq,
              Icons.help,
              onTap: () {
                _safeNavigate(
                  () => context.push(Routes.parentHelp),
                );
              },
            ),
            _buildSettingItem(
              context,
              l10n.contactUs,
              Icons.contact_mail,
              onTap: () {
                _safeNavigate(
                  () => context.push(Routes.parentContactUs),
                );
              },
            ),
            _buildSettingItem(
              context,
              l10n.about,
              Icons.info,
              onTap: () {
                _safeNavigate(
                  () => context.push(Routes.parentAbout),
                );
              },
            ),

            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                await ref
                    .read(childSessionControllerProvider.notifier)
                    .endChildSession();
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go(Routes.selectUserType);
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: AppConstants.fontSize,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: colors.primary, size: 20),
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(
          fontSize: AppConstants.fontSize,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
