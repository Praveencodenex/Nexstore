import 'dart:math';
import 'package:flutter/material.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../../data/models/notification_model.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';

class NotificationItemCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onPressed;

  const NotificationItemCard({
    super.key,
    required this.notification,
    required this.onPressed,
  });

  // Generate a random light pastel color (same as order item)
  Color _getRandomLightColor() {
    final random = Random(notification.title.hashCode);
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
            // Notification Icon with random light background
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

            // Notification Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    notification.title,
                    style: bodyStyleStyleB1Bold.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: getProportionateScreenHeight(17),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: getProportionateScreenWidth(3)),

                  // Description
                  Text(
                    notification.description,
                    style: bodyStyleStyleB3SemiBold.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: getProportionateScreenWidth(10)),

                  // Time
                  Text(
                    _formatTime(notification.createdAt),
                    style: bodyStyleStyleB3SemiBold.copyWith(
                      color: kAccentTextAccentOrange,
                    ),
                  ),

                  // View/Shop Now Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                          onTap: onPressed,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                notification.type == "offer" ? 'Shop Now' : 'View',
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

  String _formatTime(String dateTime) {
    try {
      if (dateTime.isEmpty) return '';

      // Parse the date string
      DateTime parsedDate = DateTime.parse(dateTime);
      DateTime now = DateTime.now();

      // Calculate difference
      Duration difference = now.difference(parsedDate);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      // If parsing fails, try to extract time from string or return default
      if (dateTime.contains(':')) {
        return dateTime.split(' ').last;
      }
      return '10:00 Am'; // Default fallback
    }
  }
}