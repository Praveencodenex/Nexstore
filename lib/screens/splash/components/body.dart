// body.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';

class SplashScreenBody extends StatelessWidget {
  const SplashScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: kPrimaryColor,
      width: screenWidth,  // Use full screen width
      height: screenHeight,  // Use full screen height
      child: Center(  // Center widget for better alignment
        child: SizedBox(
          width: getProportionateScreenWidth(200),
          height: getProportionateScreenHeight(200),
          child: Image.asset(
            splash,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}