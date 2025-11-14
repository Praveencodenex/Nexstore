import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:thenexstore/data/models/common_response.dart';
import 'package:thenexstore/data/models/profile_model.dart';
import 'package:thenexstore/data/repository/profile_repository.dart';
import 'package:thenexstore/data/helper/network_exception.dart';
import 'api_state_provider.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();
  final ApiStateProvider<ProfileResponse> profileState =
  ApiStateProvider<ProfileResponse>();
  final ApiStateProvider<ProfileResponse> editProfileState =
  ApiStateProvider<ProfileResponse>();
  final ApiStateProvider<CommonResponse> feedbackState =
  ApiStateProvider<CommonResponse>();
  final ApiStateProvider<CommonResponse> deleteAccountState =
  ApiStateProvider<CommonResponse>();

  final ApiStateProvider<CommonResponse> updateFcmState =
  ApiStateProvider<CommonResponse>();

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Form state
  String? _gender;
  bool _isLoading = false;
  bool _isReviewing = false;
  File? _selectedImage; // Added to store the selected image file

  // Getters
  String? get gender => _gender;
  bool get isLoading => _isLoading;
  bool get isReviewing => _isReviewing;
  File? get selectedImage => _selectedImage;

  // Error getter
  NetworkException? getEditProfileError() {
    return editProfileState.state.maybeWhen(
      failure: (error) => error,
      orElse: () => null,
    );
  }

  // Updated to accept nullable gender
  void setGender(String? gender) {
    _gender = gender;
    notifyListeners();
  }

  // Set selected image
  void setSelectedImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  // Remove selected image
  void removeSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // Initialize form with data passed from settings screen
  void initializeFormWithData(ProfileData profileData) {
    firstNameController.text = profileData.fName;
    lastNameController.text = profileData.lName;
    phoneController.text = profileData.phone;
    emailController.text = profileData.email;
    _gender = profileData.gender?.toLowerCase();
    _selectedImage = null; // Ensure no local image is selected initially
    notifyListeners();
  }

  // Initialize form data from API response
  void initializeForm(ProfileResponse? profileResponse) {
    if (profileResponse?.data != null) {
      firstNameController.text = profileResponse!.data.fName;
      lastNameController.text = profileResponse.data.lName;
      phoneController.text = profileResponse.data.phone;
      emailController.text = profileResponse.data.email;
      _gender = profileResponse.data.gender?.toLowerCase();
      _selectedImage = null; // Reset selected image
    } else {
      // Default values for testing
      firstNameController.text = '';
      lastNameController.text = '';
      phoneController.text = '';
      emailController.text = '';
    }
    notifyListeners();
  }

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    try {
      await _repository.getProfile(
        stateProvider: profileState,
        cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.request,
      );

      if (profileState.data != null) {
        initializeForm(profileState.data);
      }

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> updateFcm({bool forceRefresh = false,required dynamic fcmToken}) async {
    try {
      await _repository.updateFcm(
        stateProvider: updateFcmState,
         token: fcmToken,
      );
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> updateProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final profileData = {
        'f_name': firstNameController.text,
        'l_name': lastNameController.text,
        'email': emailController.text,
        'gender': _gender,
      };

      await _repository.editProfile(
        stateProvider: editProfileState,
        profileData: profileData,
        image: _selectedImage, // Pass the selected image file
      );

      final isSuccess = editProfileState.state.maybeWhen(
        success: (_) => true,
        orElse: () => false,
      );

      if (isSuccess) {
        _selectedImage = null; // Clear the selected image after successful update
        await fetchProfile(forceRefresh: true); // Refresh profile data
      }

      _isLoading = false;
      notifyListeners();
      return isSuccess;
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> orderFeedback(String feedback) async {
    try {
      _isReviewing=true;
      notifyListeners();
      await _repository.updateFeedback(
        stateProvider: feedbackState, feedback: feedback,
      );

    } catch (e) {
      debugPrint(e.toString());
    }finally{
      _isReviewing=false;
      notifyListeners();
    }
  }
Future<void> deleteAccount(int userId) async {
    try {
      await _repository.deleteAccount(
        stateProvider: deleteAccountState, userId: userId,
      );

    } catch (e) {
      debugPrint(e.toString());
    }finally{
      notifyListeners();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}