import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:thenexstore/data/helper/api_service.dart';

import '../models/home_model.dart';
import '../providers/api_state_provider.dart';

class HomeRepository {
  final ApiService _apiService = ApiService();

  Future<void> getHome({
    required ApiStateProvider<HomeResponse> stateProvider,
    bool forceRefresh = false,
  }) async {

    await _apiService.get<HomeResponse>(
      endpoint: 'home',
      stateProvider: stateProvider,
      fromJson: (json) => HomeResponse.fromJson(json),

      extra: {
        'cacheKey': 'home_data',
      },
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      enableAutoRetry: true,

    );
  }

  Future<bool> clearHomeCache() async {
    try {
      await _apiService.clearCache('home_data');
      return true;
    } catch (e) {
      return false;
    }
  }
}