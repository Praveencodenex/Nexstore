import 'package:flutter/cupertino.dart';
import '../helper/api_service.dart';
import '../helper/dio_client.dart';
import '../models/auth_model.dart';
import '../providers/api_state_provider.dart';


class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<void> sendOtp({
    required String phone,
    required ApiStateProvider<AuthResponse<PhoneLoginResponse>> stateProvider,
  }) async {
    await _apiService.post<AuthResponse<PhoneLoginResponse>>(
      endpoint: 'send-otp',
      stateProvider: stateProvider,
      data: {'phone': '+91$phone'},
      fromJson: (json) => AuthResponse.fromJson(
        json,
            (data) => PhoneLoginResponse.fromJson(data),
      ),
      enableAutoRetry: false,
    );
  }

  Future<void> sendEmailOtp({
    required String email,
    required ApiStateProvider<AuthResponse<PhoneLoginResponse>> stateProvider,
  }) async {
    await _apiService.post<AuthResponse<PhoneLoginResponse>>(
      endpoint: 'send-email-otp',
      stateProvider: stateProvider,
      data: {'email': email},
      fromJson: (json) => AuthResponse.fromJson(
        json,
            (data) => PhoneLoginResponse.fromJson(data),
      ),
      enableAutoRetry: false,
    );
  }


  Future<void> verifyOtp({
    required String phone,
    required String otp,
    required ApiStateProvider<AuthResponse<UserData>> stateProvider,
  }) async {
    await _apiService.post<AuthResponse<UserData>>(
      endpoint: 'verify-otp-login',
      stateProvider: stateProvider,
      data: {'phone': phone, 'otp': otp,},
      fromJson: (json) => AuthResponse.fromJson(
        json, (data) => UserData.fromJson(data),
      ),
      enableAutoRetry: false,
    );
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
    required ApiStateProvider<AuthResponse<UserData>> stateProvider,
   }) async {
    await _apiService.post<AuthResponse<UserData>>(
      endpoint: 'verify-email-otp',
      stateProvider: stateProvider,
      data: {'email': email, 'otp': otp,},
      fromJson: (json) => AuthResponse.fromJson(
        json, (data) => UserData.fromJson(data),
      ),
      enableAutoRetry: false,
    );
  }

  Future<void> handleLogout() async {
    try {

    } catch (e) {
      debugPrint('Logout API error: $e');
    } finally {
      await DioClient.instance.logout();
    }
  }
}