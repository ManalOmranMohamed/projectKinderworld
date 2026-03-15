import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kinder_world/core/network/network_service.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeferredOperation {
  const DeferredOperation({
    required this.id,
    required this.method,
    required this.path,
    required this.createdAt,
    this.data,
    this.queryParameters,
    this.attempts = 0,
    this.lastError,
  });

  final String id;
  final String method;
  final String path;
  final DateTime createdAt;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? queryParameters;
  final int attempts;
  final String? lastError;

  DeferredOperation copyWith({
    int? attempts,
    String? lastError,
  }) {
    return DeferredOperation(
      id: id,
      method: method,
      path: path,
      createdAt: createdAt,
      data: data,
      queryParameters: queryParameters,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'path': path,
        'created_at': createdAt.toIso8601String(),
        'data': data,
        'query_parameters': queryParameters,
        'attempts': attempts,
        'last_error': lastError,
      };

  static DeferredOperation fromJson(Map<String, dynamic> json) {
    return DeferredOperation(
      id: json['id']?.toString() ?? '',
      method: json['method']?.toString() ?? 'POST',
      path: json['path']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      queryParameters: json['query_parameters'] is Map
          ? Map<String, dynamic>.from(json['query_parameters'] as Map)
          : null,
      attempts: json['attempts'] is int
          ? json['attempts'] as int
          : int.tryParse(json['attempts']?.toString() ?? '') ?? 0,
      lastError: json['last_error']?.toString(),
    );
  }
}

class DeferredOperationsQueue {
  DeferredOperationsQueue({
    required SharedPreferences preferences,
    required Logger logger,
  })  : _preferences = preferences,
        _logger = logger;

  final SharedPreferences _preferences;
  final Logger _logger;

  static const _storageKey = 'offline.deferred_operations.queue';

  Future<void> enqueueHttpOperation({
    required String method,
    required String path,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final queue = await getPendingOperations();
    queue.add(
      DeferredOperation(
        id: '${DateTime.now().microsecondsSinceEpoch}_${method}_$path',
        method: method.toUpperCase(),
        path: path,
        data: data,
        queryParameters: queryParameters,
        createdAt: DateTime.now(),
      ),
    );
    await _saveQueue(queue);
    _logger.i(
      'event=offline.queue.enqueued method=${method.toUpperCase()} path=$path pending=${queue.length}',
    );
  }

  Future<List<DeferredOperation>> getPendingOperations() async {
    final raw = _preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return <DeferredOperation>[];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((item) =>
              DeferredOperation.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: true);
    } catch (e) {
      _logger.w('Failed to parse deferred operations queue: $e');
      return <DeferredOperation>[];
    }
  }

  Future<int> pendingCount() async {
    final queue = await getPendingOperations();
    return queue.length;
  }

  Future<int> processPending(NetworkService networkService) async {
    final queue = await getPendingOperations();
    if (queue.isEmpty) return 0;
    final online = await networkService.isConnected();
    if (!online) return 0;
    _logger.i('event=offline.queue.sync.start pending=${queue.length}');

    var processed = 0;
    final remaining = <DeferredOperation>[];

    for (final operation in queue) {
      try {
        final ok = await _performOperation(networkService, operation);
        if (ok) {
          processed += 1;
          continue;
        }
        remaining.add(operation);
      } on DioException catch (e) {
        if (_isOfflineError(e)) {
          remaining.add(operation.copyWith(
            attempts: operation.attempts + 1,
            lastError: e.message,
          ));
          // Stop processing because connectivity became unstable again.
          remaining.addAll(queue.skip(queue.indexOf(operation) + 1));
          break;
        }
        remaining.add(operation.copyWith(
          attempts: operation.attempts + 1,
          lastError: e.message,
        ));
      } catch (e) {
        remaining.add(operation.copyWith(
          attempts: operation.attempts + 1,
          lastError: e.toString(),
        ));
      }
    }

    await _saveQueue(remaining);
    _logger.i(
      'event=offline.queue.sync.end processed=$processed remaining=${remaining.length}',
    );
    return processed;
  }

  Future<void> _saveQueue(List<DeferredOperation> queue) async {
    final payload =
        jsonEncode(queue.map((e) => e.toJson()).toList(growable: false));
    await _preferences.setString(_storageKey, payload);
  }

  Future<bool> _performOperation(
    NetworkService networkService,
    DeferredOperation operation,
  ) async {
    switch (operation.method) {
      case 'POST':
        await networkService.post<dynamic>(
          operation.path,
          data: operation.data,
          queryParameters: operation.queryParameters,
        );
        return true;
      case 'PUT':
        await networkService.put<dynamic>(
          operation.path,
          data: operation.data,
          queryParameters: operation.queryParameters,
        );
        return true;
      case 'PATCH':
        await networkService.patch<dynamic>(
          operation.path,
          data: operation.data,
          queryParameters: operation.queryParameters,
        );
        return true;
      case 'DELETE':
        await networkService.delete<dynamic>(
          operation.path,
          data: operation.data,
          queryParameters: operation.queryParameters,
        );
        return true;
      default:
        _logger.w('Unsupported deferred operation method: ${operation.method}');
        return false;
    }
  }

  bool _isOfflineError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }
}
