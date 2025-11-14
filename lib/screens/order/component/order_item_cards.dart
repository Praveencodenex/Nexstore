import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../../data/models/order_model.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';

class OrderItemCard extends StatelessWidget {
  final OrderListData order;
  final VoidCallback onPressed;

  const OrderItemCard({
    super.key,
    required this.order,
    required this.onPressed,
  });

  // Generate a random light pastel color (same as cart item)
  Color _getRandomLightColor() {
    final random = Random(order.id.hashCode);
    final colors = [
      const Color(0xFFE8F5E9), // Light green
      const Color(0xFFFFF9C4), // Light yellow
      const Color(0xFFF6E2C5), // Light orange
      const Color(0xFFF3E5F5), // Light purple
      const Color(0xFFE1F5FE), // Light blue
      const Color(0xFFFCE4EC), // Light pink
      const Color(0xFFF1F8E9), // Light lime
      const Color(0xFFE0F2F1), // Light teal
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {


    return Container(
      margin: EdgeInsets.only(
        bottom: getProportionateScreenWidth(16),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(8),
        vertical: getProportionateScreenWidth(8),
      ),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Row(
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
              child: Image.asset(
                orderItem,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(12)),

            // Order Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order ID
                  Row(
                    children: [
                      Text(
                        'Order ',
                        style: bodyStyleStyleB1Bold.copyWith(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: getProportionateScreenHeight(17),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ), Text(
                        '#ORD${order.id}',
                        style: bodyStyleStyleB1Bold.copyWith(
                          color: kAccentTextAccentOrange,
                          fontWeight: FontWeight.w800,
                          fontSize: getProportionateScreenHeight(17),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: getProportionateScreenWidth(3)),

                  // Items count
                  Text(
                    'Items: ${order.items ?? "N/A"}',
                    style: bodyStyleStyleB3SemiBold.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: getProportionateScreenWidth(3)),

                  // Order Date
                  Text(
                    'Ordered: ${order.date ?? "N/A"}',
                    style: bodyStyleStyleB3SemiBold.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: getProportionateScreenWidth(8)),

                  // Status and Track Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Status
                      if (order.status != null)
                        Flexible(
                          child: Text(
                            order.status.isNotEmpty
                                ? '${order.status[0].toUpperCase()}${order.status.substring(1)}'
                                .replaceAll('_', ' ')
                                : order.status.replaceAll('_', ' '),
                            style: bodyStyleStyleB2.copyWith(
                              color: kBlackColor,
                              fontSize: getProportionateScreenFont(14),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      // Track Button (only for non-delivered/cancelled orders)
                      if (order.status.toLowerCase() != 'delivered' &&
                          order.status.toLowerCase() != 'cancelled')
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(12),
                            vertical: getProportionateScreenWidth(8),
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: InkWell(
                            onTap: () {
                              NavigationService.instance.navigateTo(
                                RouteNames.orderTrackScreen,
                                arguments: {'orderId': order.id},
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Track',
                                  style: bodyStyleStyleB3SemiBold.copyWith(
                                    color: kWhiteColor,
                                    fontSize: getProportionateScreenFont(13),
                                  ),
                                ),
                                SizedBox(width: getProportionateScreenWidth(4)),
                                Icon(
                                  Icons.arrow_forward,
                                  size: getProportionateScreenFont(14),
                                  color: kWhiteColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}