import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:thenexstore/data/models/coupon_model.dart';

import '../helper/api_service.dart';
import '../helper/dio_client.dart';
import '../models/checkout_model.dart';
import '../providers/api_state_provider.dart';

class CheckoutRepository {
  final ApiService _apiService = ApiService();

  Future<void> getCouponList({
    required ApiStateProvider<CouponResponse> stateProvider,

  }) async {
    await _apiService.get<CouponResponse>(
      endpoint: 'coupons',
      stateProvider: stateProvider,
      fromJson: (json) => CouponResponse.fromJson(json),
      cachePolicy: CachePolicy.noCache,
      enableAutoRetry: true,
    );
  }


  Future<void> getCheckout({
    required ApiStateProvider<CheckoutResponse> stateProvider,
    bool forceRefresh = false,
    String distance = '5',
    int? couponId,
    required int cartId,
    required int addressId,
  }) async {
    final Map<String, String> params = {
      'cart_id': cartId.toString(),
      'address_id': addressId.toString(),
      'distance': distance,
    };

    if (couponId != null) {
      params['coupon_id'] = couponId.toString();
    }

    await _apiService.post<CheckoutResponse>(
      endpoint: 'cart/checkout',
      queryParameters: params,
      stateProvider: stateProvider,
      fromJson: (json) => CheckoutResponse.fromJson(json),
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      enableAutoRetry: true,
    );
  }



  Future<void> clearCheckoutCache() async {
    try {
      await DioClient.instance.clearCache('checkout_cache');
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }
}