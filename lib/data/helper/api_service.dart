import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import '../providers/api_state_provider.dart';
import 'api_result.dart';
import 'dio_client.dart';
import 'network_exception.dart';


class ApiService {
  final Dio _dio = DioClient.instance.dio;


  Future<ApiResult<T>> _executeRequest<T>({
    required Future<Response> Function() requestFunction,
    required ApiStateProvider<T> stateProvider,
    T Function(Map<String, dynamic>)? fromJson,
    CachePolicy? cachePolicy,
    Duration? maxStale,
    bool enableAutoRetry = true,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final response = await requestFunction();

      if (response.extra['updateCacheOnly'] != true) {
        stateProvider.setLoading();
      }

      if (response.data == null) {
        const error = NetworkException(message: 'Invalid response data: null');
        stateProvider.setError(error);
        return ApiResult.failure(error);
      }

      try {
        if (fromJson != null) {
          Map<String, dynamic> responseMap;

          if (response.data is Map) {
            responseMap = Map<String, dynamic>.from(response.data);
          } else if (response.data is List) {
            responseMap = {
              'data': response.data,
              'status': true,
              'message': 'Success'
            };
          } else if (response.data is String) {
            try {
              responseMap = jsonDecode(response.data);
            } catch (e) {
              responseMap = {
                'data': response.data,
                'status': true,
                'message': 'Success'
              };
            }
          } else {
            responseMap = {
              'data': response.data,
              'status': true,
              'message': 'Success'
            };
          }

          final status = responseMap['status'];
          if (status == false) {
            final error = NetworkException(
              message: responseMap['message'] ?? 'Operation failed',
              statusCode: response.statusCode,
              data: responseMap,
            );
            stateProvider.setError(error);
            return ApiResult.failure(error);
          }

          final parsedData = fromJson(responseMap);


            stateProvider.setData(parsedData);


          return ApiResult.success(parsedData);
        } else {
          final data = response.data as T;

            stateProvider.setData(data);

          return ApiResult.success(data);
        }
      } catch (e) {
        debugPrint('Parsing error: $e');
        final error = NetworkException(
            message: 'Failed to parse response: ${e.toString()}',
            data: response.data
        );
        stateProvider.setError(error);
        return ApiResult.failure(error);
      }
    } on DioException catch (e) {
      debugPrint('Dio error: $e');
      final error = NetworkException(
          message: e.response?.data?['message'] ?? e.message ?? 'Network error occurred',
          statusCode: e.response?.statusCode,
          data: e.response?.data
      );
      stateProvider.setError(error);
      return ApiResult.failure(error);
    } catch (e) {
      debugPrint('General error: $e');
      final error = NetworkException(
        message: e.toString(),
      );
      stateProvider.setError(error);
      return ApiResult.failure(error);
    }
  }


  // GET request
  Future<ApiResult<T>> get<T>({
    required String endpoint,
    required ApiStateProvider<T> stateProvider,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    CachePolicy? cachePolicy,
    Duration? maxStale,
    bool enableAutoRetry = true,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
  }) async {
    final cacheOptions = cachePolicy != null
        ? DioClient.instance.getCacheOptions(
      policy: cachePolicy,
      maxStale: maxStale ?? const Duration(days: 1),
    )
        : null;

    final requestExtra = {
      if (cacheOptions != null) 'cache': cacheOptions,
      'disableRetry': !enableAutoRetry,
      ...?extra,
    };

    final options = Options(
      headers: headers,
      extra: requestExtra,
    );

    return _executeRequest(
      requestFunction: () => _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      ),
      stateProvider: stateProvider,
      fromJson: fromJson,
      cachePolicy: cachePolicy,
      maxStale: maxStale,
      enableAutoRetry: enableAutoRetry,
      extra: extra,
    );
  }

// POST request
  Future<ApiResult<T>> post<T>({
    required String endpoint,
    required ApiStateProvider<T> stateProvider,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    CachePolicy? cachePolicy,
    Duration? maxStale,
    bool enableAutoRetry = true,
    Map<String, dynamic>? headers,
  }) async {
    final options = Options(
      headers: headers,
      extra: {
        'disableRetry': !enableAutoRetry,
      },
    );

    return _executeRequest(
      requestFunction: () => _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      stateProvider: stateProvider,
      fromJson: fromJson,
      cachePolicy: cachePolicy,
      maxStale: maxStale,
      enableAutoRetry: enableAutoRetry,
    );
  }

// PUT request
  Future<ApiResult<T>> put<T>({
    required String endpoint,
    required ApiStateProvider<T> stateProvider,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    bool enableAutoRetry = true,
    Map<String, dynamic>? headers,
  }) async {
    final options = Options(
      headers: headers,
      extra: {
        'disableRetry': !enableAutoRetry,
      },
    );

    return _executeRequest(
      requestFunction: () => _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      stateProvider: stateProvider,
      fromJson: fromJson,
      enableAutoRetry: enableAutoRetry,
    );
  }

// PATCH request
  Future<ApiResult<T>> patch<T>({
    required String endpoint,
    required ApiStateProvider<T> stateProvider,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    bool enableAutoRetry = true,
    Map<String, dynamic>? headers,
  }) async {
    final options = Options(
      headers: headers,
      extra: {
        'disableRetry': !enableAutoRetry,
      },
    );

    return _executeRequest(
      requestFunction: () => _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      stateProvider: stateProvider,
      fromJson: fromJson,
      enableAutoRetry: enableAutoRetry,
    );
  }

// DELETE request
  Future<ApiResult<T>> delete<T>({
    required String endpoint,
    required ApiStateProvider<T> stateProvider,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    bool enableAutoRetry = true,
    Map<String, dynamic>? headers,
  }) async {
    final options = Options(
      headers: headers,
      extra: {
        'disableRetry': !enableAutoRetry,
      },
    );

    return _executeRequest(
      requestFunction: () => _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      ),
      stateProvider: stateProvider,
      fromJson: fromJson,
      enableAutoRetry: enableAutoRetry,
    );
  }

// Multipart request for file uploads
  Future<ApiResult<T>> multipart<T>({
    required String endpoint,
    required ApiStateProvider<T> stateProvider,
    required List<MapEntry<String, File>> files,
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
    void Function(int sent, int total)? onSendProgress,
    bool enableAutoRetry = false,
    Map<String, dynamic>? headers,
  }) async {
    return _executeRequest(
      requestFunction: () async {
        final formData = FormData.fromMap(data ?? {});

        // Add all files to form data
        for (var file in files) {
          formData.files.add(
            MapEntry(
              file.key,
              await MultipartFile.fromFile(
                file.value.path,
                filename: file.value.path.split('/').last,
              ),
            ),
          );
        }

        return _dio.post(
          endpoint,
          data: formData,
          options: Options(
            headers: headers,
            extra: {
              'disableRetry': !enableAutoRetry,
            },
          ),
          onSendProgress: onSendProgress,
        );
      },
      stateProvider: stateProvider,
      fromJson: fromJson,
      enableAutoRetry: enableAutoRetry,
    );
  }

// Download file
  Future<ApiResult<String>> download({
    required String url,
    required String savePath,
    required ApiStateProvider<String> stateProvider,
    Map<String, dynamic>? queryParameters,
    void Function(int received, int total)? onReceiveProgress,
    bool enableAutoRetry = true,
    Map<String, dynamic>? headers,
  }) async {
    return _executeRequest(
      requestFunction: () async {
        // Create options with cache disabled for file downloads
        final options = Options(
          responseType: ResponseType.bytes, // Use bytes instead of stream
          headers: headers,
          extra: {
            'disableRetry': !enableAutoRetry,
            'disableCache': true, // Disable cache for downloads
          },
        );

        final response = await _dio.get(
          url,
          queryParameters: queryParameters,
          options: options,
          onReceiveProgress: onReceiveProgress,
        );

        // Save the downloaded bytes to file
        final file = File(savePath);
        await file.writeAsBytes(response.data);

        return Response(
          requestOptions: RequestOptions(path: url),
          data: savePath,
          statusCode: 200,
        );
      },
      stateProvider: stateProvider,
      enableAutoRetry: enableAutoRetry,
    );
  }



  // Cache management methods
  Future<void> clearCache(String cacheKey) async {
    await DioClient.instance.clearCache(cacheKey);
  }
  Future<void> clearAllCache() async {
    await DioClient.instance.clearAllCache();
  }

  // Cancel ongoing requests for a specific endpoint
  void cancelRequest(String endpoint) {
    _dio.close(force: true);
  }

  // Cancel all ongoing requests
  void cancelAllRequests() {
    _dio.close(force: true);
  }


}