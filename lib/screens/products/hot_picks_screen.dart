import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/home_model.dart';
import '../../data/providers/product_provider.dart';
import '../../data/providers/user_provider.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../../utils/assets.dart';
import '../components/common_app_bar.dart';
import '../components/custom_pagination_gridview.dart';
import '../components/product_list_loader.dart';
import '../home/components/product_card.dart';

class HotPicksScreen extends StatefulWidget {
  const HotPicksScreen({super.key});

  @override
  State<HotPicksScreen> createState() => _HotPicksScreenState();
}

class _HotPicksScreenState extends State<HotPicksScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchData(forceRefresh: false);
      });
    }
  }

  Future<void> _fetchData({required bool forceRefresh}) async {
    if (!mounted) return;
    await context.read<ProductsDataProvider>().fetchHotPickData(forceRefresh: forceRefresh);
  }

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
        backgroundColor: Colors.white, // Replace kWhiteColor with Colors.white
        appBar: const CommonAppBar(title: 'Hot Picks'),
        body: Consumer<ProductsDataProvider>(
          builder: (context, provider, child) {
            return provider.hotPickState.state.when(
              initial: () => const ProductLoader(),
              loading: () => const ProductLoader(),
              success: (hotPickData) {
                return PaginatedGridView<Product>(
                  items: provider.hotPickProducts,
                  itemBuilder: (context, product) => ProductCard(product: product),
                  onLoadMore: () => provider.loadMoreHotPickData(),
                  onRefresh: () => _fetchData(forceRefresh: true),
                  hasMore: provider.hotPickHasMorePages,
                  isLoadingMore: provider.hotPickIsLoadingMore,
                  emptyWidget: const NoDataScreen(
                    title: "Hot Picks Screen",
                    subTitle: "No hot picks found",
                    icon: emptyError,
                  ),
                );
              },
              failure: (error) => ErrorScreenNew(
                error: error,
                onRetry: () => _fetchData(forceRefresh: true),
              ),
            );
          },
        ),
      ),
    );
  }
}