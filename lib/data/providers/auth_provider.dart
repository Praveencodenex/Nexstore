// auth_provider.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thenexstore/data/services/auth_service.dart';
import 'package:thenexstore/data/providers/api_state_provider.dart';
import 'package:thenexstore/data/repository/auth_repository.dart';

import '../../routes/navigator_services.dart';
import '../../routes/routes_names.dart';
import '../../utils/snack_bar.dart';
import '../models/auth_model.dart';


class AuthenticationProvider with ChangeNotifier {
  final AuthRepository _repository;
  final AuthTokenService authManager;


  final ApiStateProvider<AuthResponse<PhoneLoginResponse>> phoneLoginState =
  ApiStateProvider<AuthResponse<PhoneLoginResponse>>();

  final ApiStateProvider<AuthResponse<PhoneLoginResponse>> emailLoginState =
  ApiStateProvider<AuthResponse<PhoneLoginResponse>>();

  final ApiStateProvider<AuthResponse<UserData>> otpVerificationState =
  ApiStateProvider<AuthResponse<UserData>>();
  final ApiStateProvider<AuthResponse<UserData>> otpEmailVerificationState =
  ApiStateProvider<AuthResponse<UserData>>();

  Timer? _resendTimer;
  int _remainingTime = 30;
  bool _canResendOTP = false;
  bool _isSendingOtp = false;
  bool _isSmartAuthSupported = true;

  // Constructor
  AuthenticationProvider({
    required this.authManager,
    AuthRepository? repository,
  }) : _repository = repository ?? AuthRepository();

  // Getters
  bool get isLoading => _isSendingOtp || phoneLoginState.isLoading || otpVerificationState.isLoading;
  bool get canResendOTP => _canResendOTP;
  bool get isSendingOtp => _isSendingOtp;
  int get remainingTime => _remainingTime;
  bool get isLoggedIn => authManager.isLoggedIn;
  bool get isSmartAuthSupported => _isSmartAuthSupported;

  // Setter for SmartAuth support
  void setSmartAuthSupported(bool isSupported) {
    _isSmartAuthSupported = isSupported;
    notifyListeners();
  }

  void startResendTimer() {
    _remainingTime = 30;
    _canResendOTP = false;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        _canResendOTP = true;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  Future<void> loginWithPhone(String phoneNumber) async {
    try {
      _isSendingOtp = true;
      notifyListeners();

      await _repository.sendOtp(
        phone: phoneNumber,
        stateProvider: phoneLoginState,
      );

      phoneLoginState.state.maybeWhen(
        success: (_) async => startResendTimer(),
        orElse: () {},
      );

    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isSendingOtp = false;
      notifyListeners();
    }
  }
  Future<void> loginWithEmail(String email) async {
    try {
      _isSendingOtp = true;
      notifyListeners();

      await _repository.sendEmailOtp(
        email: email,
        stateProvider: emailLoginState,
      );

      emailLoginState.state.maybeWhen(
        success: (_) async => startResendTimer(),
        orElse: () {},
      );

    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isSendingOtp = false;
      notifyListeners();
    }
  }

  Future<void> verifyOTP(String otp, String phone) async {
    try {
      _isSendingOtp = true;
      notifyListeners();

      await _repository.verifyOtp(
        phone: phone,
        otp: otp,
        stateProvider: otpVerificationState,
      );

      otpVerificationState.state.maybeWhen(
        success: (_) async {
          final userData = otpVerificationState.data?.data;
          if (userData != null) {
            await _handleSuccessfulAuth(userData);
          }
        },
        failure: (error) {
          SnackBarUtils.showError(error.message);
        },
        orElse: () {},
      );

    } catch (e) {
      SnackBarUtils.showError('Failed to verify OTP. Please try again.');
    } finally {
      _isSendingOtp = false;
      notifyListeners();
    }
  }

  Future<void> verifyEmailOTP(String otp, String email) async {
    try {
      _isSendingOtp = true;
      notifyListeners();

      await _repository.verifyEmailOtp(
        email: email,
        otp: otp,
        stateProvider: otpEmailVerificationState,
      );

      otpEmailVerificationState.state.maybeWhen(
        success: (_) async {
          final userData = otpEmailVerificationState.data?.data;
          if (userData != null) {
            await _handleSuccessfulAuth(userData);
          }
        },
        failure: (error) {
          SnackBarUtils.showError(error.message);
        },
        orElse: () {},
      );

    } catch (e) {
      SnackBarUtils.showError('Failed to verify OTP. Please try again.');
    } finally {
      _isSendingOtp = false;
      notifyListeners();
    }
  }

  Future<void> _handleSuccessfulAuth(UserData userData) async {
    try {
      await authManager.saveToken(userData.token);
      await NavigationService.instance.pushNamedAndClearStack(
        RouteNames.customBottomNavBar,
      );
    } catch (e) {
      debugPrint('Error handling successful auth: $e');
      throw Exception('Failed to process authentication response: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _repository.handleLogout();
      await authManager.clearToken();
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
      throw Exception('Failed to logout: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}