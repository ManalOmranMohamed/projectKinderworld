import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:kinder_world/app.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/navigation/app_navigation_controller.dart';
import 'package:kinder_world/core/network/network_service.dart';
import 'package:kinder_world/core/providers/ai_buddy_provider.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';
import 'package:kinder_world/core/providers/plan_provider.dart';
import 'package:kinder_world/core/providers/shared_preferences_provider.dart';
import 'package:kinder_world/core/storage/secure_storage.dart';
import 'package:kinder_world/core/subscription/plan_info.dart';
import 'package:kinder_world/core/theme/app_theme.dart';
import 'package:kinder_world/core/theme/theme_palette.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestSecureStorage extends SecureStorage {
  TestSecureStorage({
    this.authToken,
    this.refreshToken,
    this.parentAccessToken,
    this.parentRefreshToken,
    this.userId,
    this.userEmail,
    this.userRole,
    this.childSession,
    this.parentId,
    this.parentEmail,
    this.parentPinVerified = false,
  });

  String? authToken;
  String? refreshToken;
  String? parentAccessToken;
  String? parentRefreshToken;
  String? userId;
  String? userEmail;
  String? userRole;
  String? childSession;
  String? parentId;
  String? parentEmail;
  bool parentPinVerified;

  @override
  bool get hasCachedSessionSnapshot => true;

  @override
  bool get hasCachedAuthToken => authToken != null;

  @override
  bool get hasCachedParentPinVerification => true;

  @override
  bool get hasCachedUserId => userId != null;

  @override
  bool get hasCachedUserEmail => userEmail != null;

  @override
  String? get cachedAuthToken => authToken;

  @override
  String? get cachedUserId => userId;

  @override
  String? get cachedUserEmail => userEmail;

  @override
  SecureSessionSnapshot get cachedSessionSnapshot => SecureSessionSnapshot(
        authToken: authToken,
        userRole: userRole,
        childSession: childSession,
        parentPinVerified: parentPinVerified,
      );

  @override
  Future<String?> getAuthToken() async => authToken;

  @override
  Future<bool> saveAuthToken(String token) async {
    authToken = token;
    return true;
  }

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<bool> saveRefreshToken(String token) async {
    refreshToken = token;
    return true;
  }

  @override
  Future<bool> deleteRefreshToken() async {
    refreshToken = null;
    return true;
  }

  @override
  Future<String?> getUserId() async => userId;

  @override
  Future<bool> saveUserId(String value) async {
    userId = value;
    return true;
  }

  @override
  Future<String?> getUserEmail() async => userEmail;

  @override
  Future<bool> saveUserEmail(String value) async {
    userEmail = value;
    return true;
  }

  @override
  Future<bool> deleteUserEmail() async {
    userEmail = null;
    return true;
  }

  @override
  Future<String?> getUserRole() async => userRole;

  @override
  Future<bool> saveUserRole(String value) async {
    userRole = value;
    return true;
  }

  @override
  Future<String?> getChildSession() async => childSession;

  @override
  Future<bool> saveChildSession(String childId) async {
    childSession = childId;
    return true;
  }

  @override
  Future<bool> clearChildSession() async {
    childSession = null;
    return true;
  }

  @override
  Future<bool> saveParentPinVerified(bool isVerified) async {
    parentPinVerified = isVerified;
    return true;
  }

  @override
  Future<bool> isParentPinVerified() async => parentPinVerified;

  @override
  Future<bool> clearParentPinVerification() async {
    parentPinVerified = false;
    return true;
  }

  @override
  Future<String?> getParentAccessToken() async => parentAccessToken;

  @override
  Future<bool> saveParentAccessToken(String token) async {
    parentAccessToken = token;
    return true;
  }

  @override
  Future<String?> getParentRefreshToken() async => parentRefreshToken;

  @override
  Future<bool> saveParentRefreshToken(String token) async {
    parentRefreshToken = token;
    return true;
  }

  @override
  Future<bool> saveStoredParentId(String value) async {
    parentId = value;
    return true;
  }

  @override
  Future<bool> saveStoredParentEmail(String value) async {
    parentEmail = value;
    return true;
  }

  @override
  Future<bool> clearStoredParentSession() async {
    parentId = null;
    parentEmail = null;
    return true;
  }

  @override
  Future<String?> getParentId() async => parentId ?? userId;

  @override
  Future<String?> getParentEmail() async => parentEmail ?? userEmail;

  @override
  Future<bool> clearAuthOnly() async {
    authToken = null;
    refreshToken = null;
    parentAccessToken = null;
    parentRefreshToken = null;
    userId = null;
    userEmail = null;
    userRole = null;
    childSession = null;
    parentId = null;
    parentEmail = null;
    parentPinVerified = false;
    return true;
  }

  @override
  Future<bool> isAuthenticated() async =>
      authToken != null && authToken!.isNotEmpty;
}

class TestNetworkService extends NetworkService {
  TestNetworkService({
    required super.secureStorage,
    Logger? logger,
  }) : super(logger: logger ?? Logger());

  Never _unstubbed(String method, String path) {
    throw UnsupportedError('Unstubbed test network call: $method $path');
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    _unstubbed('GET', path);
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _unstubbed('POST', path);
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _unstubbed('PUT', path);
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _unstubbed('PATCH', path);
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _unstubbed('DELETE', path);
  }
}

class TestHarness {
  TestHarness._({
    required this.secureStorage,
    required this.sharedPreferences,
    required this.logger,
    required this.networkService,
    required this.navigationController,
    required List<Override> baseOverrides,
  }) : _baseOverrides = List<Override>.unmodifiable(baseOverrides);

  static const List<String> defaultHiveBoxes = <String>[
    'child_profiles',
    'activities',
    'progress_records',
    'gamification_data',
    'mood_entries',
  ];

  static Directory? _hiveDirectory;
  static bool _hiveInitialized = false;

  final TestSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;
  final Logger logger;
  final NetworkService networkService;
  final AppNavigationController navigationController;
  final List<Override> _baseOverrides;

  static Future<void> ensureHiveReady({
    List<String> boxes = defaultHiveBoxes,
  }) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    if (!_hiveInitialized) {
      _hiveDirectory ??=
          await Directory.systemTemp.createTemp('kinder_world_test_hive_');
      Hive.init(_hiveDirectory!.path);
      _hiveInitialized = true;
    }

    for (final boxName in boxes) {
      final box = Hive.isBoxOpen(boxName)
          ? Hive.box<dynamic>(boxName)
          : await Hive.openBox<dynamic>(boxName);
      await box.clear();
    }
  }

  static Future<TestHarness> create({
    Map<String, Object> initialSharedPreferences = const <String, Object>{},
    bool initializeHive = false,
    List<String> hiveBoxes = defaultHiveBoxes,
    TestSecureStorage? secureStorage,
    Logger? logger,
    NetworkService? networkService,
    AppNavigationController? navigationController,
    ChildProfile? currentChild,
    ChildSessionState? childSessionState,
    AsyncValue<PlanInfo>? planInfoState,
    List<Override> overrides = const <Override>[],
  }) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    if (initializeHive) {
      await ensureHiveReady(boxes: hiveBoxes);
    }

    SharedPreferences.setMockInitialValues(initialSharedPreferences);
    final sharedPreferences = await SharedPreferences.getInstance();
    final resolvedStorage = secureStorage ?? TestSecureStorage();
    final resolvedLogger = logger ?? Logger();
    final resolvedNetwork = networkService ??
        TestNetworkService(
          secureStorage: resolvedStorage,
          logger: resolvedLogger,
        );
    final resolvedNavigationController =
        navigationController ?? AppNavigationController();

    final resolvedChildState = childSessionState ??
        (currentChild == null
            ? null
            : ChildSessionState(
                childId: currentChild.id,
                childProfile: currentChild,
                isLoading: false,
              ));

    final baseOverrides = <Override>[
      loggerProvider.overrideWithValue(resolvedLogger),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      secureStorageProvider.overrideWithValue(resolvedStorage),
      networkServiceProvider.overrideWithValue(resolvedNetwork),
      appNavigationControllerProvider.overrideWithValue(
        resolvedNavigationController,
      ),
    ];

    if (resolvedChildState != null) {
      baseOverrides.addAll(<Override>[
        currentChildProvider.overrideWithValue(resolvedChildState.childProfile),
        currentChildIdProvider.overrideWithValue(resolvedChildState.childId),
        hasChildSessionProvider.overrideWithValue(
          resolvedChildState.hasActiveSession,
        ),
        childLoadingProvider.overrideWithValue(resolvedChildState.isLoading),
        childErrorProvider.overrideWithValue(resolvedChildState.error),
        aiBuddyCurrentChildProvider.overrideWithValue(
          resolvedChildState.childProfile,
        ),
        aiBuddyCurrentChildIdProvider.overrideWithValue(
          resolvedChildState.childId,
        ),
      ]);
    }

    if (planInfoState != null) {
      baseOverrides.add(
        planInfoStateProvider.overrideWithValue(planInfoState),
      );
    }

    baseOverrides.addAll(overrides);

    return TestHarness._(
      secureStorage: resolvedStorage,
      sharedPreferences: sharedPreferences,
      logger: resolvedLogger,
      networkService: resolvedNetwork,
      navigationController: resolvedNavigationController,
      baseOverrides: baseOverrides,
    );
  }

  List<Override> overrides(
      [List<Override> extraOverrides = const <Override>[]]) {
    return <Override>[
      ..._baseOverrides,
      ...extraOverrides,
    ];
  }

  ProviderContainer createContainer({
    List<Override> overrides = const <Override>[],
  }) {
    return ProviderContainer(overrides: this.overrides(overrides));
  }

  Widget wrapApp({
    required Widget home,
    List<Override> overrides = const <Override>[],
    Locale locale = const Locale('en'),
    ThemeData? theme,
  }) {
    return ProviderScope(
      overrides: this.overrides(overrides),
      child: MaterialApp(
        locale: locale,
        theme:
            theme ?? AppTheme.lightTheme(palette: ThemePalettes.defaultPalette),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        home: home,
      ),
    );
  }

  Widget wrapRouterApp({
    required GoRouter router,
    List<Override> overrides = const <Override>[],
    Locale locale = const Locale('en'),
    ThemeData? theme,
  }) {
    return ProviderScope(
      overrides: this.overrides(overrides),
      child: MaterialApp.router(
        locale: locale,
        theme:
            theme ?? AppTheme.lightTheme(palette: ThemePalettes.defaultPalette),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        routerConfig: router,
      ),
    );
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    required Widget home,
    List<Override> overrides = const <Override>[],
    Locale locale = const Locale('en'),
    ThemeData? theme,
    Size? surfaceSize,
    bool settle = true,
    Duration settleDuration = const Duration(milliseconds: 100),
  }) async {
    if (surfaceSize != null) {
      tester.view.physicalSize = surfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    await tester.pumpWidget(
      wrapApp(
        home: home,
        overrides: overrides,
        locale: locale,
        theme: theme,
      ),
    );
    await tester.pump();
    if (settle) {
      await tester.pump(settleDuration);
    }
  }

  Future<void> pumpRouterApp(
    WidgetTester tester, {
    required GoRouter router,
    List<Override> overrides = const <Override>[],
    Locale locale = const Locale('en'),
    ThemeData? theme,
    Size? surfaceSize,
    bool settle = true,
    Duration settleDuration = const Duration(milliseconds: 100),
  }) async {
    if (surfaceSize != null) {
      tester.view.physicalSize = surfaceSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    await tester.pumpWidget(
      wrapRouterApp(
        router: router,
        overrides: overrides,
        locale: locale,
        theme: theme,
      ),
    );
    await tester.pump();
    if (settle) {
      await tester.pump(settleDuration);
    }
  }
}
