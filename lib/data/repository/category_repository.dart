import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:thenexstore/data/helper/api_service.dart';

import '../models/category_model.dart';
import '../providers/api_state_provider.dart';

class CategoryRepository {
  final ApiService _apiService = ApiService();

  Future<void> getCategory({
    required ApiStateProvider<CategoryModel> stateProvider,
    CachePolicy cachePolicy = CachePolicy.forceCache,
  }) async {

    await _apiService.get<CategoryModel>(
      endpoint: 'products/categories',
      stateProvider: stateProvider,
      fromJson: (json) {
        return CategoryModel.fromJson(json);
      },
      cachePolicy: cachePolicy,
      extra: {'cacheKey': 'cat_data'},
      enableAutoRetry: true,
    );
  }

  Future<bool> clearCatCache() async {
    try {
      await _apiService.clearCache('cat_data');
      return true;
    } catch (e) {
      return false;
    }
  }
}