import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';

class AddressTypeButton extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const AddressTypeButton({super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(24),
          vertical: getProportionateScreenHeight(12),
        ),
        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(15),
          color: isSelected ? kPrimaryColor : kWhiteColor,
        ),
        child: Text(
          type,
          style: bodyStyleStyleB2.copyWith(
            color: isSelected ? kWhiteColor : kPrimaryColor,
          ),
        ),
      ),
    );
  }
}