import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/providers/order_provider.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../data/models/order_details_model.dart';
import '../../utils/constants.dart';
import 'component/review_bottom_sheet.dart';
import 'order_exchange_cancel_reason_screen.dart';

class OrderDetailsSuccessScreen extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final OrderDetailsResponse orderData;

  const OrderDetailsSuccessScreen({
    super.key,
    required this.onRefresh,
    required this.orderData,
  });

  // Generate a random light pastel color for product background
  Color _getRandomLightColor(int seed) {
    final random = Random(seed);
    final colors = [
      const Color(0xFFE8F5E9), // Light green
      const Color(0xFFFFF9C4), // Light yellow
      const Color(0xFFF6E2C5), // Light orange
      const Color(0xFFF3E5F5), // Light purple
      const Color(0xFFE1F5FE), // Light blue
      const Color(0xFFFCE4EC), // Light pink
      const Color(0xFFF1F8E9), // Light lime
      const Color(0xFFE0F2F1), // Light teal
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final order = orderData.data;

    return Scaffold(
      backgroundColor: kAppBarColor,
      floatingActionButton: order.orderStatus.toLowerCase() == "delivered"
          ? Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          return FloatingActionButton.extended(
            onPressed: orderProvider.isDownloading
                ? null
                : () {
              orderProvider.getInvoice(order.id, context);
            },
            backgroundColor: kPrimaryColor,
            icon: orderProvider.isDownloading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: kWhiteColor,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.download, color: kWhiteColor),
            label: Text(
              orderProvider.isDownloading ? "Downloading..." : 'Download Invoice',
              style: bodyStyleStyleB2SemiBold.copyWith(color: kWhiteColor),
            ),
          );
        },
      )
          : null,
      body: RefreshIndicator(
        color: kPrimaryColor,
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getProportionateScreenWidth(8)),
              _rowItemText("Payment Method:", order.paymentMethod == "offline" ? "Cash On Delivery" : "Prepaid",false),
              SizedBox(height: getProportionateScreenWidth(8)),
              _rowItemText("Order Status:",  order.orderStatus.isNotEmpty
                  ? '${order.orderStatus[0].toUpperCase()}${order.orderStatus.substring(1)}'.replaceAll('_', ' ')
                  : order.orderStatus.replaceAll('_', ' '),false),
              SizedBox(height: getProportionateScreenWidth(8)),
              _rowItemText("Total Items:", order.totalItems.toString(),false),
              SizedBox(height: getProportionateScreenWidth(8)),
              _rowItemText("Order ID: ", "#ORD${order.id}",true),

              if(order.isCancellable && order.orderStatus.toLowerCase() != "cancelled")...[
                SizedBox(height: getProportionateScreenHeight(16)),
                Consumer<OrderProvider>(
                    builder: (context, provider, child) {
                      return ElevatedButton(
                        onPressed: provider.isCancelling
                            ? null
                            : () => _handleCancelOrder(context, order.id.toString(), order.id, null),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: getProportionateScreenWidth(16),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          provider.isCancelling ? 'Please Wait' : 'Cancel',
                          style: bodyStyleStyleB2SemiBold.copyWith(
                            color: kWhiteColor,
                          ),
                        ),
                      );
                    }
                ),
              ],

              SizedBox(height: getProportionateScreenWidth(25)),

              // Products List - Card Style like order_item_cards
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.products.length,
                itemBuilder: (context, index) {
                  final product = order.products[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: getProportionateScreenWidth(16)),
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(8),
                      vertical: getProportionateScreenWidth(8),
                    ),
                    decoration: BoxDecoration(
                      color: kWhiteColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Product Image with random light background
                        Container(
                          width: getProportionateScreenWidth(95),
                          height: getProportionateScreenWidth(110),
                          decoration: BoxDecoration(
                            color: _getRandomLightColor(product.id.hashCode),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: kPrimaryColor,
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (context, error, stackTrace) => Icon(
                                Icons.broken_image,
                                size: getProportionateScreenWidth(40),
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: getProportionateScreenWidth(12)),

                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name
                              Text(
                                product.name,
                                style: bodyStyleStyleB1Bold.copyWith(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: getProportionateScreenHeight(15),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: getProportionateScreenWidth(3)),

                              // Weight and Unit
                              Text(
                                '${product.weight} ${product.unit}',
                                style: bodyStyleStyleB3SemiBold.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: getProportionateScreenWidth(3)),

                              // Quantity
                              Text(
                                'Qty: ${product.qty.toStringAsFixed(0)}',
                                style: bodyStyleStyleB3SemiBold.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: getProportionateScreenWidth(8)),

                              // Price and Exchange Button Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Price
                                  Text(
                                      '₹${product.price}',
                                      style:bodyStyleStyleB1Bold.copyWith(color: kAccentTextAccentOrange, fontWeight: FontWeight.w800,fontSize: getProportionateScreenHeight(18))
                                  ),

                                  // Exchange Button
                                  if (product.isExchanged)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getProportionateScreenWidth(12),
                                        vertical: getProportionateScreenWidth(8),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Exchanged',
                                        style: bodyStyleStyleB3SemiBold.copyWith(
                                          color: Colors.orange,
                                          fontSize: getProportionateScreenFont(13),
                                        ),
                                      ),
                                    )
                                  else if (product.isExchangeable)
                                    Consumer<OrderProvider>(
                                      builder: (context, provider, child) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: getProportionateScreenWidth(12),
                                            vertical: getProportionateScreenWidth(8),
                                          ),
                                          decoration: BoxDecoration(
                                            color: kPrimaryColor,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: InkWell(
                                            onTap: provider.isExchanging
                                                ? null
                                                : () => _handleExchangeOrder(
                                                context,
                                                product,
                                                order.id,
                                                order.products[index].id),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  provider.isExchanging ? 'Wait' : 'Exchange',
                                                  style: bodyStyleStyleB3SemiBold.copyWith(
                                                    color: kWhiteColor,
                                                    fontSize: getProportionateScreenFont(13),
                                                  ),
                                                ),
                                                if (!provider.isExchanging) ...[
                                                  SizedBox(width: getProportionateScreenWidth(4)),
                                                  Icon(
                                                    Icons.arrow_forward,
                                                    size: getProportionateScreenFont(14),
                                                    color: kWhiteColor,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: getProportionateScreenHeight(8)),

              // Address Section
              Container(
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(15),

                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.only(top: getProportionateScreenWidth(16),left: getProportionateScreenWidth(16),right: getProportionateScreenWidth(16)),
                      child: Row(
                        children: [

                          Text(
                            'Delivery Address',
                            style: bodyStyleStyleB1SemiBold.copyWith(fontWeight: FontWeight.w800,
                              color: kPrimaryColor,fontSize: getProportionateScreenHeight(20)
                            ),
                          ),
                        ],
                      ),
                    ),


                    // Address Content
                    Padding(
                      padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contact Name & Phone
                          Row(
                            children: [

                              Text(
                                order.deliveryAddress.contactName,
                                style: bodyStyleStyleB3.copyWith(
                                  color: kTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: getProportionateScreenHeight(4)),

                          // Location Name
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  order.deliveryAddress.name,
                                  style: bodyStyleStyleB3.copyWith(
                                    color: kTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: getProportionateScreenHeight(4)),

                          // Full Address
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Expanded(
                                child: Text(
                                  order.deliveryAddress.address,
                                  style:  bodyStyleStyleB3.copyWith(
                                    color: kTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: getProportionateScreenHeight(4)),
                          Row(
                            children: [

                              Text(
                                order.deliveryAddress.contactPhone,
                                style:  bodyStyleStyleB3.copyWith(
                                  color: kTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: getProportionateScreenHeight(16)),

              // Price Summary Container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: kGreyColorLight,
                ),
                margin: EdgeInsets.only(bottom: getProportionateScreenHeight(26)),
                padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16),vertical: getProportionateScreenHeight(16)),
                child: Column(
                  children: [
                    _priceRowItemText("Sub Total", order.total?.toStringAsFixed(2) ?? order.totalAmount.toStringAsFixed(2), false),
                    const SizedBox(height: 8),
                    _priceRowItemText("Delivery Charge", order.deliveryCharge?.toStringAsFixed(2) ?? "0.00", false),
                    const SizedBox(height: 8),
                    _priceRowItemText("Handling Charges", order.handlingCharge?.toString() ?? "0.00", false),
                    const SizedBox(height: 5),
                    Divider(height: getProportionateScreenHeight(25)),
                    const SizedBox(height: 5),
                    _priceRowItemText("Total Amount", order.amountPayable?.toStringAsFixed(2) ?? order.totalAmount.toStringAsFixed(2), true),
                  ],
                ),
              ),

              if (order.orderStatus.toLowerCase() == "delivered") ...[
                Consumer<OrderProvider>(
                  builder: (context, ratingProvider, child) {
                    return Center(
                      child: order.review != null ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Consumer<OrderProvider>(
                            builder: (context, ratingProvider, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: Icon(
                                      index < order.review!.rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: getProportionateScreenWidth(30),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                          SizedBox(height: getProportionateScreenHeight(10)),
                          Text(
                            order.review?.comment ?? "",
                            style: bodyStyleStyleB2SemiBold,
                          ),
                        ],
                      ) : TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.black.withOpacity(0.5),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            builder: (context) => ReviewBottomSheet(
                              productName: order.products.isNotEmpty ? order.products[0].name : '',
                              productDescription: order.products.isNotEmpty ? '' : '',
                              initialRating: ratingProvider.selectedRating,
                              onRatingChanged: (rating) {
                                ratingProvider.setRating(rating);
                              },
                              orderId: order.id,
                            ),
                          );
                        },
                        child: Text(
                          'Write a review',
                          style: bodyStyleStyleB2SemiBold.copyWith(color: kPrimaryColor),
                        ),
                      ),
                    );
                  },
                ),
              ],

              // Add extra bottom padding when FAB is visible
              if (order.orderStatus.toLowerCase() == "delivered")
                SizedBox(height: getProportionateScreenHeight(80)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCancelOrder(BuildContext context, String name, int orderId, int? productId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReasonSelectionScreen(
          type: 'cancel',
          orderId: orderId,
          productName: name,
          productId: null,
        ),
      ),
    );
  }

  void _handleExchangeOrder(BuildContext context, Product product, int orderId, int? productId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReasonSelectionScreen(
          type: 'exchange',
          orderId: orderId,
          productName: product.name,
          productId: productId,
        ),
      ),
    );
  }

  Widget _rowItemText(String text1, String text2,bool isId) {
    return Row(
      children: [
        Text(
          text1,
          style: bodyStyleStyleB3SemiBold.copyWith(fontSize: getProportionateScreenHeight(14),color: kPrimaryColor,),
        ),
        SizedBox(width: getProportionateScreenWidth(5)),
        Text(
          text2,
          style: isId?bodyStyleStyleB3.copyWith(color: kAccentTextAccentOrange,fontWeight: FontWeight.w800):bodyStyleStyleB3,
        ),
      ],
    );
  }

  Widget _priceRowItemText(String text1, String text2, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          text1,
          style: isTotal
              ? bodyStyleStyleB2SemiBold.copyWith(color: kPrimaryColor, fontWeight: FontWeight.w800,fontSize: getProportionateScreenHeight(18))
              : bodyStyleStyleB2,
        ),
        SizedBox(width: getProportionateScreenWidth(5)),
        Text(
          '₹ $text2',
          style: bodyStyleStyleB2SemiBold.copyWith(color:isTotal
              ? kAccentTextAccentOrange: kBlackColor, fontWeight: isTotal
              ? FontWeight.w800:FontWeight.w700,fontSize:isTotal
              ? getProportionateScreenHeight(18):getProportionateScreenHeight(14)),
        ),
      ],
    );
  }
}