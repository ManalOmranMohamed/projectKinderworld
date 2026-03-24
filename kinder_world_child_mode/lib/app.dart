import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kinder_world/core/localization/app_localizations.dart'
    as custom_localizations;
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/theme/app_theme.dart';
import 'package:kinder_world/core/navigation/app_navigation_controller.dart';
import 'package:kinder_world/core/providers/app_services.dart';
import 'package:kinder_world/core/providers/connectivity_provider.dart';
import 'package:kinder_world/core/providers/deferred_operations_provider.dart';
import 'package:kinder_world/core/providers/locale_provider.dart';
import 'package:kinder_world/core/providers/progress_controller.dart';
import 'package:kinder_world/core/providers/sync_status_provider.dart';
import 'package:kinder_world/router.dart';
import 'package:kinder_world/core/providers/theme_provider.dart';
import 'package:kinder_world/core/providers/accessibility_provider.dart';
import 'package:kinder_world/core/widgets/gamification_widgets.dart';

export 'package:kinder_world/core/providers/app_services.dart'
    show loggerProvider, networkServiceProvider, secureStorageProvider;

class KinderWorldApp extends ConsumerStatefulWidget {
  const KinderWorldApp({super.key});

  @override
  ConsumerState<KinderWorldApp> createState() => _KinderWorldAppState();
}

class _KinderWorldAppState extends ConsumerState<KinderWorldApp> {
  late final ProviderSubscription<GoRouter> _routerSubscription;

  @override
  void initState() {
    super.initState();
    final navigationController = ref.read(appNavigationControllerProvider);
    navigationController.attach(ref.read(routerProvider));
    _routerSubscription = ref.listenManual<GoRouter>(
      routerProvider,
      (_, next) => navigationController.attach(next),
    );
  }

  @override
  void dispose() {
    _routerSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final themeSettings = ref.watch(themeControllerProvider);
    final palette = ref.watch(themePaletteProvider);
    final accessibility = ref.watch(accessibilityProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) =>
          custom_localizations.AppLocalizations.of(context)?.appTitle ??
          'Kinder World',
      debugShowCheckedModeBanner: false,
      theme: accessibility.highContrastEnabled
          ? AppTheme.highContrastLightTheme(palette: palette)
          : AppTheme.lightTheme(palette: palette),
      darkTheme: accessibility.highContrastEnabled
          ? AppTheme.highContrastDarkTheme(palette: palette)
          : AppTheme.darkTheme(palette: palette),
      themeMode: themeSettings.mode,
      themeAnimationCurve: Curves.easeInOutCubic,
      themeAnimationDuration: const Duration(milliseconds: 250),
      localizationsDelegates: const [
        custom_localizations.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      locale: locale,
      routerConfig: router,

      // Builder for app-level configurations
      builder: (context, child) {
        // Force text direction based on locale
        final isRTL = locale.languageCode == 'ar';

        // Apply large font scaling when accessibility large font is enabled
        Widget content = child!;
        if (accessibility.largeFontEnabled) {
          content = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: content,
          );
        }

        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: AppNavigationBackHandler(
            // GamificationRewardListener listens for pending rewards
            // (LevelUp / AchievementUnlocked) and shows overlay dialogs/banners
            // on top of whatever screen is currently active.
            child: GamificationRewardListener(
              child: _ConnectivityGuard(child: content),
            ),
          ),
        );
      },
    );
  }
}

class _ConnectivityGuard extends ConsumerStatefulWidget {
  const _ConnectivityGuard({required this.child});

  final Widget child;

  @override
  ConsumerState<_ConnectivityGuard> createState() => _ConnectivityGuardState();
}

class _ConnectivityGuardState extends ConsumerState<_ConnectivityGuard> {
  bool _isOffline = false;
  bool _didShowOfflineHint = false;
  late final ProviderSubscription<AsyncValue<ConnectivityResult>> _subscription;

  void _handleConnectivityChange(ConnectivityResult result) {
    final logger = ref.read(loggerProvider);
    final isOffline = result == ConnectivityResult.none;

    if (isOffline && !_isOffline) {
      _isOffline = true;
      _didShowOfflineHint = false;
      ref.read(syncStatusProvider.notifier).setOffline();
      logger.w('event=connectivity.offline_entered');
      return;
    }

    if (!isOffline && _isOffline) {
      _isOffline = false;
      final syncStatus = ref.read(syncStatusProvider.notifier);
      logger
          .i('event=connectivity.online_restored action=process_pending_sync');
      Future<void>(() async {
        final queue = ref.read(deferredOperationsQueueProvider);
        final network = ref.read(networkServiceProvider);
        final progressController =
            ref.read(progressControllerProvider.notifier);
        final pendingDeferred = await queue.pendingCount();
        final pendingProgress =
            await progressController.getRecordsNeedingSync();
        if (pendingDeferred > 0 || pendingProgress.isNotEmpty) {
          syncStatus.beginSync();
        } else {
          syncStatus.setOnline();
        }
        try {
          final processed = await queue.processPending(network);
          await progressController.syncWithServer();
          logger.i('event=connectivity.sync_complete processed=$processed');
        } finally {
          syncStatus.setOnline();
        }
      });
      return;
    }

    if (!isOffline) {
      ref.read(syncStatusProvider.notifier).setOnline();
    }
  }

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual<AsyncValue<ConnectivityResult>>(
      connectivityProvider,
      (previous, next) {
        final result = next.asData?.value;
        if (result == null) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _handleConnectivityChange(result);
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOffline && !_didShowOfflineHint) {
      _didShowOfflineHint = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final l10n = custom_localizations.AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              l10n?.offlineSyncHint ??
                  'Some actions will sync when you reconnect.',
            ),
          ),
        );
      });
    }

    if (!_isOffline) {
      return widget.child;
    }

    final colors = Theme.of(context).colorScheme;
    final l10n = custom_localizations.AppLocalizations.of(context);
    return Stack(
      children: [
        widget.child,
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 0),
              padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: colors.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 18,
                    color: colors.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.offlineMode ?? 'Offline mode',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.onErrorContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
