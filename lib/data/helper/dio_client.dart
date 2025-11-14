import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thenexstore/routes/routes_names.dart';


import '../../routes/navigator_services.dart';
import '../../utils/app_config.dart';
import '../services/auth_service.dart';
import 'dio_interceptors.dart';

class DioClient {

  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  late final AuthTokenService _authTokenManager;
  late final Dio dio;
  late final CacheStore cacheStore;
  late final CacheOptions defaultCacheOptions;

  static const Duration _connectionTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);

  DioClient._internal();

  Future<void> init(AuthTokenService authTokenManager) async {
    _authTokenManager = authTokenManager;

    try {
      final dir = await getTemporaryDirectory();
      cacheStore = HiveCacheStore(
        dir.path,
        hiveBoxName: 'api_cache',
      );

      defaultCacheOptions = CacheOptions(
        store: cacheStore,
        policy: CachePolicy.refreshForceCache,
        hitCacheOnErrorExcept: [401, 403],
        maxStale: const Duration(days: 1),
        priority: CachePriority.high,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false,
      );

      dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: _connectionTimeout,
          receiveTimeout: _receiveTimeout,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {
            Headers.acceptHeader: Headers.jsonContentType,
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );


      dio.interceptors.addAll([
        DioCacheInterceptor(options: defaultCacheOptions),
        ConnectivityInterceptor(),
        RetryInterceptor(
          dio: dio,
          maxRetries: 2,
          retryStatusCodes: const [408, 500, 502, 503, 504,429],
          retryDelay: const Duration(seconds: 2),
        ),
        AuthInterceptor(
          dio: dio,
          tokenProvider: _getAuthToken,
          refreshToken: _refreshToken,
          onUnauthorized: _handleUnauthorized,
        ),
        ErrorInterceptor(),
        if (!kReleaseMode)
          LoggingInterceptor(
            logRequestHeaders: true,
            logResponseHeaders: true,
            logRequestBody: true,
            logResponseBody: true,
            logError: true,
          ),
      ]);

    } catch (e) {
      debugPrint('DioClient initialization error: $e');
      rethrow;
    }
  }
    CacheOptions getCacheOptions({
    CachePolicy? policy,
    Duration? maxStale,
  }) {
    return CacheOptions(
      store: cacheStore,
      policy: policy ?? defaultCacheOptions.policy,
      hitCacheOnErrorExcept: defaultCacheOptions.hitCacheOnErrorExcept,
      maxStale: maxStale ?? defaultCacheOptions.maxStale,
      priority: defaultCacheOptions.priority,
      keyBuilder: defaultCacheOptions.keyBuilder,
      allowPostMethod: defaultCacheOptions.allowPostMethod,
    );
  }

  Future<void> clearCache(String cacheKey) async {
    await cacheStore.delete(cacheKey);
  }

  Future<void> clearAllCache() async {
    await cacheStore.clean();
  }

  Future<String?> _getAuthToken() async {
    return await _authTokenManager.getAuthToken();
  }

  void _handleUnauthorized() {
    debugPrint('DioClient: _handleUnauthorized called');
    try {

      _authTokenManager.clearToken().then((_) {
        debugPrint('DioClient: Token cleared, navigating to login');
        NavigationService.instance.pushNamedAndClearStack(RouteNames.login);
      }).catchError((e) {
        debugPrint('DioClient: Error clearing token: $e');
        NavigationService.instance.pushNamedAndClearStack(RouteNames.login);
      });
    } catch (e) {
      debugPrint('DioClient: Unexpected error in _handleUnauthorized: $e');
      NavigationService.instance.pushNamedAndClearStack(RouteNames.login);
    }
  }

  Future<String?> _refreshToken() async {
    return null;
  }

  // Request cancellation handling
  static CancelToken cancelToken = CancelToken();

  void cancelRequests() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('Cancelled by user');
    }
    cancelToken = CancelToken();
  }

  Future<void> logout() async {
    await _authTokenManager.clearToken();
    await clearAllCache();
    cancelRequests();
    dio.options.headers.remove('Authorization');
    await NavigationService.instance.pushNamedAndClearStack(RouteNames.login);
  }
}