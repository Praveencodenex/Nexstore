

import 'package:flutter/cupertino.dart';
import 'package:thenexstore/data/repository/notification_repository.dart';

import '../models/notification_model.dart';
import 'api_state_provider.dart';

class NotificationProvider extends ChangeNotifier{

  final NotificationRepository _repository = NotificationRepository();
  final ApiStateProvider<NotificationResponse> notificationState = ApiStateProvider<NotificationResponse>();
  Future<void> fetchHomeData({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await clearCache();
        notificationState.setLoading();
        notifyListeners();
      }

      await _repository.getNotification(
        stateProvider: notificationState,
      );
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  Future<void> clearCache() async {
    await _repository.clearHomeCache();
    notifyListeners();
  }
}