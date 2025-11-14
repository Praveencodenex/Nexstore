// location_picker_screen.dart - Prevent back navigation
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'dart:math' as math;

import '../../data/providers/address_provider.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../components/custom_button.dart';
import '../components/common_app_bar.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _translateAnimation;
  late Animation<double> _scaleAnimation;

  // Service area boundary coordinates - PROPERLY ORDERED clockwise
  static const List<LatLng> _originalServiceAreaPoints = [
    LatLng(10.962981, 76.4415797),
    LatLng(10.992300675915427, 76.41094352208904),
    LatLng(11.016185, 76.4391736),
    LatLng(11.0245836, 76.4546765),
    LatLng(11.0244588, 76.4668586),
    LatLng(11.0253506, 76.5027893),
    LatLng(10.9985797, 76.5077477),
    LatLng(10.9655999, 76.477087),
    LatLng(10.9613239, 76.4696725),
    LatLng(10.952112490469137, 76.43246742443336),
    LatLng(10.979051815145777, 76.40414448210504),
    LatLng(10.972501484435647, 76.50080048025548),
  ];

  // Properly sorted polygon points
  late List<LatLng> _serviceAreaPoints;
  late Set<Polygon> _polygons;
  late LatLng _mapCenter;

  // Add these variables to track initialization
  bool _isLocationInitialized = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();

    // Sort points to create proper polygon
    _serviceAreaPoints = _sortPointsClockwise(_originalServiceAreaPoints);

    // Calculate map center from polygon bounds (fallback only)
    _mapCenter = _calculatePolygonCenter(_serviceAreaPoints);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _translateAnimation = Tween<double>(
      begin: 0,
      end: -20,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Initialize polygon with sorted points
    _polygons = {
      Polygon(
        polygonId: const PolygonId('service_area'),
        points: _serviceAreaPoints,
        strokeColor: kPrimaryColor,
        strokeWidth: 2,
        fillColor: kPrimaryColor.withOpacity(0.1),
      ),
    };

    // Initialize provider and get current location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  // NEW METHOD: Initialize location properly
  Future<void> _initializeLocation() async {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    try {
      // Initialize search controller
      addressProvider.initSearchController();

      // Get current location first
      await addressProvider.getCurrentLocation();

      // Mark as initialized
      setState(() {
        _isLocationInitialized = true;
      });

      // Move map to current location if map controller is available
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: addressProvider.selectedLocation,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initializing location: $e');
      // Fallback to map center if location fails
      addressProvider.updateLocation(_mapCenter);
      setState(() {
        _isLocationInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Sort points clockwise around centroid
  List<LatLng> _sortPointsClockwise(List<LatLng> points) {
    // Calculate centroid
    double centerLat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    double centerLng = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    LatLng center = LatLng(centerLat, centerLng);

    // Sort points by angle from center
    List<LatLng> sortedPoints = List.from(points);
    sortedPoints.sort((a, b) {
      double angleA = math.atan2(a.latitude - center.latitude, a.longitude - center.longitude);
      double angleB = math.atan2(b.latitude - center.latitude, b.longitude - center.longitude);
      return angleA.compareTo(angleB);
    });

    return sortedPoints;
  }

  // Calculate polygon center for map positioning
  LatLng _calculatePolygonCenter(List<LatLng> points) {
    double minLat = points.map((p) => p.latitude).reduce(math.min);
    double maxLat = points.map((p) => p.latitude).reduce(math.max);
    double minLng = points.map((p) => p.longitude).reduce(math.min);
    double maxLng = points.map((p) => p.longitude).reduce(math.max);

    return LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
  }

  // Improved point-in-polygon algorithm
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      double xi = polygon[i].longitude;
      double yi = polygon[i].latitude;
      double xj = polygon[j].longitude;
      double yj = polygon[j].latitude;

      if (((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude < (xj - xi) * (point.latitude - yi) / (yj - yi) + xi)) {
        intersectCount++;
      }
      j = i;
    }

    return (intersectCount % 2) == 1;
  }

  void _handleLocationSelection(LatLng position, AddressProvider addressProvider) {
    if (!_isPointInPolygon(position, _serviceAreaPoints)) {
      //_showServiceUnavailableDialog();
      return;
    }

    _animationController.forward();
    addressProvider.updateLocation(position).then((_) {
      _animationController.reverse();
      addressProvider.mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position,
            zoom: 15,
          ),
        ),
      );
    });

    // Hide search results when map is tapped
    addressProvider.setShowSearchResults(false);
    addressProvider.searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // SOLUTION: Wrap Scaffold with PopScope (Flutter 3.12+) or WillPopScope (older versions)
    // This prevents ALL back navigation (back button, gestures, etc.)
    return PopScope(
      canPop: false, // Prevents back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Optionally show a dialog asking user to confirm location first
        _showMustConfirmDialog(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: const AppBarCommon(
          title: "Location Information",
          search: false,
        ),
        body: Column(
          children: [
            // Map Container - Now takes full space
            Expanded(
              child: Stack(
                children: [
                  // Google Map - FIXED: Use current location or fallback
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      // Use current location if initialized, otherwise use map center
                      target: _isLocationInitialized
                          ? addressProvider.selectedLocation
                          : _mapCenter,
                      zoom: _isLocationInitialized ? 15 : 12,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      addressProvider.setMapController(controller);

                      // If location is already initialized, move to it
                      if (_isLocationInitialized) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: addressProvider.selectedLocation,
                                zoom: 15,
                              ),
                            ),
                          );
                        });
                      }
                    },
                    onCameraMove: (position) {
                      if (!_animationController.isAnimating) {
                        _animationController.forward();
                      }
                      addressProvider.updateDragPosition(position.target);
                    },
                    onCameraIdle: () {
                      _animationController.reverse();
                      // Get the center position of the map and fetch address
                      addressProvider.handleCameraIdle();
                    },
                    onTap: (LatLng position) {
                      _handleLocationSelection(position, addressProvider);
                    },
                    polygons: _polygons,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false, // We'll use custom button
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: true,
                    buildingsEnabled: true,
                    mapType: MapType.normal,
                  ),

                  // Show loading indicator while initializing location
                  if (!_isLocationInitialized)
                    Container(
                      color: Colors.white.withOpacity(0.8),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: kPrimaryColor,),
                            SizedBox(height: 16),
                            Text('Getting your location...'),
                          ],
                        ),
                      ),
                    ),

                  // Search Bar - Now overlapping the map at the top
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 70, // Leave space for the location button
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: addressProvider.searchController,
                        focusNode: addressProvider.searchFocusNode,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            addressProvider.setShowSearchResults(true);
                          } else {
                            addressProvider.setShowSearchResults(false);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Search location within service area',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: addressProvider.searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              addressProvider.clearSearch();
                              addressProvider.setShowSearchResults(false);
                            },
                          )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Search Results Overlay - Positioned below search bar
                  if (addressProvider.showSearchResults)
                    Positioned(
                      top: 70, // Position below the search bar
                      left: 16,
                      right: 16,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Consumer<AddressProvider>(
                            builder: (context, provider, _) {
                              return provider.predictionsState.state.maybeWhen(
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                success: (data) {
                                  if (data.predictions.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text('No results found'),
                                    );
                                  }

                                  return ListView.separated(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: data.predictions.length,
                                    separatorBuilder: (context, index) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final prediction = data.predictions[index];
                                      return ListTile(
                                        leading: const Icon(Icons.location_on_outlined),
                                        title: Text(
                                          prediction.structuredFormatting?.mainText ?? prediction.description,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          prediction.structuredFormatting?.secondaryText ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        onTap: () {
                                          provider.handlePredictionTap(prediction).then((_) {
                                            final selectedPosition = provider.selectedLocation;
                                            if (!_isPointInPolygon(selectedPosition, _serviceAreaPoints)) {
                                              // _showServiceUnavailableDialog();
                                            }
                                          });
                                        },
                                      );
                                    },
                                  );
                                },
                                orElse: () => const SizedBox.shrink(),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  // Service Area Legend (when search is not active) - Positioned lower to avoid overlap with search
                  if (!addressProvider.showSearchResults && _isLocationInitialized)
                    Positioned(
                      top: 75, // Moved below search bar
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.3),
                                border: Border.all(color: kPrimaryColor, width: 1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Service Area',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Custom Current Location Button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        final addressProvider = Provider.of<AddressProvider>(context, listen: false);
                        // Get current location and check if it's in service area
                        await addressProvider.getCurrentLocation();
                        final currentLocation = addressProvider.selectedLocation;

                        if (!_isPointInPolygon(currentLocation, _serviceAreaPoints)) {
                          //_showServiceUnavailableDialog();
                        } else {
                          addressProvider.mapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: currentLocation,
                                zoom: 15,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Icon(
                        Icons.my_location,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),

                  // Centered Pin - Properly centered in the map area
                  if (!addressProvider.showSearchResults && _isLocationInitialized)
                    Center(
                      child: AnimatedBuilder(
                        animation: _translateAnimation,
                        builder: (context, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Pin Icon
                              Transform.translate(
                                offset: Offset(0, _translateAnimation.value),
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: const Icon(
                                    Icons.location_pin,
                                    size: 40,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              // Pin Shadow
                              Transform.translate(
                                offset: Offset(0, _translateAnimation.value + 5),
                                child: Container(
                                  width: 12,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Bottom sheet only shows when location is initialized
            if (_isLocationInitialized)
              Consumer<AddressProvider>(
                builder: (context, provider, _) {
                  if (provider.showSearchResults) {
                    return const SizedBox.shrink();
                  }

                  final currentPosition = provider.dragPosition ?? provider.selectedLocation;
                  final isInServiceArea = _isPointInPolygon(currentPosition, _serviceAreaPoints);

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16),vertical: getProportionateScreenHeight(26)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Service status indicator
                        if (!isInServiceArea) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(12),
                              vertical: getProportionateScreenHeight(6),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: getProportionateScreenWidth(16),
                                  color: Colors.red[600],
                                ),
                                SizedBox(width: getProportionateScreenWidth(8)),
                                Expanded(
                                  child: Text(
                                    'Service not available at this location',
                                    style: TextStyle(
                                      fontSize: getProportionateScreenWidth(12),
                                      color: Colors.red[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: getProportionateScreenHeight(8)),
                        ],

                        // Location Name
                        Text(
                          provider.displayLocationName,
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(16),
                            fontWeight: FontWeight.bold,
                            color: isInServiceArea ? Colors.black87 : Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: getProportionateScreenHeight(4)),

                        // Full Address
                        Text(
                          provider.pickedAddress.isNotEmpty
                              ? provider.pickedAddress
                              : 'Move the map to select a location within service area',
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(12),
                            color: isInServiceArea ? Colors.grey[600] : Colors.grey[400],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: getProportionateScreenHeight(12)),

                        // Current Location Info
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(12),
                            vertical: getProportionateScreenHeight(6),
                          ),
                          decoration: BoxDecoration(
                            color: isInServiceArea ? Colors.green[50] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: isInServiceArea ? Border.all(color: Colors.green[200]!) : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isInServiceArea ? Icons.check_circle_outline : Icons.location_searching,
                                size: getProportionateScreenWidth(16),
                                color: isInServiceArea ? Colors.green[600] : Colors.grey[600],
                              ),
                              SizedBox(width: getProportionateScreenWidth(8)),
                              Expanded(
                                child: Text(
                                  isInServiceArea
                                      ? 'Selected location is available for delivery'
                                      : 'Please move the map to select a location within the highlighted area',
                                  style: TextStyle(
                                    fontSize: getProportionateScreenWidth(11),
                                    color: isInServiceArea ? Colors.green[600] : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: getProportionateScreenHeight(26)),

                        // Confirm Button
                        CustomButton(
                          text: "Confirm & Continue",
                          press: isInServiceArea ? () {
                            if (provider.pickedAddress.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please wait while we fetch the address'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            String locationName = provider.getReturnLocationName();
                            provider.nameController.text = locationName;
                            provider.addressController.text = provider.pickedAddress;

                            Navigator.pop(context, {
                              'address': provider.pickedAddress,
                              'location': locationName,
                              'latitude': currentPosition.latitude.toString(),
                              'longitude': currentPosition.longitude.toString(),
                            });
                          } : () {
                            //_showServiceUnavailableDialog();
                          },
                          btnColor: isInServiceArea ? kPrimaryColor : Colors.grey[400]!,
                          txtColor: kWhiteColor,
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to show dialog when user tries to go back without confirming
  void _showMustConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Location',style: headingH3Style,),
          content:  Text(
            'Please select and confirm your location before going back.',style: bodyStyleStyleB2.copyWith(color: Colors.black38),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:  Text('OK',style: bodyStyleStyleB2SemiBold.copyWith(color: kPrimaryColor),),
            ),
          ],
        );
      },
    );
  }
}