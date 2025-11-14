import 'package:flutter/material.dart';
import 'package:thenexstore/screens/wishlist/component/product_wishlist_card.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../../data/models/home_model.dart';

class ProductsWishlistGrid extends StatelessWidget {
  final List<Product> products;

  const ProductsWishlistGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding:  EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16),vertical: getProportionateScreenWidth(16)),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductWishlistCard(product: products[index]);
        },
      ),
    );
  }
}