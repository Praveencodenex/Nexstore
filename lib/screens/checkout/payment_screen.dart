import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/models/cart_model.dart';
import 'package:thenexstore/data/providers/address_provider.dart';
import 'package:thenexstore/data/providers/cart_provider.dart';
import 'package:thenexstore/data/providers/checkout_provider.dart';
import 'package:thenexstore/data/providers/order_provider.dart';
import 'package:thenexstore/data/providers/payment_provider.dart';
import 'package:thenexstore/screens/components/common_app_bar.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../data/services/payment_service.dart';
import '../../utils/assets.dart';
import '../components/app_bar_common.dart';
import '../components/custom_button.dart';
import 'components/price_row.dart';

class PaymentScreen extends StatefulWidget {
  final int cartId;
  final dynamic amount;
  const PaymentScreen({super.key, required this.cartId, this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Set default payment method to UPI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      if (paymentProvider.selectedPaymentMethod == null) {
        paymentProvider.setSelectedPaymentMethod('upi');
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: const AppBarCommon(title: "Choose Payment"),
      body: Consumer5<OrderProvider, CartProvider, AddressProvider, CheckoutProvider, PaymentProvider>(
          builder: (context, orderProvider, cartProvider, addressProvider, checkoutProvider, paymentProvider, child) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                     Container(

                              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                              color: kAppBarColor,
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
                                            text: 'You could earn ',
                                            style: bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor),
                                            children: [
                                              TextSpan(
                                                text: '168 points',
                                                style: bodyStyleStyleB2Bold.copyWith(color: kAccentTextAccentOrange),
                                              ),
                                              TextSpan(
                                                text: ' on this order',
                                                style: bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: getProportionateScreenHeight(4)),
                                        Text(
                                          'Log in to your account or sign up to gain points!',
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


                        // Payment Summary Card
                        cartProvider.cartState.state.maybeWhen(
                          success: (checkoutResponse) {
                            return _buildPriceDetails(checkoutResponse);
                          },
                          failure: (error) {
                            return const SizedBox.shrink();
                          },
                          orElse: () {
                            return const SizedBox.shrink();
                          },
                        ),

                        // Payment Methods Section
                        _buildPaymentMethodsSection(paymentProvider, orderProvider, cartProvider, addressProvider, checkoutProvider),
                      ],
                    ),
                  ),
                ),

                // Pay Button at bottom
                _buildPayButton(paymentProvider, orderProvider, cartProvider, addressProvider, checkoutProvider),
              ],
            );
          }
      ),
    );
  }

  Widget _buildPaymentMethodsSection(PaymentProvider paymentProvider, OrderProvider orderProvider,
      CartProvider cartProvider, AddressProvider addressProvider, CheckoutProvider checkoutProvider) {
    return Container(
      margin: EdgeInsets.all( getProportionateScreenHeight(16)),
      padding: EdgeInsets.all(getProportionateScreenHeight(20)),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(15)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Select Payment Method',
            style:  bodyStyleStyleB0.copyWith(color: kPrimaryColor,fontSize: getProportionateScreenFont(22)),
          ),
          SizedBox(height: getProportionateScreenHeight(20)),

          // UPI Payment Option
          _buildPaymentCard(
            title: 'UPI Payment',
            subtitle: 'Pay using UPI apps, UPI ID or QR code',
            icon: Icons.phone_android,
            paymentType: 'upi',
            paymentProvider: paymentProvider,

          ),

          SizedBox(height: getProportionateScreenHeight(12)),

          // Card Payment
          _buildPaymentCard(
            title: 'Debit/Credit Cards',
            subtitle: 'Visa, MasterCard, RuPay and more',
            icon: Icons.credit_card,
            paymentType: 'cards',
            paymentProvider: paymentProvider,

          ),

          SizedBox(height: getProportionateScreenHeight(12)),

          // Net Banking
          _buildPaymentCard(
            title: 'Net Banking',
            subtitle: 'Pay using your bank account',
            icon: Icons.account_balance,
            paymentType: 'netbanking',
            paymentProvider: paymentProvider,

          ),

          SizedBox(height: getProportionateScreenHeight(12)),

          // Wallets
          _buildPaymentCard(
            title: 'Digital Wallets',
            subtitle: 'Paytm, PhonePe, Amazon Pay and more',
            icon: Icons.wallet,
            paymentType: 'wallets',
            paymentProvider: paymentProvider,

          ),

          SizedBox(height: getProportionateScreenHeight(12)),

          // Pay Later
          _buildPaymentCard(
            title: 'Pay Later',
            subtitle: 'Simpl, LazyPay, Paytm Postpaid and more',
            icon: Icons.schedule,
            paymentType: 'pay_later',
            paymentProvider: paymentProvider,

          ),

          SizedBox(height: getProportionateScreenHeight(12)),

          // Cash on Delivery
          _buildPaymentCard(
            title: 'Cash On Delivery',
            subtitle: 'Pay when your order is delivered',
            icon: Icons.money,
            paymentType: 'cod',
            paymentProvider: paymentProvider,

          ),

          SizedBox(height: getProportionateScreenHeight(20)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String paymentType,
    required PaymentProvider paymentProvider,

  }) {
    final isSelected = paymentProvider.isPaymentMethodSelected(paymentType);

    return InkWell(
      onTap: () {
        paymentProvider.setSelectedPaymentMethod(paymentType);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(getProportionateScreenHeight(16)),
        decoration: BoxDecoration(
          color: kAppBarColor,
          borderRadius: BorderRadius.circular(15),


        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: kWhiteColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: kPrimaryColor,
              ),
            ),
            SizedBox(width: getProportionateScreenWidth(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      fontFamily: 'manrope',
                      color: isSelected ? const Color(0xFF00694B) : Colors.black87,
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: "manrope",
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kAccentTextAccentOrange : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? kAccentTextAccentOrange : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Replace the _buildPayButton method with this updated version:

  Widget _buildPayButton(PaymentProvider paymentProvider, OrderProvider orderProvider,
      CartProvider cartProvider, AddressProvider addressProvider, CheckoutProvider checkoutProvider) {
    final isProcessing = paymentProvider.isProcessing || orderProvider.isOfflinePaymentLoading;
    final hasSelectedMethod = paymentProvider.selectedPaymentMethod != null;

    return Container(
      padding: EdgeInsets.only(
        left: getProportionateScreenHeight(20),right: getProportionateScreenHeight(20),
        top: getProportionateScreenHeight(16),bottom: getProportionateScreenHeight(8),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        child: isProcessing
            ? const CustomButton(
          text: 'Processing...',
          press: null,
          btnColor: kPrimaryColor,
          txtColor: kWhiteColor,
          isDisabled: true,
        )
            : CustomButton(
          text: hasSelectedMethod
              ? 'Pay ₹${widget.amount.toString()}'
              : 'Select Payment Method',
          press: hasSelectedMethod
              ? () {
            _handlePayment(paymentProvider, orderProvider, cartProvider,
                addressProvider, checkoutProvider);
          }
              : null,
          btnColor: kPrimaryColor,
          txtColor: kWhiteColor,
          isDisabled: !hasSelectedMethod,
        ),
      ),
    );
  }

  void _handlePayment(PaymentProvider paymentProvider, OrderProvider orderProvider,
      CartProvider cartProvider, AddressProvider addressProvider, CheckoutProvider checkoutProvider) {
    final selectedMethod = paymentProvider.selectedPaymentMethod;

    switch (selectedMethod) {
      case 'upi':
        _handleUPIPayment(paymentProvider);
        break;
      case 'cards':
        _handleCardPayment(paymentProvider);
        break;
      case 'netbanking':
        _handleNetBankingPayment(paymentProvider);
        break;
      case 'wallets':
        _handleWalletPayment(paymentProvider);
        break;
      case 'pay_later':
        _handlePayLaterPayment(paymentProvider);
        break;
      case 'cod':
        _handleCashOnDelivery(orderProvider, cartProvider, addressProvider, checkoutProvider, paymentProvider);
        break;
    }
  }

  // Merged UPI Payment Method
  void _handleUPIPayment(PaymentProvider paymentProvider) async {
    paymentProvider.setProcessing(true);

    try {
      final razorPayService = RazorPayService();
      razorPayService.initialize(
        context: context,
        onPaymentSuccess: (paymentId) async {
          await _createOrder('online', 'paid');
          paymentProvider.setProcessing(false);
        },
        onPaymentError: (error) {
          debugPrint('UPI Payment error: $error');
          paymentProvider.setProcessing(false);
        },
      );

      // For UPI, let Razorpay handle all UPI options
      razorPayService.startPayment(
        orderKey: 'rzp_test_LTL06LUHLWeL5W',
        amount: double.parse(widget.amount.toString()),
        customerName: "customerName",
        description: 'Order Payment',
        phoneNumber: "phoneNumber",
        email: "email",
        additionalOptions: {
          'method': 'upi',
        },
      );
    } catch (e) {
      debugPrint('Error initiating UPI payment: $e');
      paymentProvider.setProcessing(false);
    }
  }

  // Card Payment
  void _handleCardPayment(PaymentProvider paymentProvider) async {
    paymentProvider.setProcessing(true);

    try {
      final razorPayService = RazorPayService();
      razorPayService.initialize(
        context: context,
        onPaymentSuccess: (paymentId) async {
          await _createOrder('online', 'paid');
          paymentProvider.setProcessing(false);
        },
        onPaymentError: (error) {
          debugPrint('Card Payment error: $error');
          paymentProvider.setProcessing(false);
        },
      );

      razorPayService.startPayment(
        orderKey: 'rzp_test_LTL06LUHLWeL5W',
        amount: double.parse(widget.amount.toString()),
        customerName: "customerName",
        description: 'Order Payment',
        phoneNumber: "phoneNumber",
        email: "email",
        additionalOptions: {
          'method': 'card',
        },
      );
    } catch (e) {
      debugPrint('Error initiating card payment: $e');
      paymentProvider.setProcessing(false);
    }
  }

  // Net Banking Payment
  void _handleNetBankingPayment(PaymentProvider paymentProvider) async {
    paymentProvider.setProcessing(true);

    try {
      final razorPayService = RazorPayService();
      razorPayService.initialize(
        context: context,
        onPaymentSuccess: (paymentId) async {
          await _createOrder('online', 'paid');
          paymentProvider.setProcessing(false);
        },
        onPaymentError: (error) {
          debugPrint('Net Banking Payment error: $error');
          paymentProvider.setProcessing(false);
        },
      );

      razorPayService.startPayment(
        orderKey: 'rzp_test_LTL06LUHLWeL5W',
        amount: double.parse(widget.amount.toString()),
        customerName: "customerName",
        description: 'Order Payment',
        phoneNumber: "phoneNumber",
        email: "email",
        additionalOptions: {
          'method': 'netbanking',
        },
      );
    } catch (e) {
      debugPrint('Error initiating net banking payment: $e');
      paymentProvider.setProcessing(false);
    }
  }

  // Wallet Payment
  void _handleWalletPayment(PaymentProvider paymentProvider) async {
    paymentProvider.setProcessing(true);

    try {
      final razorPayService = RazorPayService();
      razorPayService.initialize(
        context: context,
        onPaymentSuccess: (paymentId) async {
          await _createOrder('online', 'paid');
          paymentProvider.setProcessing(false);
        },
        onPaymentError: (error) {
          debugPrint('Wallet Payment error: $error');
          paymentProvider.setProcessing(false);
        },
      );

      razorPayService.startPayment(
        orderKey: 'rzp_test_LTL06LUHLWeL5W',
        amount: double.parse(widget.amount.toString()),
        customerName: "customerName",
        description: 'Order Payment',
        phoneNumber: "phoneNumber",
        email: "email",
        additionalOptions: {
          'method': 'wallet',
        },
      );
    } catch (e) {
      debugPrint('Error initiating wallet payment: $e');
      paymentProvider.setProcessing(false);
    }
  }

  // Pay Later Payment
  void _handlePayLaterPayment(PaymentProvider paymentProvider) async {
    paymentProvider.setProcessing(true);

    try {
      final razorPayService = RazorPayService();
      razorPayService.initialize(
        context: context,
        onPaymentSuccess: (paymentId) async {
          await _createOrder('online', 'paid');
          paymentProvider.setProcessing(false);
        },
        onPaymentError: (error) {
          debugPrint('Pay Later Payment error: $error');
          paymentProvider.setProcessing(false);
        },
      );

      razorPayService.startPayment(
        orderKey: 'rzp_test_LTL06LUHLWeL5W',
        amount: double.parse(widget.amount.toString()),
        customerName: "customerName",
        description: 'Order Payment',
        phoneNumber: "phoneNumber",
        email: "email",
        additionalOptions: {
          'method': 'paylater',
        },
      );
    } catch (e) {
      debugPrint('Error initiating pay later payment: $e');
      paymentProvider.setProcessing(false);
    }
  }

  // Cash on Delivery
  void _handleCashOnDelivery(OrderProvider orderProvider, CartProvider cartProvider,
      AddressProvider addressProvider, CheckoutProvider checkoutProvider, PaymentProvider paymentProvider) async {
    paymentProvider.setProcessing(true);

    try {
      await orderProvider.orderCreation(
          cartId: widget.cartId,
          addressId: addressProvider.selectedAddress?.id ?? 0,
          coupon: checkoutProvider.selectedCoupon?.code,
          paymentType: 'offline',
          context: context,
          amount: double.parse(widget.amount.toString()),
          paymentStatus: 'unpaid'
      );

      orderProvider.createOrderState.state.maybeWhen(
          success: (response) {
            cartProvider.fetchCartData(forceRefresh: true);
          },
          orElse: () {}
      );
    } catch (e) {
      debugPrint('Error creating COD order: $e');
    }

    paymentProvider.setProcessing(false);
  }

  // Helper method to create order
  Future<void> _createOrder(String paymentType, String paymentStatus) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    final checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);

    try {
      await orderProvider.orderCreation(
          cartId: widget.cartId,
          addressId: addressProvider.selectedAddress?.id ?? 0,
          coupon: checkoutProvider.selectedCoupon?.code,
          paymentType: paymentType,
          context: context,
          amount: double.parse(widget.amount.toString()),
          paymentStatus: paymentStatus
      );

      orderProvider.createOrderState.state.maybeWhen(
          success: (response) {
            cartProvider.fetchCartData(forceRefresh: false);
          },
          orElse: () {}
      );
    } catch (e) {
      debugPrint('Error creating order: $e');
    }
  }

  Widget _buildPriceDetails(CartResponse data) {
    return Container(
      margin: EdgeInsets.all(getProportionateScreenHeight(16)),
      padding: EdgeInsets.all(getProportionateScreenWidth(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
           Row(
            children: [

              Text(
                'Payment Summary',
                style:  bodyStyleStyleB0.copyWith(color: kPrimaryColor,fontSize: getProportionateScreenFont(22)),
              ),
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
          _buildPriceRow('Subtotal', '₹${data.meta.totalAmount.toStringAsFixed(2)}', false),
          SizedBox(height: getProportionateScreenHeight(12)),
          _buildPriceRow('Delivery Charge', '₹${data.meta.deliveryCharge.toStringAsFixed(2)}', false),
          SizedBox(height: getProportionateScreenHeight(12)),
          _buildPriceRow('Handling Charge', '₹${data.meta.handlingCharge.toStringAsFixed(2)}', false),
          if (data.meta.couponAmount > 0)...[
            SizedBox(height: getProportionateScreenHeight(12)),
            _buildPriceRow('Coupon Discount', '-₹${data.meta.couponAmount.toStringAsFixed(2)}', false, isDiscount: true),
          ],
          SizedBox(height: getProportionateScreenHeight(16)),
          Divider(color: Colors.grey[200], thickness: 1),
          SizedBox(height: getProportionateScreenHeight(16)),
          _buildPriceRow(
            'Total Amount',
            '₹${data.meta.amountPayable.toStringAsFixed(2)}',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isTotal, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? kPrimaryColor : Colors.grey[700],
            fontFamily: 'manrope'
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            fontFamily: 'manrope',
            color: isTotal
                ? kAccentTextAccentOrange
                : Colors.black87,
          ),
        ),
      ],
    );
  }
}