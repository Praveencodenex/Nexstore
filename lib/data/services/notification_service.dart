import 'package:firebase_notifications_handler/firebase_notifications_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/data/providers/profile_provider.dart';
import 'package:thenexstore/data/services/auth_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AuthTokenService _authManager;

  // Track if token has been uploaded to prevent duplicate uploads
  bool _isTokenUploaded = false;
  String? _lastUploadedToken;

  NotificationService({required AuthTokenService authManager})
      : _authManager = authManager;
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Successfully subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  void _onOpenNotificationArrive(NotificationInfo info) {
    debugPrint('Foreground notification received: ${info.payload}');
  }

  void _onNotificationTap(NotificationInfo info) {
    final payload = info.payload;
    final appState = info.appState;
    debugPrint('Notification tapped in $appState with payload: $payload');

    try {
      switch (payload['type']) {
        case 'home':
          _handleHomeNotification(payload);
          break;
        case 'order':
          _handleOrderNotification(payload);
          break;
        default:
          _handleDefaultNotification(payload);
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  void _onFcmTokenInit(String? token, BuildContext? context) {
    debugPrint('FCM Token initialized: $token');
    if (token != null && context != null) {
      if (_authManager.isLoggedIn) {
        if (!_isTokenUploaded || _lastUploadedToken != token) {
          _updateFcmToken(token, context);
          _isTokenUploaded = true;
          _lastUploadedToken = token;
        } else {
          debugPrint('FCM token already uploaded, skipping duplicate upload.');
        }
      } else {
        debugPrint('User not logged in. FCM token will not be uploaded.');
        // Store the token locally to upload later when user logs in
        _storeTokenForLater(token);
      }
    }
  }

  void _onFcmTokenUpdate(String token, BuildContext? context) {
    debugPrint('FCM Token updated: $token');
    if (context != null) {
      if (_authManager.isLoggedIn) {
        if (_lastUploadedToken != token) {
          _updateFcmToken(token, context);
          _lastUploadedToken = token;
          debugPrint('FCM token updated and uploaded successfully.');
        } else {
          debugPrint('FCM token is same as previously uploaded, skipping upload.');
        }
      } else {
        debugPrint('User not logged in. FCM token will not be uploaded.');
        _storeTokenForLater(token);
      }
    }
  }

  // Method to upload FCM token after user logs in
  Future<void> uploadStoredTokenAfterLogin(BuildContext context) async {
    final storedToken = await _getStoredToken();
    if (storedToken != null && _authManager.isLoggedIn) {
      if (_lastUploadedToken != storedToken) {
        _updateFcmToken(storedToken, context);
        _isTokenUploaded = true;
        _lastUploadedToken = storedToken;
        await _clearStoredToken();
        debugPrint('Stored FCM token uploaded after login.');
      } else {
        debugPrint('Stored token is same as last uploaded, skipping.');
        await _clearStoredToken(); // Clear the stored token anyway
      }
    }
  }

  void _updateFcmToken(String token, BuildContext context) {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

      profileProvider.updateFcm(fcmToken: token);
      debugPrint('FCM token update API called successfully for token: ${token.substring(0, 20)}...');
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
      _isTokenUploaded = false;
      _lastUploadedToken = null;
    }
  }


  Future<void> _storeTokenForLater(String token) async {
    try {
      await _authManager.storePendingFcmToken(token);
      debugPrint('FCM token stored for later upload');
    } catch (e) {
      debugPrint('Error storing FCM token: $e');
    }
  }

  Future<String?> _getStoredToken() async {
    try {
      return await _authManager.getPendingFcmToken();
    } catch (e) {
      debugPrint('Error getting stored FCM token: $e');
      return null;
    }
  }


  Future<void> _clearStoredToken() async {
    try {
      await _authManager.clearPendingFcmToken();
      debugPrint('Stored FCM token cleared');
    } catch (e) {
      debugPrint('Error clearing stored FCM token: $e');
    }
  }

  // Method to reset upload status when user logs out
  void resetUploadStatus() {
    _isTokenUploaded = false;
    _lastUploadedToken = null;
    debugPrint('FCM token upload status reset');
  }


  void _handleHomeNotification(Map<String, dynamic> payload) {
    NavigationService.instance.pushNamedAndClearStack(RouteNames.customBottomNavBar);
  }

  void _handleOrderNotification(Map<String, dynamic> payload) {
    NavigationService.instance.navigateTo(RouteNames.orderScreen,arguments: {'backNeeded': true});
  }

  void _handleDefaultNotification(Map<String, dynamic> payload) {
    NavigationService.instance.pushNamedAndClearStack(RouteNames.customBottomNavBar);
  }

  AndroidNotificationsConfig _getAndroidConfig() {
    return AndroidNotificationsConfig(
      channelIdGetter: (message) => 'thenexstore_app_channel',
      channelNameGetter: (message) => 'thenexstore Notifications',
      channelDescriptionGetter: (message) => 'Notifications for thenexstore User',
      appIconGetter: (message) => '@mipmap/ic_launcher',
      importanceGetter: (message) => Importance.high,
      priorityGetter: (message) => Priority.high,
      playSoundGetter: (message) => true,
      enableVibrationGetter: (message) => true,
      enableLightsGetter: (message) => true,
    );
  }
  Widget buildApp(Widget child) {
    return Builder(
      builder: (context) {
        return FirebaseNotificationsHandler(
          requestPermissionsOnInitialize: true,
          onOpenNotificationArrive: _onOpenNotificationArrive,
          onTap: _onNotificationTap,
          localNotificationsConfiguration: LocalNotificationsConfiguration(androidConfig: _getAndroidConfig()),
          onFcmTokenInitialize: (token) => _onFcmTokenInit(token, context),
          onFcmTokenUpdate: (token) => _onFcmTokenUpdate(token, context),
          handleInitialMessage: true,
          child: child,
        );
      },
    );
  }
}