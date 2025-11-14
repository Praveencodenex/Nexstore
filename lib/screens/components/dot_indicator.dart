import 'package:flutter/material.dart';
import 'package:thenexstore/utils/size_config.dart';

import '../../../../utils/constants.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    required this.currentPage,
    required this.index,
  });

  final int currentPage;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: currentPage == index ? getProportionateScreenWidth(25) :  getProportionateScreenWidth(25),
      width: 20,
      decoration: BoxDecoration(
        color: currentPage == index ? kBlackColor : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class HorizontalDotIndicator extends StatelessWidget {
  const HorizontalDotIndicator({
    super.key,
    required this.currentPage,
    required this.index,
  });

  final int currentPage;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 5),
      width: currentPage == index ?  getProportionateScreenWidth(25) :  getProportionateScreenWidth(25),
      height: 4,
      decoration: BoxDecoration(
        color: currentPage == index ? kBlackColor : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
