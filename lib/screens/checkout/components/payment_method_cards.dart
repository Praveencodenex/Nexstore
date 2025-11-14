
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';

class PaymentMethodCard extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        padding:  EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16), vertical: getProportionateScreenHeight(14)),
        child: Row(
          children: [
            Container(
              width: getProportionateScreenHeight(40),
              height: getProportionateScreenHeight(40),
              alignment: Alignment.center,

              child: SvgPicture.asset(
                icon,
                color: kPrimaryColor,
                height: 24,
              ),
            ),
             SizedBox(width:  getProportionateScreenWidth(16)),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black54,
              size: 25,
            ),
          ],
        ),
      ),
    );
  }
}