import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';

import '../../../data/models/intro_model.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(getProportionateScreenWidth(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            data.image,
            height: getProportionateScreenHeight(300),
          ),
           SizedBox(height: getProportionateScreenHeight(45)),
          Text(
            data.title,
            style: headingH2Style.copyWith(color: kPrimaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: bodyStyleStyleB1.copyWith(color: kTextColor),
              children: [
                TextSpan(
                  text: _getTextWithoutLastTwoWords(data.description),
                ),
                TextSpan(
                  text: _getLastTwoWords(data.description),
                  style: const TextStyle(color: kAccentTextAccentOrange),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  String _getTextWithoutLastTwoWords(String text) {
    final words = text.split(' ');
    if (words.length <= 2) return '';
    return '${words.sublist(0, words.length - 2).join(' ')} ';
  }

  String _getLastTwoWords(String text) {
    final words = text.split(' ');
    if (words.length <= 2) return text;
    return words.sublist(words.length - 2).join(' ');
  }
}
