import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import '../../data/providers/order_provider.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../components/common_app_bar.dart';
import 'component/order_loader.dart';
import 'order_details_success_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: const AppBarCommon(title: 'Order Details', search: false,cart: true,),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          return provider.orderDetailsState.state.when(
            initial: () => const OrderTrackingLoader(),
            loading: () => const OrderTrackingLoader(),
            success: (orderData) {
              if (orderData.data.products.isEmpty) {
                return const NoDataScreen(
                  title: "No Order Details",
                  subTitle: "Could not find details for this order",
                  icon: emptyError,
                );
              }
              return OrderDetailsSuccessScreen(
                onRefresh: () => _fetchData(forceRefresh: true),
                orderData: orderData,
              );
            },
            failure: (error) => ErrorScreenNew(
              error: error,
              onRetry: () => provider.fetchOrderDetails(forceRefresh: true, orderId: widget.orderId),
            ),
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData(forceRefresh: true);
  }

  Future<void> _fetchData({required bool forceRefresh}) async {
    if (!mounted) return;
    await context.read<OrderProvider>().fetchOrderDetails(
      forceRefresh: forceRefresh,
      orderId: widget.orderId,
    );
  }
}