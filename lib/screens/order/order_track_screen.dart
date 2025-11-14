import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import '../../data/providers/order_provider.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../components/common_app_bar.dart';
import 'component/order_track_loader.dart';
import 'order_track_success_screen.dart';

class OrderTrackScreen extends StatefulWidget {
  final int orderId;
  const OrderTrackScreen({super.key, required this.orderId});

  @override
  State<OrderTrackScreen> createState() => _OrderTrackScreenState();
}

class _OrderTrackScreenState extends State<OrderTrackScreen> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchOrderTrackData(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: const AppBarCommon(title: 'Order Status', search: false,cart: true,),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          return provider.orderTrackState.state.when(
            initial: () => const OrderTrackLoader(),
            loading: () => const OrderTrackLoader(),
            success: (orderTrackData) {
              if (orderTrackData.data.orderId == 0) {
                return const NoDataScreen(
                  title: "No Tracking Data",
                  subTitle: "We couldn't find any tracking information for this order",
                  icon: emptyError,
                );
              }
              return OrderTrackSuccessScreen(
                onRefresh: () => _fetchOrderTrackData(forceRefresh: true),
                orderTrackData: orderTrackData,
              );
            },
            failure: (error) => ErrorScreenNew(
              error: error,
              onRetry: () => _fetchOrderTrackData(forceRefresh: true),
            ),
          );
        },
      ),
    );
  }

  Future<void> _fetchOrderTrackData({required bool forceRefresh}) async {
    if (!mounted) return;
    await context.read<OrderProvider>().getOrderTrack(
      forceRefresh: forceRefresh,
      orderId: widget.orderId,
    );
  }
}