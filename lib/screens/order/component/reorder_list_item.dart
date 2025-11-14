import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/models/reorder_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';

class ReorderItemCard extends StatelessWidget {
  final ReorderProduct product;
  final bool isSelected;
  final ValueChanged<bool?> onSelected;

  const ReorderItemCard({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.totalStock <= 0;

    return Container(
      margin: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
      decoration: BoxDecoration(
        color: kGreyColorLight,
        border: Border.all(color: kGreyColor, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image with out of stock overlay
          Container(
            padding: EdgeInsets.all(getProportionateScreenWidth(8)),
            margin: EdgeInsets.all(getProportionateScreenWidth(8)),
            width: getProportionateScreenWidth(100),
            height: getProportionateScreenHeight(100),
            decoration: BoxDecoration(
              color: kWhiteColor,
              border: Border.all(color: kGreyColor, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: product.image,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Icon(
                      Icons.broken_image,
                      size: getProportionateScreenHeight(60),
                      color: kGreyColorLightMed,
                    ),
                  ),
                ),
                if (isOutOfStock)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                if (isOutOfStock)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        color: kWhiteColor.withOpacity(0.8),
                        padding: EdgeInsets.symmetric(
                          vertical: getProportionateScreenHeight(4),
                          horizontal: getProportionateScreenWidth(8),
                        ),
                        child: Text(
                          'Out Of Stock',
                          style: bodyStyleStyleB3SemiBold.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Product Details
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.title,
                    style: bodyStyleStyleB2SemiBold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: getProportionateScreenHeight(4)),
                  Text(
                    '${product.weight} ${product.unit}',
                    style: bodyStyleStyleB2SemiBold.copyWith(color: kPrimaryColor),
                  ),
                  SizedBox(height: getProportionateScreenHeight(8)),
                  Text(
                    '₹ ${product.price}',
                    style: bodyStyleStyleB2SemiBold,
                  ),
                ],
              ),
            ),
          ),
          // Checkbox
          Padding(
            padding: EdgeInsets.only(right: getProportionateScreenWidth(16)),
            child: SizedBox(
              width: getProportionateScreenWidth(24),
              height: getProportionateScreenWidth(24),
              child: Checkbox(
                value: isSelected,
                activeColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  width: 1.5,
                  color: isOutOfStock ? kDescription : kPrimaryColor,
                ),
                onChanged: isOutOfStock ? null : onSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}