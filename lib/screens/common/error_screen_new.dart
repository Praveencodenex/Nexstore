// error_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/helper/network_exception.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../components/custom_button.dart';


class ErrorScreenNew extends StatelessWidget {
  final NetworkException error;
  final VoidCallback? onRetry;

  const ErrorScreenNew({
    super.key,
    required this.error,
    this.onRetry,
  });

  String get _getIcon {
    if (error.statusCode == -1) {
      return noNetworkError; // No internet
    } else if (error.statusCode == 408) {
      return timeOutError; // Timeout
    } else {
      return commonError; // Default error icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(26)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SvgPicture.asset(
              _getIcon,
              height: getProportionateScreenHeight(160),
              width: getProportionateScreenWidth(100),
            ),
            SizedBox(height: getProportionateScreenWidth(20)),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: bodyStyleStyleB3.copyWith(color: kBlackColor),
            ),
            if (onRetry != null)...[
              SizedBox(height: getProportionateScreenWidth(30)),
              CustomButton(text: 'Try Again',
                btnColor: kPrimaryColor,
                press: onRetry,
                txtColor: kWhiteColor,
              )
            ],

          ],
        ),
      ),
    );
  }
}