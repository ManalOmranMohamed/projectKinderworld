import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kinder_world/core/storage/secure_storage.dart';

import 'package:kinder_world/app.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Open required Hive boxes as untyped for JSON storage
  // Note: Freezed models don't work directly with Hive TypeAdapters,
  // so we store as JSON maps and serialize/deserialize in repositories
  await Hive.openBox('child_profiles');
  await Hive.openBox('activities');
  await Hive.openBox('progress_records');
  
  // Initialize secure storage
  final secureStorage = SecureStorage();
  
  // Initialize logger
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );
  
  // Set error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e('Flutter Error: ${details.exception}');
  };
  
  runApp(
    ProviderScope(
      overrides: [
        secureStorageProvider.overrideWithValue(secureStorage),
        loggerProvider.overrideWithValue(logger),
      ],
      child: const KinderWorldApp(),
    ),
  );
}