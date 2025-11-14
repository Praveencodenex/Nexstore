import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:thenexstore/data/helper/api_service.dart';
import '../helper/dio_client.dart';
import '../models/common_response.dart';
import '../models/wishlist_model.dart';
import '../providers/api_state_provider.dart';

class WishListRepository {
  final ApiService _apiService = ApiService();

  Future<void> getWishlist({
    required ApiStateProvider<WishlistResponse> stateProvider,
    bool forceRefresh = false,
  }) async {
    await _apiService.get<WishlistResponse>(
      endpoint: 'wishlist',
      stateProvider: stateProvider,
      fromJson: (json) => WishlistResponse.fromJson(json),
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      extra: {
        'cacheKey': 'home_data',
        'backgroundRefresh': true,
      },
      enableAutoRetry: true,
    );
  }

  Future<void> removeFromWishlist({
    required int productId,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.delete<CommonResponse>(
      endpoint: 'wishlist/remove',
      stateProvider: stateProvider,
      queryParameters: {'product_id': productId},
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }

Future<void> addToWishlist({
    required int productId,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.post<CommonResponse>(
      endpoint: 'wishlist/add',
      stateProvider: stateProvider,
      data: {'product_id': productId},
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }

  Future<void> clearWishlistCache() async {
    try {
      await DioClient.instance.clearCache('wishlist_data');
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }
}