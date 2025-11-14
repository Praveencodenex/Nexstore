import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import '../../data/providers/notification_provider.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../components/common_app_bar.dart';
import 'components/notification_loader.dart';
import 'notification_success_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: const AppBarCommon(title: 'Notification',search: false,cart: true,),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return provider.notificationState.state.when(
            initial: () => const NotificationLoader(),
            loading: () => const NotificationLoader(),
            success: (notificationData) {
              if (notificationData.data.notifications.isEmpty) {
                return const NoDataScreen(
                  title: "No Notifications",
                  subTitle: "You don't have any notifications yet",
                  icon: emptyError,
                );
              }
              return NotificationSuccessScreen(
                onRefresh: ()=>_fetchData(forceRefresh: true),
                notificationData: notificationData,
              );
            },
            failure: (error) => ErrorScreenNew(
              error: error,
              onRetry: () => provider.fetchHomeData(forceRefresh: true),
            ),
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData(forceRefresh: false);
  }

  Future<void> _fetchData({required bool forceRefresh}) async {
    if (!mounted) return;
    await context.read<NotificationProvider>().fetchHomeData(
      forceRefresh: forceRefresh,
    );
  }
}