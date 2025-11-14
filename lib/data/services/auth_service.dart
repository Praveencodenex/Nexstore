import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenService {
  final SharedPreferences _prefs;
  static const String _tokenKey = 'app_token';
  static const String _isLoggedInKey = 'app_is_logged_in';
  static const String _pendingFcmTokenKey = 'pending_fcm_token';

  AuthTokenService(this._prefs);

  Future<String?> getAuthToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
    await _prefs.setBool(_isLoggedInKey, true);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.setBool(_isLoggedInKey, false);
  }

  bool get isLoggedIn => _prefs.getBool(_isLoggedInKey) ?? false;

  Future<void> storePendingFcmToken(String token) async {
    await _prefs.setString(_pendingFcmTokenKey, token);
  }

  Future<String?> getPendingFcmToken() async {
    return _prefs.getString(_pendingFcmTokenKey);
  }

  Future<void> clearPendingFcmToken() async {
    await _prefs.remove(_pendingFcmTokenKey);
  }
}