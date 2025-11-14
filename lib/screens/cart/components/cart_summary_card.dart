import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';

import '../../../data/providers/cart_provider.dart';
import '../../../routes/navigator_services.dart';
import '../../../routes/routes_names.dart';

class CartSummaryCard extends StatelessWidget {

  const CartSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final cartData = cartProvider.cartState.data;
        final cartItems = cartData?.data.cartItems ?? [];

        // Hide the card if the cart is empty
        if (cartItems.isEmpty) {
          return const SizedBox.shrink();
        }

        final firstItemImage = cartItems[0].image; // Image of the first cart item
        final totalItems = cartData?.meta.totalItems ?? 0;

        return Container(
          height: getProportionateScreenHeight(90), // Fixed height for the card
          decoration: const BoxDecoration(
            color: Colors.white, // White background
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
            children: [
              // Stack for product image and multiple items indicator
              SizedBox(
                width: 60, // Give enough width for the stacked effect
                height: 50,
                child: Stack(
                  children: [
                    // Background rectangles for multiple items (positioned behind)
                    if (totalItems > 1) ...[

                      Positioned(
                        left: 0,
                        top: 6,
                        child: Container(
                          width: 50,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                      ),
                      // Second background rectangle (middle)
                      Positioned(
                        left: 5,
                        top: 3,
                        child: Container(
                          width: 50,
                          height: 47,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                          ),
                        ),
                      ),
                    ],
                    Positioned(
                      left: totalItems > 1 ? 10 : 0,
                      top: 0,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: CachedNetworkImage(
                            imageUrl: firstItemImage,
                            fit: BoxFit.cover,
                            errorWidget: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: getProportionateScreenWidth(5)), // Spacing between image and text
              // Cart item count
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total: ',
                        style: bodyStyleStyleB1Bold.copyWith(
                          color: kBlackColor,
                        ),
                      ), Text(
                        '₹${double.parse(cartData!.meta.totalAmount.toStringAsFixed(2)).toString()}',
                        style: bodyStyleStyleB1Bold.copyWith(
                          color: kAccentTextAccentOrange,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$totalItems item${totalItems != 1 ? 's' : ''}',
                    style: bodyStyleStyleB2Bold.copyWith(
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
              const Spacer(), // Pushes the button to the right
              // Green "Go to Cart" button
              SizedBox(height: getProportionateScreenHeight(45),
                child: ElevatedButton(
                  onPressed: () {
                    NavigationService.instance.navigateTo(RouteNames.cartScreen,arguments: {'isBottom':false});
                  },
                
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor, // Green background
                    foregroundColor: Colors.white, // White text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  child:  Text('Go to Cart',style: bodyStyleStyleB2SemiBold.copyWith(color: kWhiteColor,),),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}