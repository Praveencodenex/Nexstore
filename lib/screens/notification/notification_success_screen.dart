import 'package:flutter/material.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import '../../data/models/notification_model.dart';
import '../../utils/constants.dart';
import 'components/notification_item_card.dart';

class NotificationSuccessScreen extends StatelessWidget {
  final NotificationResponse notificationData;
  final Future<void> Function() onRefresh;

  const NotificationSuccessScreen({
    super.key,
    required this.notificationData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kPrimaryColor,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notificationData.data.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationData.data.notifications[index];
          return NotificationItemCard(
            notification: notification,
            onPressed: () {
               manageNotification(notification.type);
            },
          );
        },
      ),
    );
  }
  manageNotification( String type){
    if(type=="order"){
      NavigationService.instance.navigateTo(RouteNames.orderScreen,arguments: {'backNeeded': true});
    }else{
      NavigationService.instance.pushNamedAndClearStack(RouteNames.customBottomNavBar);
    }
  }
}