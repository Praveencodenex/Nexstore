import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../helper/api_service.dart';
import '../models/search_model.dart';
import '../providers/api_state_provider.dart';

class SearchRepository {
  final ApiService _apiService = ApiService();

  Future<void> searchProducts({
    required String query,
    required ApiStateProvider<SearchResponse> stateProvider,
    String language = 'en',
    int page = 1,
    CachePolicy cachePolicy = CachePolicy.refresh,
  }) async {
    await _apiService.get<SearchResponse>(
      endpoint: 'products/search',
      queryParameters: {
        'query': query,
        'page': page,
        'lang': language,
      },
      stateProvider: stateProvider,
      extra: {
        'cacheKey': 'home_data',
        'backgroundRefresh': true,
      },
      fromJson: (json) => SearchResponse.fromJson(json),
      cachePolicy: cachePolicy,
      enableAutoRetry: true,
    );
  }

  Future<bool> clearSearchCache() async {
    try {
      await _apiService.clearCache('search_data');
      return true;
    } catch (e) {
      return false;
    }
  }
}