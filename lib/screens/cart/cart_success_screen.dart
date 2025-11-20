import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/providers/checkout_provider.dart';
import '../../data/models/checkout_model.dart';
import '../../routes/navigator_services.dart';
import '../../routes/routes_names.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../../utils/snack_bar.dart';
import '../../data/models/cart_model.dart';
import '../../data/providers/address_provider.dart';
import '../../data/providers/cart_provider.dart';
import '../address/components/address_bottom_sheet.dart';
import '../checkout/components/coupon_bottom_sheet.dart';
import '../components/custom_bottom_sheet_dialog.dart';
import '../components/custom_button.dart';
import 'components/cart_list_item.dart';

class CartSuccessScreen extends StatefulWidget {
  final CartResponse cartData;
  final Future<void> Function() onRefresh;

  const CartSuccessScreen({
    super.key,
    required this.cartData,
    required this.onRefresh,
  });

  @override
  State<CartSuccessScreen> createState() => _CartSuccessScreenState();
}

class _CartSuccessScreenState extends State<CartSuccessScreen> {


  Widget _buildCouponsSection(
      CheckoutProvider checkoutProvider, CartProvider cartProvider, CheckoutData? data) {
    final selectedCoupon = checkoutProvider.selectedCoupon;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(6),
            vertical: getProportionateScreenWidth(3),
          ),
          child: selectedCoupon != null
              ? Container(
            margin: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(5),
              vertical: getProportionateScreenWidth(2),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
              vertical: getProportionateScreenWidth(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(getProportionateScreenWidth(8)),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(offer,height: getProportionateScreenFont(25),width: getProportionateScreenWidth(25),)
                      ),
                      SizedBox(width: getProportionateScreenWidth(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedCoupon.title,
                              style: bodyStyleStyleB2SemiBold.copyWith(
                                color: kPrimaryColor,
                              ),
                            ),
                            SizedBox(height: getProportionateScreenWidth(4)),
                            // Updated with highlighted amounts in orange
                            selectedCoupon.type == "first_order"
                                ? RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: bodyStyleStyleB3.copyWith(color: kTextColor),
                                children: [
                                  const TextSpan(text: 'Get extra '),
                                  TextSpan(
                                    text: selectedCoupon.discountType == "percent"
                                        ? '${selectedCoupon.discount}%'
                                        : '₹${selectedCoupon.discount}',
                                    style: const TextStyle(
                                      color: Color(0xFFECA26D),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (selectedCoupon.discountType == "percent")
                                    TextSpan(
                                      children: [
                                        const TextSpan(text: ' upto '),
                                        TextSpan(
                                          text: 'Rs ${selectedCoupon.maxDiscount}',
                                          style: const TextStyle(
                                            color: Color(0xFFECA26D),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const TextSpan(text: ' on a cart value of '),
                                  TextSpan(
                                    text: '₹${selectedCoupon.minPurchase}',
                                    style: const TextStyle(
                                      color: Color(0xFFECA26D),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' and above for first order'),
                                ],
                              ),
                            )
                                : RichText(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: bodyStyleStyleB3.copyWith(color: kTextColor),
                                children: [
                                  const TextSpan(text: 'Get extra '),
                                  TextSpan(
                                    text: selectedCoupon.discountType == "percent"
                                        ? '${selectedCoupon.discount}%'
                                        : '₹${selectedCoupon.discount}',
                                    style: const TextStyle(
                                      color:kAccentTextAccentOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (selectedCoupon.discountType == "percent")
                                    TextSpan(
                                      children: [
                                        const TextSpan(text: ' upto '),
                                        TextSpan(
                                          text: 'Rs ${selectedCoupon.maxDiscount}',
                                          style: const TextStyle(
                                            color:kAccentTextAccentOrange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const TextSpan(text: ' on a cart value of '),
                                  TextSpan(
                                    text: '₹${selectedCoupon.minPurchase}',
                                    style: const TextStyle(
                                      color: kAccentTextAccentOrange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' and above'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Remove button
                TextButton(
                  onPressed: () {
                    checkoutProvider.removeSelectedCoupon();
                    final addressProvider = context.read<AddressProvider>();
                    final selectedAddress = addressProvider.selectedAddress;
                    if (selectedAddress != null) {
                      cartProvider.fetchCartData(
                        forceRefresh: false,
                        addressId: selectedAddress.id,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(8),
                      vertical: getProportionateScreenWidth(4),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Remove',
                    style: bodyStyleStyleB3.copyWith(
                      color: kAccentTextAccentOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          )
              : Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(8)),
            child: InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(12),
                  vertical: getProportionateScreenWidth(12), // Added vertical padding
                ),
                child: Row(
                  children: [
                    Container(
                        padding: EdgeInsets.all(getProportionateScreenWidth(8)),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(offer,height: getProportionateScreenFont(25),width: getProportionateScreenWidth(25),)
                    ),
                    SizedBox(width: getProportionateScreenWidth(10)),
                    // Fixed: Wrapped Column in Expanded to prevent overflow
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Added alignment
                        children: [
                          Text(
                            'View Coupons & Offers',
                            style: bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor),
                          ),
                          Text(
                            'Click here to view all coupons',
                            style: bodyStyleStyleB3Medium.copyWith(color: kTextColor),
                            maxLines: 1, // Added to prevent overflow
                            overflow: TextOverflow.ellipsis, // Added to prevent overflow
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(8)), // Added spacing
                    TextButton(
                      onPressed: () {
                        showCouponSelector(
                          context,
                              (selectedCoupon) {
                            if (selectedCoupon.minPurchase <=
                                widget.cartData.meta.totalAmount) {
                              checkoutProvider.setSelectedCoupon(selectedCoupon);
                              final addressProvider = context.read<AddressProvider>();
                              final selectedAddress = addressProvider.selectedAddress;
                              if (selectedAddress != null) {
                                cartProvider.fetchCartData(
                                  forceRefresh: false,
                                  addressId: selectedAddress.id,
                                  couponId: selectedCoupon.id,
                                );
                              }
                            } else {
                              SnackBarUtils.showError(
                                "Minimum order amount of ₹${selectedCoupon.minPurchase} is required to apply this coupon.",
                              );
                            }
                          },
                          checkoutProvider.selectedCoupon?.code,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: getProportionateScreenWidth(8),
                          vertical: getProportionateScreenWidth(4),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Apply',
                        style: bodyStyleStyleB3.copyWith(
                          color: kAccentTextAccentOrange,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to check if any item in cart is out of stock
  bool _hasOutOfStockItems() {
    for (var item in widget.cartData.data.cartItems) {
      final stock = item.productStock is int
          ? item.productStock as int
          : int.tryParse(item.productStock.toString()) ?? 0;
      final quantity = item.quantity is int
          ? item.quantity as int
          : int.tryParse(item.quantity.toString()) ?? 0;

      if (stock < quantity) {
        return true;
      }
    }
    return false;
  }

  Future<void> _handlePaymentPress(
      BuildContext context,
      AddressProvider addressProvider,
      CheckoutProvider checkoutProvider) async {
    // Check for out of stock items first
    if (_hasOutOfStockItems()) {
      SnackBarUtils.showError(
          "Please remove out of stock items from your cart before proceeding to checkout.");
      return;
    }

    if (widget.cartData.meta.totalAmount < 99) {
      SnackBarUtils.showInfo("Place your order with a minimum spend of ₹99!");
      return;
    }

    final addressState = addressProvider.addressState.state;

    await addressState.maybeWhen(
      success: (addressResponse) async {
        if (addressResponse.data.isEmpty) {
          // Navigate to add address screen
          final result = await NavigationService.instance.navigateTo(
              RouteNames.addEditAddressScreen,
              arguments: {'address': null});

          if (result == true && mounted) {
            await addressProvider.fetchAddressData(forceRefresh: true);
            final defaultAddress = addressProvider.getDefaultAddress();
            if (defaultAddress != null) {
              addressProvider.setSelectedAddress(defaultAddress);
              NavigationService.instance.navigateTo(
                RouteNames.paymentScreen,
                arguments: {
                  'cartId': widget.cartData.data.id,
                  'amount': widget.cartData.meta.amountPayable ?? 0
                },
              );
            }
          }
        } else {
          // Go to checkout if we have an address selected
          final selectedAddress = addressProvider.selectedAddress;
          if (selectedAddress == null) {
            SnackBarUtils.showInfo("Please select a delivery address");
            return;
          }
          NavigationService.instance.navigateTo(
            RouteNames.paymentScreen,
            arguments: {
              'cartId': widget.cartData.data.id,
              'amount': widget.cartData.meta.amountPayable ?? 0
            },
          );
        }
      },
      failure: (error) {
        SnackBarUtils.showError("Unable to load addresses. Please try again.");
      },
      orElse: () {
        SnackBarUtils.showInfo("Please wait while loading address details...");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      body: Consumer3<AddressProvider, CartProvider, CheckoutProvider>(
        builder: (context, addressProvider, cartProvider, checkoutProvider, child) {
          final selectedAddress = addressProvider.selectedAddress;
          final isAddressLoading = addressProvider.addressState.state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );

          final hasAddresses = addressProvider.addressState.state.maybeWhen(
            success: (addressResponse) => addressResponse.data.isNotEmpty,
            orElse: () => false,
          );

          // Check if there are out of stock items
          final hasOutOfStockItems = _hasOutOfStockItems();

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: widget.onRefresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Cart Items List
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final item = widget.cartData.data.cartItems[index];
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: getProportionateScreenWidth(16),
                                vertical: getProportionateScreenWidth(8),
                              ),
                              child: CartItemWidget(
                                item: item,
                                onDelete: () async {
                                  await cartProvider.removeFromCart(item.productId);
                                  cartProvider.deleteState.state.maybeWhen(
                                    success: (response) {
                                      SnackBarUtils.showSuccess(response.message);
                                    },
                                    failure: (error) {
                                      SnackBarUtils.showError(error.message);
                                    },
                                    orElse: () {},
                                  );
                                },
                                onQuantityChanged: (quantity) async {
                                  if (quantity <= 0) {
                                    await showModalBottomSheet<bool>(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder: (BuildContext context) {
                                        return CustomBottomSheet(
                                          title: 'Are you sure you want to remove this item from your cart?',
                                          subtitle: 'This action cannot be undone',
                                          positiveButtonText: 'Delete',
                                          negativeButtonText: 'Cancel',
                                          onPositivePressed: () async {
                                            await cartProvider.removeFromCart(item.productId);
                                            if (context.mounted) {
                                              cartProvider.deleteState.state.maybeWhen(
                                                success: (response) {
                                                  SnackBarUtils.showSuccess(response.message);
                                                },
                                                failure: (error) {
                                                  SnackBarUtils.showError(error.message);
                                                },
                                                orElse: () {},
                                              );
                                            }
                                          },
                                          onNegativePressed: () {},
                                        );
                                      },
                                    );
                                  } else {
                                    await cartProvider.updateToCart(item.productId, quantity);
                                    if (context.mounted) {
                                      cartProvider.updateState.state.maybeWhen(
                                        success: (response) {
                                          SnackBarUtils.showSuccess(response.message);
                                        },
                                        failure: (error) {
                                          SnackBarUtils.showError(error.message);
                                        },
                                        orElse: () {},
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                          childCount: widget.cartData.data.cartItems.length,
                        ),
                      ),

                      // Coupon Section (below cart items)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: getProportionateScreenHeight(8),
                          ),
                          child: _buildCouponsSection(
                            checkoutProvider,
                            cartProvider,
                            null,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(16),
                            vertical: getProportionateScreenWidth(4),
                          ),
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                      ),


                      // Points Section (below coupons)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(16),

                          ),
                          child: Container(
                            padding: EdgeInsets.all(getProportionateScreenWidth(12)),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(getProportionateScreenWidth(8)),
                                  decoration: BoxDecoration(
                                    color: kWhiteColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: SvgPicture.asset(info,height: getProportionateScreenFont(25),width: getProportionateScreenWidth(25),)

                                ),
                                SizedBox(width: getProportionateScreenWidth(12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'Free delivery for orders',
                                          style: bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor),
                                          children: [
                                            TextSpan(
                                              text: ' ₹300',
                                              style: bodyStyleStyleB2Bold.copyWith(color: kAccentTextAccentOrange),
                                            ),
                                            TextSpan(
                                              text: ' and above',
                                              style: bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: getProportionateScreenHeight(4)),
                                      Text(
                                        'Add more item to get extra rewards!',
                                        style: bodyStyleStyleB3.copyWith(
                                          color: Colors.black54,
                                          fontSize: getProportionateScreenFont(11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(16),
                            vertical: getProportionateScreenWidth(4),
                          ),
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                      ),

                      // Address Section (below points)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(16),
                          ),
                          child: InkWell(
                            onTap: isAddressLoading
                                ? null
                                : (hasAddresses
                                ? () {
                              showAddressSelector(
                                context,
                                    (address) {
                                  addressProvider.setSelectedAddress(address);
                                },
                              );
                            }
                                : () {
                              NavigationService.instance.navigateTo(
                                  RouteNames.addEditAddressScreen,
                                  arguments: {'address': null});
                            }),
                            child: Container(
                              padding: EdgeInsets.all(getProportionateScreenWidth(12)),

                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(getProportionateScreenWidth(8)),
                                    decoration: BoxDecoration(
                                      color: kWhiteColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: SvgPicture.asset(address,height: getProportionateScreenFont(25),width: getProportionateScreenWidth(25),)
                                  ),
                                  SizedBox(width: getProportionateScreenWidth(12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isAddressLoading
                                              ? 'Loading Address...'
                                              : (selectedAddress?.name ?? 'Add Delivery Address'),
                                          style: bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor),
                                        ),
                                        SizedBox(height: getProportionateScreenHeight(4)),
                                        if (selectedAddress != null && !isAddressLoading)
                                          Text(
                                            '${selectedAddress.contactName}, ${selectedAddress.contactPhone}',
                                            style: bodyStyleStyleB3.copyWith(
                                              color: Colors.black54,
                                              fontSize: getProportionateScreenFont(11),
                                            ),
                                          )
                                        else if (!isAddressLoading)
                                          Text(
                                            'Tap to select delivery address',
                                            style: bodyStyleStyleB3.copyWith(
                                              color: Colors.black54,
                                              fontSize: getProportionateScreenFont(11),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (!isAddressLoading)
                                    Icon(
                                      Icons.chevron_right,
                                      color: kAccentTextAccentOrange,
                                      size: getProportionateScreenFont(24),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom padding
                      SliverToBoxAdapter(
                        child: SizedBox(height: getProportionateScreenHeight(16)),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Payment Section (Fixed at bottom)
              Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                decoration: const BoxDecoration(
                  color: Colors.white,

                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Estimated Total Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Total',
                          style: bodyStyleStyleB1Bold.copyWith(color: kPrimaryColor),
                        ),
                        Row(
                          children: [
                            Text(
                              '₹${widget.cartData.meta.amountPayable.toStringAsFixed(2)}',
                              style: bodyStyleStyleB1Bold.copyWith(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: getProportionateScreenFont(18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: getProportionateScreenHeight(16)),

                    // Checkout Button
                    CustomButton(
                      text: isAddressLoading
                          ? 'Loading Address...'
                          : hasOutOfStockItems
                          ? 'Remove out of stock items'
                          : 'Go to checkout',
                      press: (isAddressLoading || selectedAddress == null || hasOutOfStockItems)
                          ? () {
                        if (hasOutOfStockItems) {
                          SnackBarUtils.showInfo(
                              "Please remove out of stock items from your cart");
                        } else {
                          SnackBarUtils.showInfo("Please add an address");
                        }
                      }
                          : () => _handlePaymentPress(context, addressProvider, checkoutProvider),
                      txtColor: kWhiteColor,
                      btnColor: hasOutOfStockItems ? Colors.grey : kPrimaryColor,
                    ),
                    SizedBox(height: getProportionateScreenHeight(16)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}