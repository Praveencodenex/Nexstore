import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import '../helper/api_service.dart';
import '../helper/dio_client.dart';
import '../models/filter_model.dart';
import '../models/hot_pick_model.dart';
import '../models/product_model.dart';
import '../models/related_product.dart';
import '../providers/api_state_provider.dart';

class ProductRepository {
  final ApiService _apiService = ApiService();

  String _buildProductCacheKey({
    required int id,
    required String language,
    required int page,
    String? typeId,
    String? brandId,
  }) {
    return 'products_${id}_${language}_${page}_${typeId ?? 'all'}_${brandId ?? 'all'}';
  }

  String _buildFilterCacheKey({
    required String filterType,
    String? search,
  }) {
    return 'filters_${filterType}_${search ?? "all"}';
  }

  Future<void> getHotPickList({
    required ApiStateProvider<HotPickResponse> stateProvider,
    int page = 1,
    CachePolicy cachePolicy = CachePolicy.request,
  }) async {
    final cacheKey = 'hot_pick_data_page_$page';
    await _apiService.get<HotPickResponse>(
      endpoint: 'products/hot',
      queryParameters: {
        'page': page,
      },
      stateProvider: stateProvider,
      fromJson: (json) => HotPickResponse.fromJson(json),
      cachePolicy: cachePolicy,
      extra: {
        'cacheKey': cacheKey,
        'forceRefresh': cachePolicy == CachePolicy.refresh
      },
      enableAutoRetry: true,
    );
  }

  Future<void> getProductsByCategory({
    required ApiStateProvider<ProductResponse> stateProvider,
    required int id,
    required String language,
    String? typeId,
    String? brandId,
    int page = 1,
    CachePolicy cachePolicy = CachePolicy.refreshForceCache,
  }) async {
    final cacheKey = _buildProductCacheKey(
      id: id,
      language: language,
      page: page,
      typeId: typeId,
      brandId: brandId,
    );

    await _apiService.get<ProductResponse>(
      endpoint: 'products',
      queryParameters: {
        'category_id': id,
        'page': page,
        'lang': language,
        if (typeId != null) 'type': typeId,
        if (brandId != null) 'brand': brandId,
      },
      stateProvider: stateProvider,
      fromJson: (json) => ProductResponse.fromJson(json),
      cachePolicy: cachePolicy,
      extra: {'cacheKey': cacheKey,
        'forceRefresh': cachePolicy == CachePolicy.refresh
      },
      enableAutoRetry: true,
    );
  }

  Future<void> getRelatedProducts({
    required ApiStateProvider<RelatedProductsResponse> stateProvider,
    bool forceRefresh = false,
    required int productId ,
    int page = 1,
  }) async {
    await _apiService.get<RelatedProductsResponse>(
      endpoint: 'products/$productId/related',
      stateProvider: stateProvider,
      queryParameters: {
        'current_page': page,
      },
      extra: {'cacheKey': "related_product"},
      fromJson: (json) => RelatedProductsResponse.fromJson(json),
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      enableAutoRetry: true,
    );
  }


  Future<void> getFilters({
    required ApiStateProvider<CombinedResponse> stateProvider,
    required String filterType,
    required int catId,
    String? search,
    CachePolicy cachePolicy = CachePolicy.refreshForceCache,
  }) async {
    final cacheKey = _buildFilterCacheKey(
      filterType: filterType,
      search: search,
    );

    await _apiService.get<CombinedResponse>(
      endpoint: 'products/filters',
      queryParameters: {
        'filter_type': filterType,
        'category_id': catId,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      stateProvider: stateProvider,
      fromJson: (json) => CombinedResponse.fromJson(json, filterType),
      cachePolicy: cachePolicy,
      extra: {'cacheKey': cacheKey},
      enableAutoRetry: true,
    );
  }

  Future<void> clearCategoryCache({
    required int categoryId,
    required String language,
    String? typeId,
    String? brandId,
  }) async {
    final firstPageCacheKey = _buildProductCacheKey(
      id: categoryId,
      language: language,
      page: 1,
      typeId: typeId,
      brandId: brandId,
    );
    await _apiService.clearCache(firstPageCacheKey);
  }

  Future<void> clearFilterCache({
    required String filterType,
    String? search,
  }) async {
    final cacheKey = _buildFilterCacheKey(
      filterType: filterType,
      search: search,
    );
    await _apiService.clearCache(cacheKey);
  }

  Future<void> clearHotPickCache() async {
    try {
      await DioClient.instance.clearCache('hot_pick_data');
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }
  Future<void> clearRelatedProductsCache() async {
    try {
      await DioClient.instance.clearCache('related_product');
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }
}