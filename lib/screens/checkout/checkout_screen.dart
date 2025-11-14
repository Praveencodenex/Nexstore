import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/providers/cart_provider.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/utils/snack_bar.dart';
import '../../../data/providers/address_provider.dart';
import '../../../data/providers/checkout_provider.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/checkout_model.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../address/components/address_bottom_sheet.dart';
import '../components/common_app_bar.dart';
import '../components/custom_button.dart';
import 'components/coupon_bottom_sheet.dart';
import 'components/price_row.dart';

class CheckoutScreen extends StatefulWidget {
  final CartResponse? cartResponse;

  const CheckoutScreen({super.key, this.cartResponse});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isPaymentProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCheckout();
  }

  void _initializeCheckout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CheckoutProvider>().removeSelectedCoupon();
        final addressProvider = context.read<AddressProvider>();
        final selectedAddress = addressProvider.selectedAddress;
        if (selectedAddress != null) {
          context.read<CheckoutProvider>().fetchCheckoutData(
            forceRefresh: true,
            distance: "0",
            addressId: selectedAddress.id,
            cartId: widget.cartResponse?.data.id ?? 0,
          );
        }
      }
    });
  }

  Widget _buildDeliveryBanner() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(10)),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 34,
            margin: EdgeInsets.only(left: getProportionateScreenWidth(16)),
            decoration: const BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(6),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Center(child: SvgPicture.asset(flash, color: kWhiteColor)),
          ),
          Expanded(
            child: Container(
              height: 44,
              margin: EdgeInsets.only(right: getProportionateScreenWidth(16)),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFFBFDED9),
                    const Color(0xFFBFDED9).withAlpha(230), // ~0.9 opacity
                    const Color(0xFFBFDED9).withAlpha(0),   // 0.0 opacity
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Get your groceries delivered in just 15 minutes with zero zec',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(AddressProvider addressProvider) {
    final selectedAddress = addressProvider.selectedAddress;
    if (selectedAddress == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text("No address selected")),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(16),
        vertical: getProportionateScreenWidth(8),
      ),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivering Location',
                  style: bodyStyleStyleB1.copyWith(
                    color: kBlackColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showAddressSelector(
                      context,
                          (address) {
                        addressProvider.setSelectedAddress(address);
                        context.read<CheckoutProvider>().fetchCheckoutData(
                          forceRefresh: true,
                          distance: "0",
                          addressId: address.id,
                          cartId: widget.cartResponse?.data.id ?? 0,
                        );
                        context.read<CheckoutProvider>().removeSelectedCoupon();
                      },
                    );

                  },
                  child: Text(
                    'Change',
                    style: bodyStyleStyleB3SemiBold.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(thickness: 1, color: Colors.grey.shade300),
          Padding(
            padding: EdgeInsets.all(getProportionateScreenWidth(15)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    colorFilter:
                    const ColorFilter.mode(kWhiteColor, BlendMode.srcIn),
                    selectedAddress.type == "home" ? homeAddress : workAddress,
                    height: getProportionateScreenHeight(30),
                    width: getProportionateScreenHeight(30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAddress.name,
                        style: bodyStyleStyleB1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: kBlackColor,
                        ),
                      ),
                      Text(
                        '${selectedAddress.contactName}, ${selectedAddress.contactPhone}',
                        style: bodyStyleStyleB3SemiBold.copyWith(
                          color: kTextColor,
                        ),
                      ),
                      Text(
                        selectedAddress.address,
                        style: bodyStyleStyleB3SemiBold.copyWith(
                          color: kTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsSection(CheckoutProvider checkoutProvider, CheckoutData? data) {
    final selectedCoupon = checkoutProvider.selectedCoupon;
    final amount = data?.amountPayable ?? widget.cartResponse?.meta.totalAmount ?? 0.0;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(16),
            vertical: getProportionateScreenWidth(8),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
              vertical: getProportionateScreenWidth(selectedCoupon != null ? 15 : 2),
            ),
            decoration: BoxDecoration(
              color: selectedCoupon != null ? Colors.white : kPrimaryColorTint,
              border: Border.all(color: selectedCoupon != null ? kPrimaryColor : Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: selectedCoupon != null
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COUPON',
                        style: bodyStyleStyleB1.copyWith(
                          color: kBlackColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(10)),
                      Text(
                        selectedCoupon.title,
                        style: bodyStyleStyleB1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: kBlackColor,
                        ),
                      ),
                      selectedCoupon.type == "first_order"
                          ? Text(
                        'Get extra ${selectedCoupon.discountType == "percent" ? "" : "₹"}${selectedCoupon.discount}${selectedCoupon.discountType == "percent" ? "%" : ""}${selectedCoupon.discountType == "percent" ? " upto Rs ${selectedCoupon.maxDiscount}" : ""} on a cart value of ${selectedCoupon.minPurchase} and above for first order',
                        style: bodyStyleStyleB3.copyWith(color: kTextColor),
                      )
                          : Text(
                        'Get extra ${selectedCoupon.discountType == "percent" ? "" : "₹"}${selectedCoupon.discount}${selectedCoupon.discountType == "percent" ? "%" : ""}${selectedCoupon.discountType == "percent" ? " upto Rs ${selectedCoupon.maxDiscount}" : ""} on a cart value of ${selectedCoupon.minPurchase} and above',
                        style: bodyStyleStyleB3.copyWith(color: kTextColor),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    checkoutProvider.removeSelectedCoupon();
                    final addressProvider = context.read<AddressProvider>();
                    final selectedAddress = addressProvider.selectedAddress;
                    if (selectedAddress != null) {
                      checkoutProvider.fetchCheckoutData(
                        forceRefresh: true,
                        distance: "0",
                        addressId: selectedAddress.id,
                        cartId: widget.cartResponse?.data.id ?? 0,
                      );
                    }
                  },
                  child: Text(
                    'Remove',
                    style: bodyStyleStyleB3.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ) : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Add Coupons',
                      style: bodyStyleStyleB2SemiBold.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(5)),
                    SvgPicture.asset(
                      coupon,
                      height: getProportionateScreenWidth(20),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    showCouponSelector(
                      context,
                          (selectedCoupon) {
                        if (selectedCoupon.minPurchase <= amount) {
                          checkoutProvider.setSelectedCoupon(selectedCoupon);
                          final addressProvider = context.read<AddressProvider>();
                          final selectedAddress = addressProvider.selectedAddress;
                          if (selectedAddress != null) {
                            checkoutProvider.fetchCheckoutData(
                              forceRefresh: true,
                              distance: "0",
                              addressId: selectedAddress.id,
                              couponId: selectedCoupon.id,
                              cartId: widget.cartResponse?.data.id ?? 0,
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
                  child: Text(
                    'Apply',
                    style: bodyStyleStyleB2SemiBold.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetails(CheckoutData? data) {
    return Container(
      margin: EdgeInsets.all(getProportionateScreenWidth(16)),
      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
      decoration: BoxDecoration(
        color: kGreyColorLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: bodyStyleStyleB2SemiBold.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          PriceRow('Total', '₹${data?.total.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          PriceRow('Delivery Charge', '₹${double.parse(data!.deliveryCharge).toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          PriceRow('Handling Charge', '₹${data.handlingCharge.toStringAsFixed(2)}'),
          if (data.couponAmount > 0) ...[
            const SizedBox(height: 8),
            PriceRow('Coupon Discount', '-₹${data.couponAmount.toStringAsFixed(2)}'),
          ],
          const Divider(height: 24),
          PriceRow(
            'Amount Payable',
            '₹${data.amountPayable.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: const AppBarCommon(title: 'Check Out', search: false),
      body: SafeArea(
        child: Consumer3<AddressProvider, CheckoutProvider, CartProvider>(
          builder: (context, addressProvider, checkoutProvider, cartProvider, child) {
            final selectedAddress = addressProvider.selectedAddress;
            if (selectedAddress == null) {
              return const Center(child: Text("Please select a delivery address"));
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: getProportionateScreenHeight(15)),
                        _buildDeliveryBanner(),
                        _buildAddressSection(addressProvider),
                        _buildCouponsSection(checkoutProvider, checkoutProvider.checkoutResponseData?.data),
                        checkoutProvider.checkoutState.state.maybeWhen(
                          success: (checkoutResponse) {
                            if (checkoutResponse.data != null) {
                              return _buildPriceDetails(checkoutResponse.data!);
                            }
                            return const SizedBox.shrink();
                          },
                          failure: (error) {
                            return _buildPriceDetails(checkoutProvider.checkoutResponseData?.data);
                          },

                          orElse: () {
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(16),
                    vertical: getProportionateScreenWidth(10),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, -4),
                        blurRadius: 8,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                  child: CustomButton(
                    btnColor: kPrimaryColor,
                    txtColor: kWhiteColor,
                    text: 'Proceed to Payment',
                    press: () async {

                      NavigationService.instance.navigateTo(
                        RouteNames.paymentScreen,
                        arguments: {'cartId': widget.cartResponse?.data.id ?? 0,'amount':checkoutProvider.checkoutResponseData?.data?.amountPayable??0},
                      );

                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}