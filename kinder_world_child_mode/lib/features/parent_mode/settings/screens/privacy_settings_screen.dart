import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/providers/privacy_provider.dart';

class ParentPrivacySettingsScreen extends ConsumerWidget {
  const ParentPrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyState = ref.watch(privacyProvider);
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.parentPrivacySettings ?? 'Privacy Settings'),
        elevation: 0,
      ),
      body: privacyState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading privacy settings'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(privacyProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (privacySettings) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Analytics toggle
                SwitchListTile(
                  title: const Text('Analytics'),
                  subtitle: const Text('Help improve Kinder World with usage data'),
                  value: privacySettings.analyticsEnabled,
                  onChanged: (value) {
                    ref.read(privacyControllerProvider.notifier).updateSettings(
                          privacySettings.copyWith(
                            analyticsEnabled: value,
                          ),
                        );
                  },
                ),
                const Divider(),

                // Personalized recommendations toggle
                SwitchListTile(
                  title: const Text('Personalized Recommendations'),
                  subtitle: const Text('Receive customized content suggestions'),
                  value:
                      privacySettings.personalizedRecommendations,
                  onChanged: (value) {
                    ref.read(privacyControllerProvider.notifier).updateSettings(
                          privacySettings.copyWith(
                            personalizedRecommendations: value,
                          ),
                        );
                  },
                ),
                const Divider(),

                // Data collection opt-out toggle
                SwitchListTile(
                  title: const Text('Opt-out of Data Collection'),
                  subtitle: const Text('Do not collect any usage data'),
                  value: privacySettings.dataCollectionOptOut,
                  onChanged: (value) {
                    ref.read(privacyControllerProvider.notifier).updateSettings(
                          privacySettings.copyWith(
                            dataCollectionOptOut: value,
                          ),
                        );
                  },
                ),

                const SizedBox(height: 32),

                // Info section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    border: Border.all(color: colors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy Information',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your privacy is important to us. These settings control what data we collect and how it is used to improve your experience.',
                        style: textTheme.bodySmall?.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
