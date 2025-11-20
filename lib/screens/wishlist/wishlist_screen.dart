import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/screens/wishlist/wishlist_success_screen.dart';
import '../../data/providers/wishlist_provider.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../components/common_app_bar.dart';
import '../components/product_list_loader.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: const AppBarCommon(title: 'Wishlist',cart: true,isBottom: true,),
      body: Consumer<WishListProvider>(
        builder: (context, provider, child) {
          return provider.wishState.state.when(
            initial: () => const ProductLoader(),
            loading: () => const ProductLoader(),
            success: (wishData) {
              if (wishData.data.isEmpty) {
                return const NoDataScreen(
                  title: "Empty Wishlist",
                  subTitle: "No items in your wishlist yet",
                  icon: emptyError,
                );
              }
              return WishlistSuccessScreen(
                onRefresh: ()=>_fetchData(forceRefresh: true),
                wishlistData: wishData,
              );
            },
            failure: (error) => ErrorScreenNew(
              error: error,
              onRetry: () => provider.fetchWishlistData(forceRefresh: true),
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
    await context.read<WishListProvider>().fetchWishlistData(
      forceRefresh: forceRefresh,
    );
  }

}