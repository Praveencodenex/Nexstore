import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class CustomCacheInterceptor extends Interceptor {
  final CacheOptions options;

  CustomCacheInterceptor({required this.options});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.method != 'GET') {
      return handler.next(options);
    }

    try {
      if (this.options.store != null) {
        final cacheKey = this.options.keyBuilder(options);
        final cacheData = await this.options.store!.get(cacheKey);

        if (cacheData != null && cacheData.content != null) {
          // Return cached response
          final response = Response(
            requestOptions: options,
            data: cacheData.content,
            statusCode: 200,
          );

          if (this.options.policy == CachePolicy.refreshForceCache) {
            handler.next(options);
          } else {
            handler.resolve(response);
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Cache error: $e');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.requestOptions.method == 'GET' &&
        response.statusCode == 200 &&
        response.data != null &&
        options.store != null) {
      try {
        final cacheKey = options.keyBuilder(response.requestOptions);
        final now = DateTime.now().toUtc();

        // Convert header values to List<int>
        final headerBytes = utf8.encode(json.encode(response.headers.map));

        final cacheResponse = CacheResponse(
          key: cacheKey,
          url: response.requestOptions.uri.toString(),
          headers: headerBytes,  // Now using List<int> for headers
          content: response.data,
          date: now,
          maxStale: now.add(options.maxStale ?? const Duration(days: 7)),
          expires: now.add(const Duration(days: 7)),
          priority: options.priority,
          requestDate: now,
          responseDate: now,
          cacheControl: CacheControl(maxAge: const Duration(days: 7).inSeconds),
          eTag: response.headers.value('etag') ?? '',
          lastModified: response.headers.value('last-modified') ?? now.toIso8601String(),
        );

        await options.store!.set(cacheResponse);
      } catch (e) {
        debugPrint('Cache storage error: $e');
      }
    }

    handler.next(response);
  }
}

// Retry Interceptor
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final List<int> retryStatusCodes;
  final Duration retryDelay;
  final bool Function(DioException)? shouldRetryCallback;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryStatusCodes = const [408, 500, 502, 503, 504,429],
    this.retryDelay = const Duration(seconds: 1),
    this.shouldRetryCallback,
  });

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.extra['disableRetry'] == true) {
      return handler.next(err);
    }

    final extra = err.requestOptions.extra;
    final int currentRetry = extra['currentRetry'] ?? 0;

    if (_shouldRetry(err, currentRetry)) {
      final delay = retryDelay * (currentRetry + 1);
      await Future.delayed(delay);

      try {
        final newOptions = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          extra: {
            ...err.requestOptions.extra,
            'currentRetry': currentRetry + 1,
          },
        );

        final response = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: newOptions,
        );

        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err, int currentRetry) {
    if (currentRetry >= maxRetries) return false;

    if (shouldRetryCallback != null) {
      return shouldRetryCallback!(err);
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }

    if (err.response != null &&
        retryStatusCodes.contains(err.response?.statusCode)) {
      return true;
    }

    return false;
  }
}

// Auth Interceptor
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Future<String?> Function() tokenProvider;
  final Future<String?> Function()? refreshToken;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    required this.dio,
    required this.tokenProvider,
    this.refreshToken,
    this.onUnauthorized,
  });

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    if (!options.extra.containsKey('requiresAuth') ||
        options.extra['requiresAuth'] == true) {
      try {
        final token = await tokenProvider();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (e) {
        debugPrint('Error getting token: $e');
      }
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 401) {
      debugPrint('AuthInterceptor: 401 detected in onResponse');
      if (onUnauthorized != null) {
        onUnauthorized!();
        response.data = {'message': 'Unauthorized', 'status': false};
      }
    }
    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Print detailed debug info
    debugPrint('AuthInterceptor.onError: statusCode=${err.response?.statusCode}');

    if (err.response?.statusCode == 401) {
      debugPrint('AuthInterceptor: 401 Unauthorized detected');

      // Try token refresh if available
      if (refreshToken != null) {
        try {
          final newToken = await refreshToken!();
          if (newToken != null) {
            final newOptions = Options(
              method: err.requestOptions.method,
              headers: {
                ...err.requestOptions.headers,
                'Authorization': 'Bearer $newToken'
              },
            );

            final response = await dio.request(
              err.requestOptions.path,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
              options: newOptions,
            );

            return handler.resolve(response);
          }
        } catch (e) {
          debugPrint('AuthInterceptor: Token refresh error: $e');
        }
      }

      if (onUnauthorized != null) {
        debugPrint('AuthInterceptor: Calling onUnauthorized');

        // Call the unauthorized handler
        onUnauthorized!();
        return handler.resolve(Response(
          requestOptions: err.requestOptions,
          statusCode: 401,
          data: {'message': 'Unauthorized', 'status': false},
        ));
      }
    }

    // For non-401 errors or if onUnauthorized is null
    return handler.next(err);
  }
}
// ErrorInterceptor
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // First check for connection error to ensure no network is properly handled
    if (err.type == DioExceptionType.connectionError) {
      err = DioException(
        requestOptions: err.requestOptions,
        error: 'No internet connection',
        type: err.type,
        response: Response(
            statusCode: -1,
            requestOptions: err.requestOptions,
            data: {'message': 'No internet connection'}
        ),
      );
      return handler.next(err);
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        err = DioException(
          requestOptions: err.requestOptions,
          error: 'Connection timed out',
          type: err.type,
          response: Response(
              statusCode: 408,
              requestOptions: err.requestOptions,
              data: {'message': 'Connection timed out'}
          ),
        );
        break;
      case DioExceptionType.badResponse:
        final response = err.response;
        String errorMessage = 'Server error';
        if (response?.data != null && response?.data is Map) {
          errorMessage = response?.data['message'] ?? errorMessage;
        }
        err = DioException(
          requestOptions: err.requestOptions,
          error: errorMessage,
          type: err.type,
          response: response,
        );
        break;
      case DioExceptionType.cancel:
        err = DioException(
          requestOptions: err.requestOptions,
          error: 'Request cancelled',
          type: err.type,
        );
        break;
      default:
        err = DioException(
          requestOptions: err.requestOptions,
          error: 'Something went wrong',
          type: err.type,
        );
    }
    handler.next(err);
  }
}


// Connectivity Interceptor
class ConnectivityInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return handler.next(options);
      }

      // No internet connection - explicitly set status code to -1
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
          response: Response(
              statusCode: -1, // Explicitly set status code for no network
              requestOptions: options,
              data: {'message': 'No internet connection'}
          ),
        ),
      );
    } on SocketException catch (_) {
      // Handle SocketException with explicit status code
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'No internet connection',
          response: Response(
              statusCode: -1, // Explicitly set status code for no network
              requestOptions: options,
              data: {'message': 'No internet connection'}
          ),
        ),
      );
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: e.toString(),
        ),
      );
    }
  }
}
// Logging Interceptor
class LoggingInterceptor extends Interceptor {
  final bool logRequestHeaders;
  final bool logResponseHeaders;
  final bool logRequestBody;
  final bool logResponseBody;
  final bool logError;

  LoggingInterceptor({
    this.logRequestHeaders = true,
    this.logResponseHeaders = true,
    this.logRequestBody = true,
    this.logResponseBody = true,
    this.logError = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌──────────────────────────── Request ────────────────────────────');
      debugPrint('│ ${options.method} ${options.uri}');
      if (logRequestHeaders) {
        debugPrint('│ Headers:');
        options.headers.forEach((key, value) {
          debugPrint('│   $key: $value');
        });
      }
      if (logRequestBody && options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      debugPrint('└─────────────────────────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌──────────────────────────── Response ───────────────────────────');
      debugPrint('│ ${response.requestOptions.method} ${response.requestOptions.uri}');
      debugPrint('│ Status: ${response.statusCode}');
      if (logResponseHeaders) {
        debugPrint('│ Headers:');
        response.headers.forEach((name, values) {
          debugPrint('│   $name: ${values.join(', ')}');
        });
      }
      if (logResponseBody) {
        debugPrint('│ Body: ${response.data}');
      }
      debugPrint('└─────────────────────────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode && logError) {
      debugPrint('┌──────────────────────────── Error ─────────────────────────────');
      debugPrint('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
      debugPrint('│ Type: ${err.type}');
      debugPrint('│ Message: ${err.message}');
      if (err.response != null) {
        debugPrint('│ Status: ${err.response?.statusCode}');
        debugPrint('│ Data: ${err.response?.data}');
      }
      debugPrint('└─────────────────────────────────────────────────────────────────');
    }
    handler.next(err);
  }
}