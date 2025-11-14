import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:thenexstore/data/models/common_response.dart';
import 'dart:io';
import '../helper/api_service.dart';
import '../models/profile_model.dart';
import '../providers/api_state_provider.dart';

class ProfileRepository {
  final ApiService _apiService = ApiService();

  Future<void> getProfile({
    required ApiStateProvider<ProfileResponse> stateProvider,
    CachePolicy cachePolicy = CachePolicy.request,
  }) async {
    await _apiService.get<ProfileResponse>(
      endpoint: 'profile',
      stateProvider: stateProvider,
      fromJson: (json) => ProfileResponse.fromJson(json),
      cachePolicy: cachePolicy,
      extra: {
        'cacheKey': 'profile_data',
        'forceRefresh': cachePolicy == CachePolicy.refresh,
      },
      enableAutoRetry: true,
    );
  }

  Future<void> editProfile({
    required ApiStateProvider<ProfileResponse> stateProvider,
    required Map<String, dynamic> profileData,
    File? image,
  }) async {
    final List<MapEntry<String, File>> files = [];
    if (image != null) {
      files.add(MapEntry('profile_image', image));
    }

    await _apiService.multipart<ProfileResponse>(
      endpoint: 'profile',
      stateProvider: stateProvider,
      files: files,
      data: profileData,
      fromJson: (json) => ProfileResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }

  Future<void> updateFcm({
    required dynamic token,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.patch<CommonResponse>(
      endpoint: 'fcm-token',
      stateProvider: stateProvider,
      data: {
        'token': token,
      },
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }

  Future<void> deleteAccount({
    required int userId ,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.delete<CommonResponse>(
      endpoint: 'profile/$userId',
      stateProvider: stateProvider,
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: true,
    );
  }


  Future<void> updateFeedback({
    required dynamic feedback,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.post<CommonResponse>(
      endpoint: 'feedback',
      stateProvider: stateProvider,
      data: {
        'feedback': feedback,
      },
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }
}