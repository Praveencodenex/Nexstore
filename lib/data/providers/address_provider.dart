// address_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/shared_pref_service.dart';
import '../models/places_model.dart';
import '../repository/address_repository.dart';
import '../models/address_model.dart';
import '../models/common_response.dart';
import '../../utils/snack_bar.dart';
import '../../routes/navigator_services.dart';
import 'api_state_provider.dart';

class AddressProvider with ChangeNotifier {
  final AddressRepository _repository = AddressRepository();

  // API State Providers
  final ApiStateProvider<AddressResponse> addressState = ApiStateProvider<AddressResponse>();
  final ApiStateProvider<CommonResponse> deleteState = ApiStateProvider<CommonResponse>();
  final ApiStateProvider<CommonResponse> addState = ApiStateProvider<CommonResponse>();
  final ApiStateProvider<CommonResponse> updateState = ApiStateProvider<CommonResponse>();
  final ApiStateProvider<PredictionResponse> predictionsState = ApiStateProvider<PredictionResponse>();
  final ApiStateProvider<PlaceDetailResponse> placeDetailState = ApiStateProvider<PlaceDetailResponse>();
  final ApiStateProvider<NearbyPlacesResponse> nearbyPlacesState = ApiStateProvider<NearbyPlacesResponse>();

  // Controllers for forms
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  // Controllers for search
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  bool _showSearchResults = false;

  // Map related properties
  GoogleMapController? mapController;
  LatLng selectedLocation = const LatLng(10.990601041127169, 76.45549497976026);
  String pickedAddress = '';

  // Nearby places properties
  List<Place> nearbyPlaces = [];
  Place? selectedPlace;
  String selectedPlaceName = '';

  // CRITICAL FIX: Special storage for search results
  String _searchedPlaceName = '';
  String _searchedPlaceAddress = '';
  bool _isFromSearch = false;

  // State properties
  bool _isLoading = false;
  String _selectedType = 'home';
  bool _isDefaultAddress = false;
  Address? selectedAddress;
  List<Map<String, dynamic>> _searchHistory = [];
  bool _isLocationInitialized = false;

  // Debounce for search
  Timer? _searchDebounce;

  // Getters
  bool get isLoading => _isLoading;
  String get selectedType => _selectedType;
  bool get isDefaultAddress => _isDefaultAddress;
  List<Map<String, dynamic>> get searchHistory => _searchHistory;
  bool get showSearchResults => _showSearchResults;



  LatLng? dragPosition;

  Future<void> handlePredictionTap(Prediction prediction) async {
    searchController.text = prediction.description;
    setShowSearchResults(false);
    searchFocusNode.unfocus();
    await getPlaceDetails(prediction.placeId);
  }

  Future<void> updateDragPosition(LatLng position) async {
    selectedLocation = position;
    dragPosition = position; // Store the drag position

    // CRITICAL: Reset all search-related flags
    _isFromSearch = false;
    _searchedPlaceName = '';
    _searchedPlaceAddress = '';

    notifyListeners();
  }



  // CRITICAL FIX: New improved getter for display name
  String get displayLocationName {
    // First priority: Search result
    if (_isFromSearch && _searchedPlaceName.isNotEmpty) {
      debugPrint('DISPLAY: Using search name: $_searchedPlaceName');
      return _searchedPlaceName;
    }

    // Second priority: Manually selected place with proper name
    if (selectedPlaceName.isNotEmpty && !_isLikelyCode(selectedPlaceName)) {
      debugPrint('DISPLAY: Using selected place name: $selectedPlaceName');
      return selectedPlaceName;
    }

    // Third priority: Try to extract a good name from address parts
    if (pickedAddress.isNotEmpty) {
      List<String> parts = pickedAddress.split(',');
      for (String part in parts) {
        String trimmed = part.trim();
        if (trimmed.isNotEmpty && !_isLikelyCode(trimmed)) {
          debugPrint('DISPLAY: Using address part: $trimmed');
          return trimmed;
        }
      }
    }

    // Fallback
    return "Selected Location";
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setShowSearchResults(bool show) {
    _showSearchResults = show;
    notifyListeners();
  }

  // Initialize search controller
  void initSearchController() {
    searchController.addListener(_handleSearchTextChange);
    searchFocusNode.addListener(_handleSearchFocusChange);
  }

  // Handle search text changes
  void _handleSearchTextChange() {
    if (searchController.text.isNotEmpty) {
      setShowSearchResults(true);
      getPlacePredictions(searchController.text);
    } else {
      setShowSearchResults(false);
      clearPredictions();
    }
  }

  // Handle focus changes
  void _handleSearchFocusChange() {
    if (searchFocusNode.hasFocus) {
      setShowSearchResults(searchController.text.isNotEmpty);
    }
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    setShowSearchResults(false);
  }


  // Map Controller Methods
  void setMapController(GoogleMapController controller) {
    mapController = controller;
    notifyListeners();
  }

  // Location Methods
  Future<void> getCurrentLocation() async {
    try {
      setLoading(true);

      // Reset search flags for current location
      _isFromSearch = false;
      _searchedPlaceName = '';
      _searchedPlaceAddress = '';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Add a timeout to ensure the process doesn't hang
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        ).catchError((error) {
          debugPrint('Error getting precise position: $error');
          // Fallback to a less accurate position if high accuracy fails
          return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
        });

        selectedLocation = LatLng(position.latitude, position.longitude);
        await getAddressFromLatLng();

        // After getting address, fetch nearby places
        await getNearbyPlaces();

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: selectedLocation,
              zoom: 15,
            ),
          ),
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
    } finally {
      setLoading(false);
    }
  }

  // IMPROVED: Get nearby places for more accurate establishment names
  Future<void> getNearbyPlaces() async {
    // Skip for search results
    if (_isFromSearch) {
      debugPrint('SKIPPED nearby places for search result');
      return;
    }

    try {
      // First try with a smaller radius for accuracy
      await _repository.getNearbyPlaces(
        latitude: selectedLocation.latitude.toString(),
        longitude: selectedLocation.longitude.toString(),
        radius: '50', // Start with 50 meters
        stateProvider: nearbyPlacesState,
      );

      nearbyPlacesState.state.maybeWhen(
        success: (response) {
          nearbyPlaces = response.results;
          debugPrint('Found ${nearbyPlaces.length} nearby places');

          if (nearbyPlaces.isEmpty) {
            // If no places found, try with a larger radius
            _searchWithLargerRadius();
          } else {
            _findMostRelevantEstablishment();
          }
          notifyListeners();
        },
        failure: (error) {
          debugPrint('Error getting nearby places: ${error.message}');
          _searchWithLargerRadius(); // Try with larger radius on failure
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('Error getting nearby places: $e');
    }
  }

  Future<void> _searchWithLargerRadius() async {
    try {
      await _repository.getNearbyPlaces(
        latitude: selectedLocation.latitude.toString(),
        longitude: selectedLocation.longitude.toString(),
        radius: '200', // Increase to 200 meters
        type: 'establishment', // Specifically request establishments
        stateProvider: nearbyPlacesState,
      );

      nearbyPlacesState.state.maybeWhen(
        success: (response) {
          nearbyPlaces = response.results;
          debugPrint('Found ${nearbyPlaces.length} nearby places with larger radius');

          if (nearbyPlaces.isNotEmpty) {
            _findMostRelevantEstablishment();
          } else {
            _searchWithMaximumRadius();
          }
          notifyListeners();
        },
        failure: (error) {
          debugPrint('Error getting nearby places with larger radius: ${error.message}');
          _searchWithMaximumRadius();
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('Error getting nearby places with larger radius: $e');
    }
  }

  Future<void> _searchWithMaximumRadius() async {
    try {
      await _repository.getNearbyPlaces(
        latitude: selectedLocation.latitude.toString(),
        longitude: selectedLocation.longitude.toString(),
        radius: '500', // Maximum radius
        stateProvider: nearbyPlacesState,
      );

      nearbyPlacesState.state.maybeWhen(
        success: (response) {
          nearbyPlaces = response.results;
          debugPrint('Found ${nearbyPlaces.length} nearby places with maximum radius');

          if (nearbyPlaces.isNotEmpty) {
            _findMostRelevantEstablishment();
          } else {
            selectedPlace = null;
            selectedPlaceName = '';
          }
          notifyListeners();
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('Error getting nearby places with maximum radius: $e');
    }
  }

  // IMPROVED: Better establishment detection
  void _findMostRelevantEstablishment() {
    if (nearbyPlaces.isEmpty) return;

    // Skip if from search
    if (_isFromSearch) return;

    List<String> priorityTypes = [
      'establishment',
      'point_of_interest',
      'premise',
      'hospital', 'health', 'doctor', 'clinic',
      'store', 'shop', 'mall',
      'restaurant', 'cafe', 'food',
      'school', 'university', 'college',
      'bank', 'atm', 'finance',
      'pharmacy', 'drugstore'
    ];

    // First: Try to find exact or very close matches
    double targetLat = selectedLocation.latitude;
    double targetLng = selectedLocation.longitude;

    // Calculate distance threshold (approximately 50 meters)
    double distanceThreshold = 0.0005;

    // First pass: Find very close establishments
    List<Place> nearbyEstablishments = nearbyPlaces.where((place) {
      if (place.geometry?.location == null) return false;

      double lat = place.geometry!.location!.lat;
      double lng = place.geometry!.location!.lng;

      double distance = (lat - targetLat) * (lat - targetLat) +
          (lng - targetLng) * (lng - targetLng);

      return distance < distanceThreshold;
    }).toList();

    Place? bestMatch;

    // From close establishments, prioritize by type
    if (nearbyEstablishments.isNotEmpty) {
      // First, check for priority types
      for (String type in priorityTypes) {
        for (Place place in nearbyEstablishments) {
          if (place.types != null &&
              place.types!.contains(type) &&
              place.name != null &&
              place.name!.isNotEmpty &&
              !_isLikelyCode(place.name!)) {
            bestMatch = place;
            break;
          }
        }
        if (bestMatch != null) break;
      }

      // If no priority types found, take the closest one with a valid name
      if (bestMatch == null) {
        for (Place place in nearbyEstablishments) {
          if (place.name != null && place.name!.isNotEmpty &&
              !_isLikelyCode(place.name!)) {
            bestMatch = place;
            break;
          }
        }
      }
    }

    // If no close matches, take any establishment with proper name
    if (bestMatch == null) {
      for (Place place in nearbyPlaces) {
        if (place.name != null && place.name!.isNotEmpty &&
            !_isLikelyCode(place.name!)) {
          bestMatch = place;
          break;
        }
      }
    }

    if (bestMatch != null) {
      selectedPlace = bestMatch;
      selectedPlaceName = selectedPlace!.name!;
      debugPrint('Selected establishment: $selectedPlaceName');
    } else {
      // If all else fails, just pick the first non-empty name that's not a code
      for (Place place in nearbyPlaces) {
        if (place.name != null && place.name!.isNotEmpty && !_isLikelyCode(place.name!)) {
          selectedPlace = place;
          selectedPlaceName = place.name!;
          debugPrint('Selected fallback place: $selectedPlaceName');
          break;
        }
      }
    }

    // Update the address with the selected place name
    if (selectedPlaceName.isNotEmpty) {
      _updateAddressWithPlaceName();
    }
  }

  // IMPROVED: Better code detection
  bool _isLikelyCode(String text) {
    // Check for codes like "394+westhil"
    if (text.contains('+')) return true;

    // Check for short alphanumeric strings that look like codes
    if (text.length <= 8 && RegExp(r'[0-9]').hasMatch(text) && RegExp(r'[A-Za-z]').hasMatch(text)) {
      // If it has both letters and numbers and is short, likely a code
      return true;
    }

    // Check for specific code patterns
    if (RegExp(r'^[0-9][A-Za-z][0-9]{3,4}$').hasMatch(text)) {
      return true;
    }

    return false;
  }

  void _updateAddressWithPlaceName() {
    if (selectedPlaceName.isNotEmpty) {
      // Set the name field to the establishment name
      nameController.text = selectedPlaceName;

      // Update the address field
      if (pickedAddress.isNotEmpty) {
        // Check if place name is already part of the address
        if (!pickedAddress.toLowerCase().contains(selectedPlaceName.toLowerCase())) {
          // Add the establishment name to the beginning
          pickedAddress = '$selectedPlaceName, $pickedAddress';
        }
        addressController.text = pickedAddress;
      }

      notifyListeners();
      debugPrint('Address updated with establishment name: $selectedPlaceName');
    }
  }

  // CRITICAL FIX: Completely revised getAddressFromLatLng
  Future<void> getAddressFromLatLng() async {
    // HARD BLOCK: Never override search results
    if (_isFromSearch) {
      debugPrint('BLOCKED: Keeping search result name: $_searchedPlaceName');
      return;
    }

    try {
      setLoading(true);
      await _repository.getPlaceDetails(
        placeId: '', // Empty for reverse geocoding
        stateProvider: placeDetailState,
        latitude: selectedLocation.latitude.toString(),
        longitude: selectedLocation.longitude.toString(),
      );

      placeDetailState.state.maybeWhen(
        success: (details) {
          debugPrint('Place details received: ${details.result.formattedAddress}');

          // First check if we have a name directly from the place details
          if (details.result.name != null &&
              details.result.name!.isNotEmpty &&
              !_isLikelyCode(details.result.name!)) {
            selectedPlaceName = details.result.name!;
            debugPrint('Place name from details: $selectedPlaceName');
          } else {
            selectedPlaceName = '';
          }

          if (details.result.addressComponents != null) {
            _updateAddressFromComponents(details.result.addressComponents!);
          } else if (details.result.formattedAddress != null) {
            _updateAddressFromFormatted(details.result.formattedAddress!);
          } else {
            debugPrint('No address details found');
          }

          notifyListeners();
        },
        failure: (error) {
          debugPrint('Error getting address details: ${error.message}');
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
    } finally {
      setLoading(false);
    }
  }

  void _updateAddressFromComponents(List<AddressComponent> components) {
    // Skip if this is from search
    if (_isFromSearch) return;

    // Debug all components first
    debugPrint('Address components found: ${components.length}');
    for (var component in components) {
      debugPrint('Component: ${component.longName}, Types: ${component.types.join(', ')}');
    }

    // First check for establishment name
    String? establishment = _getAddressComponent(components, [
      PlaceType.establishment,
      PlaceType.pointOfInterest,
      PlaceType.premise
    ]);

    if (establishment != null && !_isLikelyCode(establishment)) {
      debugPrint('Found establishment: $establishment');

      // Only use this if we didn't get a name from place details or nearby search
      if (selectedPlaceName.isEmpty) {
        selectedPlaceName = establishment;
      }
    }

    String? streetNumber = _getAddressComponent(components, [PlaceType.streetAddress]);
    String? route = _getAddressComponent(components, [PlaceType.route]);
    String? locality = _getAddressComponent(components, [PlaceType.locality, PlaceType.sublocality]);
    String? area = _getAddressComponent(components, [PlaceType.administrativeAreaLevel1]);
    String? postalCode = _getAddressComponent(components, [PlaceType.postalCode]);

    // Build address parts - if we have a place name, use it first
    List<String> addressParts = [];

    if (selectedPlaceName.isNotEmpty && !_isLikelyCode(selectedPlaceName)) {
      addressParts.add(selectedPlaceName);
    } else if (establishment != null && !_isLikelyCode(establishment)) {
      addressParts.add(establishment);
    }

    // Add the rest of the address components
    addressParts.addAll([
      if (streetNumber != null) streetNumber,
      if (route != null) route,
      if (locality != null) locality,
      if (area != null) area,
    ].where((part) => part.isNotEmpty && !addressParts.contains(part)));

    pickedAddress = addressParts.join(', ');

    // Set the name in the nameController with better validation
    if (selectedPlaceName.isNotEmpty && !_isLikelyCode(selectedPlaceName)) {
      nameController.text = selectedPlaceName;
    } else if (establishment != null && !_isLikelyCode(establishment)) {
      nameController.text = establishment;
    } else {
      // Improved validation to avoid setting codes as names
      String possibleName = [streetNumber, route]
          .where((part) => part != null && part.isNotEmpty)
          .join(' ');

      // Check if it looks like a code (has numbers and letters but is short)
      bool looksLikeCode = _isLikelyCode(possibleName);
      if (!looksLikeCode && possibleName.isNotEmpty) {
        nameController.text = possibleName;
      } else if (locality != null) {
        // Fall back to locality name instead of code
        nameController.text = locality;
      } else {
        // As a last resort, use a generic label
        nameController.text = "Selected Location";
      }
    }

    addressController.text = pickedAddress;
    if (postalCode != null) {
      pincodeController.text = postalCode;
    }
  }

  String? _getAddressComponent(
      List<AddressComponent> components,
      List<String> types,
      ) {
    for (var component in components) {
      for (var type in types) {
        if (component.types.contains(type)) {
          return component.longName;
        }
      }
    }
    return null;
  }

  void _updateAddressFromFormatted(String formattedAddress) {
    // Skip if from search
    if (_isFromSearch) return;

    pickedAddress = formattedAddress;

    // If we have a place name, use it
    if (selectedPlaceName.isNotEmpty && !_isLikelyCode(selectedPlaceName)) {
      nameController.text = selectedPlaceName;

      // Update the full address to include the place name if needed
      if (!formattedAddress.contains(selectedPlaceName)) {
        pickedAddress = '$selectedPlaceName, $formattedAddress';
      }
    } else {
      // Get the first part of the formatted address
      String firstPart = formattedAddress.split(',').first.trim();

      // Check if it looks like a code (has numbers and letters but is short)
      bool looksLikeCode = _isLikelyCode(firstPart);
      if (!looksLikeCode) {
        nameController.text = firstPart;
      } else {
        // Get the second part if the first part looks like a code
        List<String> parts = formattedAddress.split(',');
        if (parts.length > 1) {
          nameController.text = parts[1].trim();
        } else {
          nameController.text = "Selected Location";
        }
      }
    }

    addressController.text = pickedAddress;
  }

  // CRITICAL FIX: Reset search flags for manual location change
  Future<void> updateLocation(LatLng location) async {
    selectedLocation = location;
    // Reset place information
    selectedPlace = null;
    selectedPlaceName = '';
    nearbyPlaces = [];

    // CRITICAL: Reset all search-related flags
    _isFromSearch = false;
    _searchedPlaceName = '';
    _searchedPlaceAddress = '';

    notifyListeners();

    // Get address first, then nearby places
    await getAddressFromLatLng();
    await getNearbyPlaces();
  }



  // CRITICAL FIX: Process address only for non-search results
  Future<void> handleCameraIdle() async {
    // HARD BLOCK: Skip if from search
    if (_isFromSearch) {
      debugPrint('CAMERA IDLE: Kept search result name: $_searchedPlaceName');
      return;
    }

    // Get address from coordinates
    await getAddressFromLatLng();

    // Get nearby places to find a good name
    await getNearbyPlaces();
  }

  // Search functionality
  Future<void> getPlacePredictions(String input) async {
    try {
      // Cancel previous timer if it exists
      if (_searchDebounce?.isActive ?? false) {
        _searchDebounce!.cancel();
      }

      // Show loading indicator
      setLoading(true);

      // Small debounce to avoid too many API calls
      _searchDebounce = Timer(const Duration(milliseconds: 100), () async {
        if (input.isEmpty) {
          clearPredictions();
          return;
        }

        await _repository.getPlacePredictions(
          input: input,
          stateProvider: predictionsState,
          cachePolicy: CachePolicy.refresh,
        );

        // Debug the results
        predictionsState.state.maybeWhen(
          success: (response) {
            debugPrint('Found ${response.predictions.length} predictions');
          },
          failure: (error) {
            debugPrint('Search error: ${error.message}');
          },
          orElse: () {},
        );

        setLoading(false);
      });
    } catch (e) {
      debugPrint('Error getting predictions: $e');
      setLoading(false);
    }
  }

  void clearPredictions() {
    predictionsState.setData(PredictionResponse(
        predictions: [],
        status: 'ZERO_RESULTS'
    ));
    setLoading(false);
  }

  // CRITICAL FIX: Completely rewritten to properly handle search results
  Future<void> getPlaceDetails(String placeId) async {
    try {
      setLoading(true);

      // Call the API
      await _repository.getPlaceDetails(
        placeId: placeId,
        stateProvider: placeDetailState,
      );

      placeDetailState.state.maybeWhen(
        success: (details) {
          if (details.result.geometry?.location != null) {
            // 1. Set the map location
            final location = details.result.geometry!.location!;
            selectedLocation = LatLng(location.lat, location.lng);

            // 2. CRITICAL: Save the searched name and address separately
            if (details.result.name != null &&
                details.result.name!.isNotEmpty &&
                !_isLikelyCode(details.result.name!)) {
              _searchedPlaceName = details.result.name!;
              selectedPlaceName = _searchedPlaceName;
              debugPrint('SAVED SEARCH NAME: $_searchedPlaceName');
            } else if (details.result.formattedAddress != null) {
              // Try to get a good name from the address
              String firstPart = details.result.formattedAddress!.split(',').first.trim();
              if (!_isLikelyCode(firstPart)) {
                _searchedPlaceName = firstPart;
                selectedPlaceName = _searchedPlaceName;
              } else {
                // If first part looks like a code, try the second part
                List<String> parts = details.result.formattedAddress!.split(',');
                if (parts.length > 1) {
                  _searchedPlaceName = parts[1].trim();
                  selectedPlaceName = _searchedPlaceName;
                }
              }
              debugPrint('SAVED ADDRESS PART AS NAME: $_searchedPlaceName');
            }

            _searchedPlaceAddress = details.result.formattedAddress ?? '';
            pickedAddress = _searchedPlaceAddress;

            // 3. Set the main address fields too (as backup)
            if (_searchedPlaceName.isNotEmpty) {
              nameController.text = _searchedPlaceName;
            }

            if (_searchedPlaceAddress.isNotEmpty) {
              addressController.text = _searchedPlaceAddress;
            }

            // 4. Flag this as from search - CRITICAL
            _isFromSearch = true;

            // 5. Debug output
            debugPrint('SEARCH SELECTED NAME: $_searchedPlaceName');
            debugPrint('SEARCH ADDRESS: $_searchedPlaceAddress');

            // 6. Move map to location
            mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: selectedLocation,
                  zoom: 16,
                ),
              ),
            );

            notifyListeners();
          }
        },
        failure: (error) {
          debugPrint('Error getting place details: ${error.message}');
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('Error getting place details: $e');
    } finally {
      setLoading(false);
    }
  }

  // Method for getting the location name to return
  String getReturnLocationName() {
    if (_isFromSearch && _searchedPlaceName.isNotEmpty) {
      return _searchedPlaceName;
    }

    if (selectedPlaceName.isNotEmpty && !_isLikelyCode(selectedPlaceName)) {
      return selectedPlaceName;
    }

    // Go through address parts and find a good name
    if (pickedAddress.isNotEmpty) {
      List<String> parts = pickedAddress.split(',');
      for (String part in parts) {
        String trimmed = part.trim();
        if (trimmed.isNotEmpty && !_isLikelyCode(trimmed)) {
          return trimmed;
        }
      }
    }

    return pickedAddress.isNotEmpty ? pickedAddress.split(',').first : "Selected Location";
  }

  // Search History Methods
  Future<void> loadSearchHistory() async {
    try {
      _searchHistory = await SharedService.getLocationHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading search history: $e');
      _searchHistory = [];
    }
  }

  Future<void> addToSearchHistory(Map<String, dynamic> location) async {
    try {
      await SharedService.addToLocationHistory(location);
      await loadSearchHistory();
    } catch (e) {
      debugPrint('Error adding to search history: $e');
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      await SharedService.clearLocationHistory();
      _searchHistory = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing search history: $e');
    }
  }

  // Reset location data
  void resetLocationData() {
    // Only initialize once
    if (!_isLocationInitialized) {
      _isLocationInitialized = true;
      getCurrentLocation();
    } else {
      pickedAddress = '';
      selectedPlace = null;
      selectedPlaceName = '';
      nearbyPlaces = [];
      _isFromSearch = false;
      _searchedPlaceName = '';
      _searchedPlaceAddress = '';

      notifyListeners();
      getCurrentLocation();
    }
  }

  void clearLocationData() {
      pickedAddress = '';
      selectedPlace = null;
      selectedPlaceName = '';
      nearbyPlaces = [];
      _isFromSearch = false;
      _searchedPlaceName = '';
      _searchedPlaceAddress = '';
      notifyListeners();

    }

  Future<void> fetchAddressData({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await clearCache();
      }

      await _repository.getAddressList(
        stateProvider: addressState,
        cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.request,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching address data: $e');
    }
  }

  Future<void> addAddress(
      String name,
      String userName,
      String address,
      String pincode,
      String type,
      String latitude,
      String longitude,
      bool isDefault,
      String phone,
      String note,
      ) async {
    if (_isLoading) return;

    try {
      setLoading(true);

      await _repository.addAddress(
        name: name,
        userName: userName,
        address: address,
        pincode: pincode,
        type: type,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        phone: phone,
        note: note,
        stateProvider: addState,
      );

      addState.state.maybeWhen(
        success: (_) async {
          await fetchAddressData(forceRefresh: true);
          NavigationService.instance.goBack();
        },
        failure: (error) {
          SnackBarUtils.showError(error.message);
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('Error adding address: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateToCart(
      String name,
      String userName,
      String address,
      String pincode,
      String id,
      String type,
      String latitude,
      String longitude,
      bool isDefault,
      String phone,
      String note,
      ) async {
    if (_isLoading) return;

    try {
      setLoading(true);

      await _repository.updateAddress(
        name: name,
        userName: userName,
        address: address,
        pincode: pincode,
        type: type,
        note: note,
        id: id,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        phone: phone,
        stateProvider: updateState,
      );

      updateState.state.maybeWhen(
        success: (_) async {
          await fetchAddressData(forceRefresh: true);
          NavigationService.instance.goBack();
        },
        failure: (error) {
          SnackBarUtils.showError(error.message);
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('Error updating address: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> removeAddress(int addressId) async {
    if (_isLoading) return;

    try {
      setLoading(true);

      if (selectedAddress != null && selectedAddress!.id == addressId) {
        selectedAddress = null;
      }

      await _repository.removeAddress(
        addressId: addressId,
        stateProvider: deleteState,
      );

      deleteState.state.maybeWhen(
        success: (_) async {
          await fetchAddressData(forceRefresh: true);
          if (selectedAddress == null) {
            final newDefaultAddress = getDefaultAddress();
            if (newDefaultAddress != null) {
              setSelectedAddress(newDefaultAddress);
            }
          }
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('Error removing address: $e');
    } finally {
      setLoading(false);
    }
  }

  // Utility Methods
  void setType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setDefaultAddress(bool value) {
    _isDefaultAddress = value;
    notifyListeners();
  }

  void setSelectedAddress(Address address) {
    selectedAddress = address;
    notifyListeners();
  }

  Address? getDefaultAddress() {
    return addressState.state.maybeWhen(
      success: (addressData) {
        final addresses = addressData.data;
        if (addresses.isEmpty) return null;
        return addresses.firstWhere(
              (address) => address.isDefault,
          orElse: () => addresses.first,
        );
      },
      orElse: () => null,
    );
  }

  void initializeForm(Address? address) {
    if (address != null) {
      nameController.text = address.name;
      userNameController.text = address.contactName ?? "";
      addressController.text = address.address;
      phoneController.text = address.contactPhone ?? '';
      pincodeController.text = address.pincode;
      instructionsController.text = address.note ?? '';
      _selectedType = address.type;
      _isDefaultAddress = address.isDefault;

      if (address.latitude != null && address.longitude != null) {
        selectedLocation = LatLng(
          double.parse(address.latitude.toString()),
          double.parse(address.longitude.toString()),
        );
      }
    } else {
      nameController.clear();
      addressController.clear();
      phoneController.clear();
      pincodeController.clear();
      userNameController.clear();
      instructionsController.clear();
      _selectedType = 'home';
      _isDefaultAddress = false;
    }
    notifyListeners();
  }

  Future<void> clearCache() async {
    try {
      await _repository.clearAddressCache();
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    pincodeController.dispose();
    userNameController.dispose();
    instructionsController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    _searchDebounce?.cancel();

    super.dispose();
  }
}