import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:thenexstore/data/helper/api_service.dart';

import '../helper/dio_client.dart';
import '../models/cart_model.dart';
import '../models/common_response.dart';
import '../providers/api_state_provider.dart';

class CartRepository {
  final ApiService _apiService = ApiService();

  Future<void> getCartList({
    required ApiStateProvider<CartResponse> stateProvider,
    bool forceRefresh = false,
    int? couponId,
    int? addressId,
  }) async {
    if (forceRefresh) {
      clearCartCache();
    }
    // Create an empty map and add parameters only if they are not null
    Map<String, dynamic> queryParameters = {};
    if (couponId != null) {
      queryParameters['coupon_id'] = couponId;
    }
    if (addressId != null) {
      queryParameters['address_id'] = addressId;
    }
    await _apiService.get<CartResponse>(
      endpoint: 'cart',
      stateProvider: stateProvider,
      queryParameters: queryParameters,
      fromJson: (json) => CartResponse.fromJson(json),
      cachePolicy: CachePolicy.refreshForceCache,
      extra: {
        'backgroundRefresh': true,
        'cacheKey': 'cart_data',
      },
      enableAutoRetry: true,
    );
  }
  Future<void> removeFromCart({
    required int productId,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.delete<CommonResponse>(
      endpoint: 'cart/remove',
      stateProvider: stateProvider,
      queryParameters: {'product_id': productId},
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }

  Future<void> addToCart({
    required int productId,
    required int quantity,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.post<CommonResponse>(
      endpoint: 'cart/add',
      stateProvider: stateProvider,
      data: {
        'product_id': productId,
        'quantity':quantity
      },
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }
    Future<void> updateToCart({
      required int productId,
      required int quantity,
      required ApiStateProvider<CommonResponse> stateProvider,
    }) async {
      await _apiService.patch<CommonResponse>(
        endpoint: 'cart/update',
        stateProvider: stateProvider,
        data: {
          'product_id': productId,
          'quantity':quantity
        },
        fromJson: (json) => CommonResponse.fromJson(json),
        enableAutoRetry: false,
      );
    }

  Future<void> clearCartCache() async {
    try {
      await DioClient.instance.clearCache('cart_data');
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }
}