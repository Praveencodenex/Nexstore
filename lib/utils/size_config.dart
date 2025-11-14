import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late Orientation orientation;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static bool isTablet = false;
  static bool isInitialized = false;
  static bool isWeb = kIsWeb;

  // Reference dimensions (based on iPhone 12 Pro)
  static const double _referenceScreenWidth = 390.0;
  static const double _referenceScreenHeight = 844.0;

  // Web-specific breakpoints
  static const double _webMaxWidth = 1440.0;
  static const double _webMinWidth = 320.0;

  void init(BuildContext context) {
    if (isInitialized) return;

    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;

    // Web-specific adjustments
    if (kIsWeb) {
      // Limit maximum screen width for web
      screenWidth = screenWidth.clamp(_webMinWidth, _webMaxWidth);

      // Adjust height based on aspect ratio for web
      double aspectRatio = screenHeight / screenWidth;
      if (aspectRatio > 2) {
        // Very tall viewport, limit the height
        screenHeight = screenWidth * 2;
      } else if (aspectRatio < 0.5) {
        // Very wide viewport, maintain minimum height
        screenHeight = screenWidth * 0.5;
      }
    }

    // Safe area padding
    _safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    // Safe area block sizes
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    // Check if device is tablet or large screen
    isTablet = _mediaQueryData.size.shortestSide >= 600 || (kIsWeb && screenWidth >= 768);

    // Set default size based on platform and orientation
    defaultSize = orientation == Orientation.landscape
        ? screenHeight * 0.024
        : screenWidth * 0.024;

    isInitialized = true;
  }

  static void ensureInitialized() {
    if (!isInitialized) {
      throw Exception("SizeConfig.init(context) has not been called. Make sure to call it in the build method.");
    }
  }
}

double getProportionateScreenHeight(double inputHeight) {
  SizeConfig.ensureInitialized();

  double scaleFactor;

  if (SizeConfig.isWeb) {
    // Web-specific scaling
    scaleFactor = SizeConfig.screenHeight / SizeConfig._referenceScreenHeight;
    scaleFactor = scaleFactor.clamp(0.5, 1.5); // More flexible scaling for web
  } else {
    // Mobile scaling
    scaleFactor = SizeConfig.screenHeight / SizeConfig._referenceScreenHeight;
    if (SizeConfig.isTablet) {
      scaleFactor *= 0.8;
    }
    scaleFactor = scaleFactor.clamp(0.8, 1.2);
  }

  return inputHeight * scaleFactor;
}

double getProportionateScreenWidth(double inputWidth) {
  SizeConfig.ensureInitialized();

  double scaleFactor;

  if (SizeConfig.isWeb) {
    // Web-specific scaling
    scaleFactor = SizeConfig.screenWidth / SizeConfig._referenceScreenWidth;
    scaleFactor = scaleFactor.clamp(0.5, 2.0); // More flexible scaling for web
  } else {
    // Mobile scaling
    scaleFactor = SizeConfig.screenWidth / SizeConfig._referenceScreenWidth;
    if (SizeConfig.isTablet) {
      scaleFactor *= 0.8;
    }
    scaleFactor = scaleFactor.clamp(0.8, 1.2);
  }

  return inputWidth * scaleFactor;
}

double getProportionateScreenFont(double inputSize) {
  SizeConfig.ensureInitialized();

  double scaleFactor;

  if (SizeConfig.isWeb) {
    // Web-specific font scaling
    scaleFactor = SizeConfig.screenWidth / SizeConfig._referenceScreenWidth;
    scaleFactor = scaleFactor.clamp(0.8, 1.4); // More flexible for web fonts
  } else {
    // Mobile font scaling
    scaleFactor = SizeConfig.screenWidth / SizeConfig._referenceScreenWidth;
    scaleFactor = scaleFactor.clamp(0.9, 1.1);
  }

  return inputSize * scaleFactor;
}