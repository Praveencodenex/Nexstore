import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';

import '../../utils/assets.dart';

class NoDataScreen extends StatelessWidget {
  final String title;
  final String subTitle;
  final String icon;
  final String? param;

  const NoDataScreen({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
    this.param
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(20)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: getProportionateScreenHeight(100)),
          SvgPicture.asset(
            emptyError,
            height: getProportionateScreenWidth(150),
            width: getProportionateScreenHeight(150),
          ),

          SizedBox(height: getProportionateScreenHeight(25)),
          Text(
            title,
            style: headingH3Style,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: getProportionateScreenHeight(8)),
          Text(
            subTitle,
            style: bodyStyleStyleB2,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }


}