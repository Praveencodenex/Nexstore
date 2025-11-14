import 'package:flutter/material.dart';
import 'package:thenexstore/utils/constants.dart';

class PriceRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isTotal;

  const PriceRow(
      this.label,
      this.amount, {super.key,
        this.isTotal = false,
      });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:bodyStyleStyleB1.copyWith( fontSize: isTotal ? 16 : 14,color: kBlackColor,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,)

        ),
        Text(
          amount,
          style: bodyStyleStyleB2SemiBold.copyWith(fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,)
        ),
      ],
    );
  }
}