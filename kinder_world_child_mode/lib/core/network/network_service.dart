import 'dart:math';

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/storage/secure_storage.dart';
import 'package:logger/logger.dart';

class NetworkService {
  final Dio _dio;
  final Connectivity _connectivity;
  final SecureStorage _secureStorage;
  final Logger _logger;
  final Random _random = Random();

  NetworkService({
    Dio? dio,
    Connectivity? connectivity,
    required SecureStorage secureStorage,
    Logger? logger,
  })  : _dio = dio ?? Dio(),
        _connectivity = connectivity ?? Connectivity(),
        _secureStorage = secureStorage,
        _logger = logger ?? Logger() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      sendTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Request Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requestId = _resolveRequestId(options);
          options.headers['X-Request-ID'] = requestId;
          options.extra['requestId'] = requestId;
          options.extra['startedAtMs'] = DateTime.now().millisecondsSinceEpoch;

          final authorizationHeaderKey =
              _findHeaderKey(options.headers, 'Authorization');
          if (authorizationHeaderKey != null) {
            final explicitAuthorization =
                options.headers[authorizationHeaderKey];
            if (explicitAuthorization == null ||
                explicitAuthorization.toString().trim().isEmpty) {
              options.headers.remove(authorizationHeaderKey);
            }
          } else {
            final token = _secureStorage.hasCachedAuthToken
                ? _secureStorage.cachedAuthToken
                : await _secureStorage.getAuthToken();
            if (_shouldAttachAuthToken(token)) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          _logDebug(
            'http.request.start',
            fields: {
              'request_id': requestId,
              'method': options.method,
              'path': options.path,
              'retry': options.extra['retryCount'] ?? 0,
            },
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          final requestId =
              response.requestOptions.extra['requestId']?.toString() ??
                  response.headers.value('X-Request-ID') ??
                  'unknown';
          final duration = _requestDurationMs(response.requestOptions);
          _logForStatus(
            response.statusCode ?? 0,
            'http.request.end',
            fields: {
              'request_id': requestId,
              'method': response.requestOptions.method,
              'path': response.requestOptions.path,
              'status_code': response.statusCode,
              'duration_ms': duration,
              'retry': response.requestOptions.extra['retryCount'] ?? 0,
            },
          );
          handler.next(response);
        },
        onError: (error, handler) {
          final requestId =
              error.requestOptions.extra['requestId']?.toString() ?? 'unknown';
          _logError(
            'http.request.error',
            fields: {
              'request_id': requestId,
              'method': error.requestOptions.method,
              'path': error.requestOptions.path,
              'status_code': error.response?.statusCode,
              'error_type': error.type.name,
              'message': error.message ?? 'unknown_error',
              'retry': error.requestOptions.extra['retryCount'] ?? 0,
              'duration_ms': _requestDurationMs(error.requestOptions),
            },
          );
          handler.next(error);
        },
      ),
    );

    // Retry Interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logger: _logger,
      ),
    );
  }

  String? _findHeaderKey(Map<String, dynamic> headers, String target) {
    for (final key in headers.keys) {
      if (key.toLowerCase() == target.toLowerCase()) {
        return key;
      }
    }
    return null;
  }

  String _resolveRequestId(RequestOptions options) {
    final existingHeader = _findHeaderKey(options.headers, 'X-Request-ID');
    if (existingHeader != null) {
      final value = options.headers[existingHeader]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    final existingExtra = options.extra['requestId']?.toString().trim();
    if (existingExtra != null && existingExtra.isNotEmpty) {
      return existingExtra;
    }
    return '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 20)}';
  }

  int? _requestDurationMs(RequestOptions options) {
    final startedAt = options.extra['startedAtMs'];
    final startedAtMs = startedAt is int
        ? startedAt
        : int.tryParse(startedAt?.toString() ?? '');
    if (startedAtMs == null) return null;
    return DateTime.now().millisecondsSinceEpoch - startedAtMs;
  }

  void _logDebug(String event, {required Map<String, Object?> fields}) {
    _logger.d(_structured(event, fields));
  }

  void _logInfo(String event, {required Map<String, Object?> fields}) {
    _logger.i(_structured(event, fields));
  }

  void _logWarning(String event, {required Map<String, Object?> fields}) {
    _logger.w(_structured(event, fields));
  }

  void _logError(String event, {required Map<String, Object?> fields}) {
    _logger.e(_structured(event, fields));
  }

  void _logForStatus(
    int statusCode,
    String event, {
    required Map<String, Object?> fields,
  }) {
    if (statusCode >= 500) {
      _logError(event, fields: fields);
      return;
    }
    if (statusCode >= 400) {
      _logWarning(event, fields: fields);
      return;
    }
    _logInfo(event, fields: fields);
  }

  String _structured(String event, Map<String, Object?> fields) {
    final parts = <String>['event=$event'];
    for (final entry in fields.entries) {
      final value = entry.value;
      if (value == null) continue;
      final safeValue = value.toString().replaceAll('\n', ' ').trim();
      if (safeValue.isEmpty) continue;
      parts.add('${entry.key}=$safeValue');
    }
    return parts.join(' ');
  }

  bool _shouldAttachAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }
    // Child mode uses a local session marker, not a backend JWT.
    if (token.startsWith('child_session_')) {
      return false;
    }
    return true;
  }

  // Check internet connectivity
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      return false;
    }
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    _logError(
      'http.transport.error',
      fields: {
        'request_id':
            e.requestOptions.extra['requestId']?.toString() ?? 'unknown',
        'method': e.requestOptions.method,
        'path': e.requestOptions.path,
        'status_code': e.response?.statusCode,
        'error_type': e.type.name,
        'message': e.message ?? 'unknown_error',
      },
    );
  }

  // Cancel all requests
  void cancelAllRequests() {
    _dio.close();
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final Logger logger;
  final int maxRetries;

  RetryInterceptor({
    required this.dio,
    required this.logger,
    this.maxRetries = 3,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        final requestId =
            err.requestOptions.extra['requestId']?.toString() ?? 'unknown';
        logger.w(
          'event=http.retry.scheduled request_id=$requestId method=${err.requestOptions.method} '
          'path=${err.requestOptions.path} attempt=${retryCount + 1} max_retries=$maxRetries',
        );

        // Keep retries responsive so the app does not feel frozen on transient failures.
        await Future.delayed(
          Duration(milliseconds: 250 * (1 << retryCount)),
        );

        // Clone request with incremented retry count
        final options = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          extra: {
            ...err.requestOptions.extra,
            'retryCount': retryCount + 1,
          },
        );

        try {
          final response = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: options,
          );
          logger.i(
            'event=http.retry.success request_id=$requestId method=${err.requestOptions.method} '
            'path=${err.requestOptions.path} attempt=${retryCount + 1}',
          );
          handler.resolve(response);
          return;
        } catch (e) {
          logger.e(
            'event=http.retry.failed request_id=$requestId method=${err.requestOptions.method} '
            'path=${err.requestOptions.path} attempt=${retryCount + 1} error=$e',
          );
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
