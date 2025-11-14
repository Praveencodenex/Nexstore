import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/models/reorder_model.dart';
import 'package:thenexstore/data/providers/order_provider.dart';
import 'package:thenexstore/data/providers/user_provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../../utils/snack_bar.dart';
import '../components/common_app_bar.dart';
import '../components/custom_paginated_listview.dart';
import 'component/order_loader.dart';
import 'component/reorder_list_item.dart';

class ReOrderScreen extends StatefulWidget {
  const ReOrderScreen({super.key});

  @override
  State<ReOrderScreen> createState() => _ReOrderScreenState();
}

class _ReOrderScreenState extends State<ReOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          Provider.of<UserProvider>(context, listen: false).setCurrentIndex(0);
        }
      },
      child: Scaffold(
        backgroundColor: kAppBarColor,
        appBar: const AppBarCommon(title: 'Reorder', search: false,isBottom: true,),
        body: Consumer<OrderProvider>(
          builder: (context, provider, child) {
            return provider.reOrderState.state.when(
              initial: () => const OrderTrackingLoader(),
              loading: () => const OrderTrackingLoader(),
              success: (_) => PaginatedListView<ReorderProduct>(
                items: provider.reorderItems,
                itemBuilder: (context, product) {
                  final isSelected = provider.selectedProducts[product.productId] ?? false;
                  return ReorderItemCard(
                    product: product,
                    isSelected: isSelected,
                    onSelected: (value) {
                      provider.toggleProductSelection(product.productId, value!);
                    },
                  );
                },
                onLoadMore: provider.loadMoreReorders,
                onRefresh: () => provider.fetchReOrderData(forceRefresh: true),
                hasMore: provider.reorderHasMorePages,
                isLoadingMore: provider.reorderIsLoadingMore,
                emptyWidget: const NoDataScreen(
                  title: "No Reorder Items",
                  subTitle: "You don't have any items to reorder",
                  icon: emptyError,
                ),
              ),
              failure: (error) => ErrorScreenNew(
                error: error,
                onRetry: () => provider.fetchReOrderData(forceRefresh: true),
              ),
            );
          },
        ),
        bottomNavigationBar: Consumer<OrderProvider>(
          builder: (context, provider, child) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                child: ElevatedButton(
                  onPressed: provider.getSelectedProductsCount() > 0 ? () => _handleReorder(provider) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(16)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(
                    provider.isLoadingRe ? 'Please Wait' : 'Reorder',
                    style: bodyStyleStyleB1SemiBold.copyWith(color: kWhiteColor),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleReorder(OrderProvider orderProvider) async {
    final selectedProductIds = orderProvider.getSelectedProductIds();

    await orderProvider.submitReorder(selectedProductIds);

    orderProvider.reOrderSubmitState.state.maybeWhen(
      orElse: () {},
      success: (data) {
        SnackBarUtils.showSuccess('${selectedProductIds.length} products added to cart');
        Provider.of<UserProvider>(context, listen: false).setCurrentIndex(3); // Navigate to cart tab
      },
      failure: (error) {
        SnackBarUtils.showError('Failed to reorder these products.');
      },
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
    await context.read<OrderProvider>().fetchReOrderData(forceRefresh: forceRefresh);
  }
}

