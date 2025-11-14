import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? press;
  final Color txtColor;
  final Color btnColor;
  final double height;
  final String? icon;
  final bool isDisabled;
  final bool? borderEnabled;

  const CustomButton({
    this.txtColor = Colors.black,
    this.btnColor = kPrimaryColor,
    super.key,
    this.height = 60,
    required this.text,
    required this.press,
    this.icon,
    this.isDisabled = false,
    this.borderEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDisabled ? btnColor.withOpacity(0.5) : btnColor,
        border: borderEnabled == true
            ? Border.all(color: kPrimaryColor, width: 1) // Use kPrimaryColor
            : null,
        borderRadius: BorderRadius.circular(35),
      ),
      width: double.infinity,
      height: getProportionateScreenHeight(60),
      child: TextButton(
        onPressed: isDisabled ? null : press,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              SvgPicture.asset(
                icon!,
                height: getProportionateScreenWidth(20),
                colorFilter: ColorFilter.mode(
                  isDisabled ? txtColor.withOpacity(0.5) : txtColor,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(10)),
            ],
            Text(
              text,
              style: buttonStyleStyle.copyWith(
                color: isDisabled ? txtColor.withOpacity(0.5) : txtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}