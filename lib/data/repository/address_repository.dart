// address_repository.dart
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../helper/api_service.dart';
import '../helper/dio_client.dart';
import '../models/address_model.dart';
import '../models/common_response.dart';
import '../models/places_model.dart';
import '../providers/api_state_provider.dart';

class AddressRepository {
  final ApiService _apiService = ApiService();

  final String _placeApiBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  final String _geocodeApiBaseUrl = 'https://maps.googleapis.com/maps/api/geocode';

  Future<void> getAddressList({
    required ApiStateProvider<AddressResponse> stateProvider,
    CachePolicy cachePolicy = CachePolicy.request,
  }) async {
    await _apiService.get<AddressResponse>(
      endpoint: 'addresses',
      stateProvider: stateProvider,
      fromJson: (json) => AddressResponse.fromJson(json),
      cachePolicy: cachePolicy,
      extra: {
        'cacheKey': 'address_data',
        'forceRefresh': cachePolicy == CachePolicy.refresh
      },
      enableAutoRetry: true,
    );
  }

  Future<void> removeAddress({
    required int addressId,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.delete<CommonResponse>(
      endpoint: 'addresses',
      stateProvider: stateProvider,
      queryParameters: {'address_id': addressId},
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }

  Future<void> addAddress({
    required String name,
    required String userName,
    required String address,
    required String pincode,
    required String type,
    required String latitude,
    required String longitude,
    required bool isDefault,
    required String phone,
    required String note,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.post<CommonResponse>(
      endpoint: 'addresses',
      stateProvider: stateProvider,
      data: {
        'contact_name': userName,
        'name': name,
        'address':address,
        'pincode':pincode,
        'type':type,
        'is_default':isDefault,
        'contact_phone':phone,
        'latitude':latitude,
        'longitude':longitude,
        'note':note,
      },
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }


  Future<void> updateAddress({
    required String name,
    required String userName,
    required String address,
    required String pincode,
    required String type,
    required String latitude,
    required String longitude,
    required bool isDefault,
    required String id,
    required String phone,
    required String note,
    required ApiStateProvider<CommonResponse> stateProvider,
  }) async {
    await _apiService.patch<CommonResponse>(
      endpoint: 'addresses',
      stateProvider: stateProvider,
      data: {
        'contact_name': userName,
        'name': name,
        'address':address,
        'pincode':pincode,
        'type':type,
        'address_id':id,
        'is_default':isDefault,
        'contact_phone':phone,
        'latitude':latitude,
        'longitude':longitude,
        'note':note,
      },
      fromJson: (json) => CommonResponse.fromJson(json),
      enableAutoRetry: false,
    );
  }

  Future<void> getPlacePredictions({
    required String input,
    required ApiStateProvider<PredictionResponse> stateProvider,
    CachePolicy? cachePolicy,
  }) async {
    await _apiService.get<PredictionResponse>(
      endpoint: '$_placeApiBaseUrl/autocomplete/json',
      queryParameters: {
        'input': input,
        'key': dotenv.env['GOOGLE_MAP_API_KEY'],
        'components': 'country:in',
        'language': 'en',
      },
      stateProvider: stateProvider,
      fromJson: (json) => PredictionResponse.fromJson(json),
      cachePolicy: cachePolicy,
    );
  }

  Future<void> getPlaceDetails({
    required String placeId,
    required ApiStateProvider<PlaceDetailResponse> stateProvider,
    String? latitude,
    String? longitude,
    CachePolicy? cachePolicy,
  }) async {
    if (latitude != null && longitude != null) {
      // Use reverse geocoding API
      await _apiService.get<PlaceDetailResponse>(
        endpoint: '$_geocodeApiBaseUrl/json',
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': dotenv.env['GOOGLE_MAP_API_KEY'],
        },
        stateProvider: stateProvider,
        cachePolicy: cachePolicy,
        fromJson: (json) {
          if (json['results'] != null && json['results'].isNotEmpty) {
            return PlaceDetailResponse(
              result: PlaceResult.fromJson(json['results'][0]),
              status: json['status'],
            );
          }
          throw Exception('No results found');
        },
      );
    } else {
      // Use place details API
      await _apiService.get<PlaceDetailResponse>(
        endpoint: '$_placeApiBaseUrl/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': dotenv.env['GOOGLE_MAP_API_KEY'],
          'fields': 'geometry,formatted_address,address_components,name',
        },
        stateProvider: stateProvider,
        cachePolicy: cachePolicy,
        fromJson: (json) => PlaceDetailResponse.fromJson(json),
      );
    }
  }


  Future<void> getNearbyPlaces({
    required String latitude,
    required String longitude,
    required ApiStateProvider<NearbyPlacesResponse> stateProvider,
    String radius = '10', // Default to 50 meters
    String? type,
    CachePolicy? cachePolicy,
  }) async {
    await _apiService.get<NearbyPlacesResponse>(
      endpoint: '$_placeApiBaseUrl/nearbysearch/json',
      queryParameters: {
        'location': '$latitude,$longitude',
        'radius': radius,
        'rankby': 'prominence', // Get most relevant places
        'key': dotenv.env['GOOGLE_MAP_API_KEY'],
        if (type != null) 'type': type,
      },
      stateProvider: stateProvider,
      fromJson: (json) => NearbyPlacesResponse.fromJson(json),
      cachePolicy: cachePolicy ?? CachePolicy.refresh,
    );
  }


  Future<void> clearAddressCache() async {
    try {
      await DioClient.instance.clearCache('address_data');
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }
}