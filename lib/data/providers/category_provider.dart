import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/cupertino.dart';
import '../helper/api_service.dart';
import '../models/category_model.dart';
import '../repository/category_repository.dart';
import 'api_state_provider.dart';

class CategoryProvider with ChangeNotifier {

  final CategoryRepository _repository = CategoryRepository();
  final ApiStateProvider<CategoryModel> categoryState = ApiStateProvider<CategoryModel>();


  Future<void> fetchCategoryData({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        categoryState.setLoading();
        await clearCache();
      }
      await _repository.getCategory(
        stateProvider: categoryState,
        cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      );
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> clearCache() async {
    await _repository.clearCatCache();
    notifyListeners();
  }

}
