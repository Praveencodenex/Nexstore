import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedService {
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String languageKey = 'language_code';
  static const String locationHistoryKey = 'location_history';

  // Existing token methods
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Existing user data methods
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userDataKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(userDataKey);
    return data != null ? jsonDecode(data) : null;
  }

  // New language methods
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, languageCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageKey) ?? 'en'; // Default to English
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Added this method to match what's being called in AddressProvider
  static Future<void> setLocationHistory(List<Map<String, dynamic>> history) async {
    await saveLocationHistory(history);
  }

  static Future<void> saveLocationHistory(List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = history.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList(locationHistoryKey, historyJson);
  }

  static Future<List<Map<String, dynamic>>> getLocationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(locationHistoryKey) ?? [];
    return historyJson
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> addToLocationHistory(Map<String, dynamic> location) async {
    final history = await getLocationHistory();
    history.removeWhere((item) => item['placeId'] == location['placeId']);
    history.insert(0, location);
    if (history.length > 5) {
      history.length = 5;
    }

    await saveLocationHistory(history);
  }

  static Future<void> clearLocationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(locationHistoryKey);
  }
}