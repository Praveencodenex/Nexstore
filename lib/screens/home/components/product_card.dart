import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../../data/models/home_model.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/wishlist_provider.dart';
import '../../../utils/snack_bar.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        cartProvider.updateProductInCart(product);
        final quantityNotifier =
        cartProvider.getQuantityNotifier(product.id, product.inCart);

        return GestureDetector(
          onTap: () {
            NavigationService.instance.navigateTo(
              RouteNames.productDetailScreen,
              arguments: {'product': product},
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 15, bottom: 5),
                          child: CachedNetworkImage(
                            imageUrl: product.featuredImage,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_outlined,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),

                      if (product.totalStock <= 0)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.35),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child:  Center(
                              child: Container(color: kWhiteColor,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    'Out Of Stock',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                   /*   if (product.discount > 0)
                        Positioned(
                          top: 12,
                          left: -1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: kAccentTextAccentOrange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discount.toInt()}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),*/

                      Positioned(
                        top: 12,
                        right: 10,
                        child: Consumer<WishListProvider>(
                          builder: (context, wishlistProvider, _) {
                            return Container(
                              width: 35,
                              height: 35,
                              decoration: const BoxDecoration(
                                color: kAppBarColor,
                                shape: BoxShape.circle,

                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                iconSize: 26,
                                icon: Icon(
                                  product.inWishlist
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: product.inWishlist
                                      ? Colors.red
                                      : Colors.grey[700],
                                ),
                                onPressed: wishlistProvider
                                    .isProductLoading(product.id)
                                    ? null
                                    : () async {
                                  if (product.inWishlist) {
                                    await wishlistProvider
                                        .removeFromWishlist(
                                        product.id, context);
                                  } else {
                                    await wishlistProvider.addToWishlist(
                                        product.id, context);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Details Section
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10,top: 0, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seller info
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.brand??"No Brand",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        ],
                      ),

                      // Product name
                      Text(
                        product.name,
                        style: bodyStyleStyleB2Bold.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Price and button
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Price Section (always visible)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                      '₹${product.sellingPrice.toInt()}',
                                      style: headingH3Style.copyWith(color: kAccentTextAccentOrange,fontWeight: FontWeight.w800)
                                  ),
                                  if (product.discount > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                        '₹${product.price.toInt()}',
                                        style: bodyStyleStyleB3Medium.copyWith(color: Colors.grey[500],decoration: TextDecoration.lineThrough,)
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                product.weight,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          // Cart Button (positioned at right)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: ValueListenableBuilder<int>(
                              valueListenable: quantityNotifier,
                              builder: (context, quantity, _) {
                                if (quantity == 0) {
                                  return SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: ElevatedButton(
                                      onPressed: cartProvider.isProductLoading(product.id) ||
                                          product.totalStock <= 0
                                          ? null
                                          : () async {
                                        await cartProvider.addToCart(product.id, 1);
                                        if (context.mounted) {
                                          cartProvider.addState.state.maybeWhen(
                                              success: (response) {
                                                SnackBarUtils.showSuccess(response.message);
                                              },
                                              failure: (error) {
                                                SnackBarUtils.showError(error.message);
                                              },
                                              orElse: () {});
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        foregroundColor: Colors.white,
                                        shape: const CircleBorder(),
                                        padding: EdgeInsets.zero,
                                        elevation: 0,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: kWhiteColor,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kAppBarColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Minus Button
                                        InkWell(
                                          onTap: cartProvider.isProductLoading(product.id)
                                              ? null
                                              : () async {
                                            if (quantity > 1) {
                                              await cartProvider.updateToCart(
                                                  product.id, quantity - 1);
                                              if (context.mounted) {
                                                cartProvider.updateState.state.maybeWhen(
                                                    success: (response) {
                                                      SnackBarUtils.showSuccess(response.message);
                                                    },
                                                    failure: (error) {
                                                      SnackBarUtils.showError(error.message);
                                                    },
                                                    orElse: () {});
                                              }
                                            } else {
                                              await cartProvider.removeFromCart(product.id);
                                              if (context.mounted) {
                                                cartProvider.deleteState.state.maybeWhen(
                                                    success: (response) {
                                                      SnackBarUtils.showSuccess(response.message);
                                                    },
                                                    failure: (error) {
                                                      SnackBarUtils.showError(error.message);
                                                    },
                                                    orElse: () {});
                                              }
                                            }
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: const BoxDecoration(
                                              color: kWhiteColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 18,
                                              color: kBlackColor,
                                            ),
                                          ),
                                        ),

                                        // Quantity
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text(
                                            quantity.toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: kBlackColor,
                                            ),
                                          ),
                                        ),

                                        // Plus Button
                                        InkWell(
                                          onTap: cartProvider.isProductLoading(product.id) ||
                                              product.totalStock == 0
                                              ? null
                                              : () async {
                                            if (quantity < product.maximumOrderQuantity) {
                                              await cartProvider.updateToCart(
                                                  product.id, quantity + 1);
                                              if (context.mounted) {
                                                cartProvider.updateState.state.maybeWhen(
                                                    success: (response) {
                                                      SnackBarUtils.showSuccess(response.message);
                                                    },
                                                    failure: (error) {
                                                      SnackBarUtils.showError(error.message);
                                                    },
                                                    orElse: () {});
                                              }
                                            } else {
                                              SnackBarUtils.showInfo(
                                                  'Maximum order quantity reached');
                                            }
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: const BoxDecoration(
                                              color: kPrimaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 18,
                                              color: kWhiteColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}