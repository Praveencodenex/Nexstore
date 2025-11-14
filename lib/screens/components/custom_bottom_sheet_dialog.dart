import 'package:flutter/material.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../utils/constants.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? positiveButtonText;
  final String? negativeButtonText;
  final VoidCallback? onPositivePressed;
  final VoidCallback? onNegativePressed;
  final bool singleButton;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.subtitle,
    this.positiveButtonText,
    this.negativeButtonText,
    this.onPositivePressed,
    this.onNegativePressed,
    this.singleButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(getProportionateScreenWidth(20)),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: getProportionateScreenWidth(20)),

          Container(
            width: getProportionateScreenWidth(40),
            height: getProportionateScreenWidth(4),
            margin: EdgeInsets.only(bottom: getProportionateScreenWidth(20)),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: getProportionateScreenWidth(10)),
          Text(
            title,
            style: headingH3Style.copyWith(color: kPrimaryColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: getProportionateScreenWidth(20)),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: bodyStyleStyleB2,
          ),
          SizedBox(height: getProportionateScreenWidth(40)),
          Row(
            mainAxisAlignment: singleButton
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceEvenly,
            children: [
              if (!singleButton)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      onNegativePressed?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: EdgeInsets.symmetric(
                        vertical: getProportionateScreenWidth(12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    child: Text(negativeButtonText ?? 'Cancel'),
                  ),
                ),
              if (!singleButton)
                SizedBox(width: getProportionateScreenWidth(8)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onPositivePressed?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: getProportionateScreenWidth(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  child: Text(positiveButtonText ?? 'OK'),
                ),
              ),
            ],
          ),
          SizedBox(height: getProportionateScreenWidth(20)),
        ],
      ),
    );
  }
}