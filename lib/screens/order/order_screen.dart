import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import '../../data/models/order_model.dart';
import '../../data/providers/order_provider.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../components/common_app_bar.dart';
import '../components/custom_paginated_listview.dart';
import 'component/order_loader.dart';
import 'component/order_item_cards.dart';
import '../../routes/navigator_services.dart';
import '../../routes/routes_names.dart';

class OrderScreen extends StatefulWidget {
  final bool backNeeded;
  const OrderScreen({super.key, required this.backNeeded});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar:  AppBarCommon(title: 'Your Order', search: false,cart: true,isBottom: true,backNeeded: widget.backNeeded,),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          return provider.orderState.state.when(
            initial: () => const OrderTrackingLoader(),
            loading: () => const OrderTrackingLoader(),
            success: (_) => PaginatedListView<OrderListData>(
              items: provider.orders,
              itemBuilder: (context, order) => OrderItemCard(
                order: order,
                onPressed: () {
                  NavigationService.instance.navigateTo(
                    RouteNames.orderDetailsScreen,
                    arguments: {'orderId': order.id},
                  );
                },
              ),
              onLoadMore: provider.loadMoreOrders,
              onRefresh: () => provider.fetchOrderData(forceRefresh: true),
              hasMore: provider.hasMorePages,
              isLoadingMore: provider.isLoadingMore,
              emptyWidget: const NoDataScreen(
                title: "No Orders",
                subTitle: "You haven't placed any orders yet",
                icon: emptyError,
              ),
            ),
            failure: (error) => ErrorScreenNew(
              error: error,
              onRetry: () => provider.fetchOrderData(forceRefresh: true),
            ),
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(forceRefresh: false);
    });
  }

  Future<void> _fetchData({required bool forceRefresh}) async {
    if (!mounted) return;
    await context.read<OrderProvider>().fetchOrderData(forceRefresh: forceRefresh);
  }
}