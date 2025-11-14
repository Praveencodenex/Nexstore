import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/models/cart_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDelete;
  final Function(int) onQuantityChanged;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onQuantityChanged,
  });

  // Generate a random light pastel color
  Color _getRandomLightColor() {
    final random = Random(item.name.hashCode); // Use item name for consistent color per item
    final colors = [
      const Color(0xFFE8F5E9), // Light green
      const Color(0xFFF3EFCB), // Light yellow
      const Color(0xFFECDCC6), // Light orange
      const Color(0xFFEEE7EF), // Light purple
      const Color(0xFFE1F5FE), // Light blue
      const Color(0xFFEFE1E6), // Light pink
      const Color(0xFFF1F8E9), // Light lime
      const Color(0xFFE0F2F1), // Light teal
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(8),
        vertical: getProportionateScreenWidth(8),
      ),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Image with random light background
              Container(
                width: getProportionateScreenWidth(95),
                height: getProportionateScreenWidth(110),
                decoration: BoxDecoration(
                  color: _getRandomLightColor(),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(getProportionateScreenWidth(10)),
                child: CachedNetworkImage(
                  imageUrl: item.image ?? "",
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image,
                    size: getProportionateScreenHeight(30),
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(12)),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Padding(
                      padding: EdgeInsets.only(right: getProportionateScreenWidth(30)),
                      child: Text(
                        item.name,
                        style: bodyStyleStyleB1Bold.copyWith(fontWeight: FontWeight.w800,
                          color: kPrimaryColor,fontSize: getProportionateScreenHeight(17)
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenWidth(3)),

                    // Weight
                    Text(
                      "${item.weight}${item.unit}",
                      style: bodyStyleStyleB3SemiBold.copyWith(color: Colors.grey[600]),
                    ),
                    SizedBox(height: getProportionateScreenWidth(8)),

                    // Price and Quantity Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Row(
                          children: [
                            Text(
                              '₹${item.price}',
                              style: bodyStyleStyleB1Bold.copyWith(
                                color: kAccentTextAccentOrange,
                                fontWeight: FontWeight.w900,
                                fontSize: getProportionateScreenFont(20),
                              ),
                            ),
                            if (item.discount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                  '₹${item.originalPrice.toInt()}',
                                  style: bodyStyleStyleB2.copyWith(color: Colors.grey[500],decoration: TextDecoration.lineThrough,)
                              ),
                            ]
                          ],
                        ),

                        // Quantity Controls in Grey Container
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(4),
                            vertical: getProportionateScreenWidth(4),
                          ),
                          decoration: BoxDecoration(
                            color: kAppBarColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              // Minus Button
                              InkWell(
                                onTap: () {
                                    onQuantityChanged(item.quantity - 1);
                                },
                                child: Container(
                                  width: getProportionateScreenWidth(26),
                                  height: getProportionateScreenWidth(26),
                                  decoration: const BoxDecoration(
                                    color: kWhiteColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: getProportionateScreenFont(16),
                                    color: kBlackColor,
                                  ),
                                ),
                              ),

                              // Quantity
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: getProportionateScreenWidth(12),
                                ),
                                child: Text(
                                  item.quantity.toString(),
                                  style: TextStyle(
                                    fontSize: getProportionateScreenFont(14),
                                    fontWeight: FontWeight.w600,
                                    color: kBlackColor,
                                  ),
                                ),
                              ),

                              // Plus Button
                              InkWell(
                                onTap: () => onQuantityChanged(item.quantity + 1),
                                child: Container(
                                  width: getProportionateScreenWidth(26),
                                  height: getProportionateScreenWidth(26),
                                  decoration: const BoxDecoration(
                                    color: kPrimaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: getProportionateScreenFont(16),
                                    color: kWhiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Delete Button (X icon) - Positioned at top right
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(4)),
                child: Icon(
                  Icons.close,
                  size: getProportionateScreenFont(22),
                  color: kBlackColor,

                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}