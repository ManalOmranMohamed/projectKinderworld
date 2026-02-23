import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/app.dart';

class LegalScreen extends ConsumerWidget {
  final String type;

  const LegalScreen({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = _getTitle(type);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final endpoint = _getEndpoint(type);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: ref
              .read(networkServiceProvider)
              .get<Map<String, dynamic>>(endpoint)
              .then((value) => value.data ?? {}),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final body = snapshot.data?['body']?.toString();
            if (body == null || body.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description,
                        size: 72,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No content yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getPlaceholder(type),
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: colors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Text(
                  body,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getTitle(String type) {
    switch (type) {
      case 'terms':
        return 'Terms of Service';
      case 'privacy':
        return 'Privacy Policy';
      case 'coppa':
        return 'COPPA & Children\'s Privacy';
      default:
        return 'Legal';
    }
  }

  static String _getPlaceholder(String type) {
    switch (type) {
      case 'terms':
        return 'Terms will be available soon.';
      case 'privacy':
        return 'Privacy policy details are coming soon.';
      case 'coppa':
        return 'COPPA compliance information will be posted shortly.';
      default:
        return 'We will share the requested information soon.';
    }
  }

  String _getEndpoint(String type) {
    switch (type) {
      case 'terms':
        return '/legal/terms';
      case 'privacy':
        return '/legal/privacy';
      case 'coppa':
        return '/legal/coppa';
      default:
        return '/legal/terms';
    }
  }
}
