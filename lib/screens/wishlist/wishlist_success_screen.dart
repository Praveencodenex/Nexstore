import 'package:flutter/material.dart';
import '../../data/models/wishlist_model.dart';
import '../../utils/constants.dart';
import 'component/wishlist_product_grid.dart';


class WishlistSuccessScreen extends StatelessWidget {
  final WishlistResponse wishlistData;
  final Future<void> Function() onRefresh;

  const WishlistSuccessScreen({
    super.key,
    required this.wishlistData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kPrimaryColor,
      onRefresh: onRefresh,
      child: ProductsWishlistGrid(products: wishlistData.data),
    );
  }
}