import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:thenexstore/data/models/invoice_model.dart';

import '../helper/api_service.dart';
import '../helper/dio_client.dart';
import '../models/common_response.dart';
import '../models/order_create_model.dart';
import '../models/order_details_model.dart';
import '../models/order_model.dart';
import '../models/order_track_model.dart';
import '../models/reorder_model.dart';
import '../providers/api_state_provider.dart';

class OrderListRepository {
  final ApiService _apiService = ApiService();

  Future<void> getOrderList({
    required ApiStateProvider<OrdersResponse> stateProvider,
    bool forceRefresh = false,
    int page = 1,
  }) async {
    await _apiService.get<OrdersResponse>(
      endpoint: 'orders',
      queryParameters: {
        'page': page,
      },
      stateProvider: stateProvider,
      fromJson: (json) => OrdersResponse.fromJson(json),
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      extra: {
        'cacheKey': 'order_data',
        'backgroundRefresh': true,
      },
      enableAutoRetry: true,
    );
  }

Future<void> getOrderTrack({
    required ApiStateProvider<OrderStatusResponse> stateProvider,
    bool forceRefresh = false,
    required int orderId ,
  }) async {
    await _apiService.get<OrderStatusResponse>(
      endpoint: 'orders/track',
      stateProvider: stateProvider,
      queryParameters: {"order_id":orderId},
      fromJson: (json) => OrderStatusResponse.fromJson(json),
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      extra: {
        'cacheKey': 'order_data',
        'backgroundRefresh': true,
      },
      enableAutoRetry: true,
    );
  }

  Future<void> downloadInvoice({
    required String url,
    required String savePath,
    required ApiStateProvider<String> stateProvider,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    await _apiService.download(
      url: url,
      savePath: savePath,
      stateProvider: stateProvider,
      onReceiveProgress: onReceiveProgress,
      enableAutoRetry: true,
    );
  }


Future<void> getInvoice({
    required ApiStateProvider<InvoiceResponse> stateProvider,
    bool forceRefresh = false,
    required int orderId ,
  }) async {
    await _apiService.get<InvoiceResponse>(
      endpoint: 'orders/$orderId/invoice',
      stateProvider: stateProvider,
      fromJson: (json) => InvoiceResponse.fromJson(json),
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      enableAutoRetry: true,
    );
  }

  Future<void> cancelOrder({
    required ApiStateProvider<CommonResponse> stateProvider,
    required int orderId ,
     String reason='' ,

  }) async {
    await _apiService.post<CommonResponse>(
      endpoint: 'orders/cancel',
      stateProvider: stateProvider,
      data: {'order_id':orderId,'reason':reason},
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: true,
    );
  }

  Future<void> exchangeOrder({
    required ApiStateProvider<CommonResponse> stateProvider,
    required int orderId ,
    required int productId ,
    String reason = '',

  }) async {
    await _apiService.post<CommonResponse>(
      endpoint: 'orders/exchange',
      stateProvider: stateProvider,
      data: {'order_id':orderId,'reason':reason,'item_id':productId},
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: true,
    );
  }

  Future<void> fetchOrderDetails({
    required ApiStateProvider<OrderDetailsResponse> stateProvider,
    required int orderId,
    bool forceRefresh = false,
  }) async {

    await _apiService.get<OrderDetailsResponse>(
      endpoint: 'orders/details',
      stateProvider: stateProvider,
      queryParameters: {"order_id":orderId},
      fromJson: (json) => OrderDetailsResponse.fromJson(json),
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      extra: {
        'cacheKey': 'order_details_data',
        'backgroundRefresh': true,
      },
      enableAutoRetry: true,
    );
  }

  Future<void> submitReorder({
    required ApiStateProvider<CommonResponse> stateProvider,
    required dynamic orderIds,
    bool forceRefresh = false,
  }) async {
    await _apiService.post<CommonResponse>(
      endpoint: 'orders/reorder',
      stateProvider: stateProvider,
      data: {
        "items": orderIds
      },
      fromJson: (json) => CommonResponse.fromJson(json),
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,

      enableAutoRetry: true,
    );
  }


  Future<void> getReorderList({
    required ApiStateProvider<ReorderResponse> stateProvider,
    bool forceRefresh = false,
    int page = 1,
  }) async {
    await _apiService.get<ReorderResponse>(
      endpoint: 'orders/reorder-items',
      stateProvider: stateProvider,
      fromJson: (json) => ReorderResponse.fromJson(json),
      queryParameters: {
        'page': page,
      },
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      extra: {
        'cacheKey': 'reorder_data',
        'backgroundRefresh': true,
      },
      enableAutoRetry: true,
    );
  }
  Future<void> confirmPayment({
    required ApiStateProvider<CommonResponse> stateProvider,
    required int orderId ,
    required String status ,
    required String paymentId ,
  }) async {
    await _apiService.post<CommonResponse>(
      endpoint: 'orders/$orderId/confirm-payment',
      data: {'payment_status':status,'transaction_id':paymentId},
      stateProvider: stateProvider,
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }

  Future<void> createOrder({
    required ApiStateProvider<OrderCreateResponse> stateProvider,
    String? coupon,
    required String paymentType,
    required String paymentStatus,
    required int cartId,
    required int addressId,
  }) async {

    final Map<String, String> data = {
      'cart_id': cartId.toString(),
      'delivery_address_id': addressId.toString(),
      'payment_method':paymentType,
      'payment_status':paymentStatus,
    };

    if (coupon != null) {
      data['coupon_code'] = coupon;
    }

    await _apiService.post<OrderCreateResponse>(
      endpoint: 'orders',
      data: data,
      stateProvider: stateProvider,
      fromJson: (json) => OrderCreateResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }

  Future<void> orderReview({
    required int orderId,
    required int rating,
    required String comment,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.post<CommonResponse>(
      endpoint: 'reviews',
      stateProvider: stateProvider,
      data: {
        'order_id': orderId,
        'rating': rating,
        'comment': comment,
      },
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }

  Future<void> clearOrderCache() async {
    try {
      await DioClient.instance.clearCache('order_data');
      await DioClient.instance.clearCache('reorder_data');
      await DioClient.instance.clearCache('order_details_data');
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }
}