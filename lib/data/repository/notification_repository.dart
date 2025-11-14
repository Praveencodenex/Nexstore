import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import '../helper/api_service.dart';
import '../models/notification_model.dart';
import '../providers/api_state_provider.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();

  Future<void> getNotification({
    required ApiStateProvider<NotificationResponse> stateProvider,
    bool forceRefresh = false,
  }) async {

    await _apiService.get<NotificationResponse>(
      endpoint: 'notifications',
      stateProvider: stateProvider,
      fromJson: (json) => NotificationResponse.fromJson(json),

      extra: {
        'cacheKey': 'notification_data',
      },
      cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      enableAutoRetry: true,

    );
  }

  Future<bool> clearHomeCache() async {
    try {
      await _apiService.clearCache('notification_data');
      return true;
    } catch (e) {
      return false;
    }
  }
}