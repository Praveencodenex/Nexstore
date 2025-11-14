import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/providers/order_provider.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';
import 'package:thenexstore/utils/snack_bar.dart';
import '../components/common_app_bar.dart';
import '../components/custom_button.dart';

class ReasonSelectionScreen extends StatefulWidget {
  final String type; // 'cancel' or 'exchange'
  final int orderId;
  final int? productId;
  final String productName;

  const ReasonSelectionScreen({
    super.key,
    required this.type,
    required this.orderId,
    required this.productName,
    this.productId,
  });

  @override
  State<ReasonSelectionScreen> createState() => _ReasonSelectionScreenState();
}

class _ReasonSelectionScreenState extends State<ReasonSelectionScreen> {

  List<String> get cancelReasons => [
    'Incorrect Item Ordered',
    'Product Not Required',
    'Found Better Price',
    'Delivery Delay',
    'Order by Mistake',
    'Other'
  ];

  List<String> get exchangeReasons => [
    'Incorrect Item Ordered',
    'Expired Product',
    'Damaged Packaging',
    'Quality Issues',
    'Size/Weight Mismatch',
    'Other'
  ];

  List<String> get reasons => widget.type == 'cancel' ? cancelReasons : exchangeReasons;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      appBar: CommonAppBar(
        title: widget.type == 'cancel' ? 'Cancel Order' : 'Exchange',
        search: false,cart: true,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: getProportionateScreenHeight(8)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                        decoration: BoxDecoration(
                          color: kGreyColorLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  widget.type == 'cancel' ? Icons.cancel_outlined : Icons.swap_horiz,
                                  color: kPrimaryColor,
                                  size: getProportionateScreenWidth(24),
                                ),
                                SizedBox(width: getProportionateScreenWidth(8)),
                                Text(
                                  widget.type == 'cancel' ? 'Cancel your order' : 'Exchange your product',
                                  style: bodyStyleStyleB2SemiBold.copyWith(
                                    color: kBlackColor,
                                    fontSize: getProportionateScreenWidth(16),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: getProportionateScreenHeight(12)),
                            Text(
                              'Please select a reason for ${widget.type == 'cancel' ? 'cancelling' : 'exchanging'} this order:',
                              style: bodyStyleStyleB3.copyWith(color: kBlackColor),
                            ),
                            SizedBox(height: getProportionateScreenHeight(8)),
                            Text(
                              widget.productName,
                              style: bodyStyleStyleB2SemiBold.copyWith(color: kPrimaryColor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(24)),
                      Container(
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: reasons.map((reason) {
                            final isSelected = provider.selectedReason == reason;
                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: getProportionateScreenWidth(16),
                                    vertical: getProportionateScreenHeight(4),
                                  ),
                                  leading: Radio<String>(
                                    value: reason,
                                    groupValue: provider.selectedReason,
                                    onChanged: (value) {
                                      provider.setSelectedReason(value);
                                    },
                                    activeColor: kPrimaryColor,
                                  ),
                                  title: Text(
                                    reason,
                                    style: bodyStyleStyleB2.copyWith(
                                      color: kBlackColor,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  onTap: () {
                                    provider.setSelectedReason(reason);
                                  },
                                ),
                                if (reason != reasons.last)
                                  Divider(
                                    height: 1,
                                    color: kGreyColorLightMed.withOpacity(0.5),
                                    indent: getProportionateScreenWidth(16),
                                    endIndent: getProportionateScreenWidth(16),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: CustomButton(
                    text: widget.type == 'cancel'
                        ? provider.isCancelling ? 'Please Wait' : 'Cancel Order'
                        : provider.isExchanging ? 'Please Wait' : 'Exchange Product',
                    txtColor: kWhiteColor,
                    btnColor: kPrimaryColor,
                    isDisabled: provider.selectedReason == null ||
                        (widget.type == 'cancel' ? provider.isCancelling : provider.isExchanging),
                    press: provider.selectedReason == null
                        ? null
                        : () => _handleSubmit(provider),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleSubmit(OrderProvider provider) async {
    if (provider.selectedReason == null) return;

    try {
      if (widget.type == 'cancel') {
        await provider.cancelOrder(widget.orderId, provider.selectedReason!);

        provider.reOrderSubmitState.state.maybeWhen(
          success: (response) {
            if (mounted) {
              SnackBarUtils.showSuccess('Order cancelled successfully');
              provider.clearSelectedReason(); // Clear after success
              Navigator.of(context).pop();
              provider.fetchOrderDetails(orderId: widget.orderId,forceRefresh: true);
            }
          },
          failure: (error) {
            if (mounted) {
              SnackBarUtils.showError('Failed to cancel order: ${error.message}');
            }
          },
          orElse: () {},
        );
      } else {
        await provider.exchangeOrder(
            widget.orderId,
            provider.selectedReason!,
            widget.productId ?? 0
        );

        provider.reOrderSubmitState.state.maybeWhen(
          success: (response) {
            if (mounted) {
              SnackBarUtils.showSuccess('Exchange request submitted successfully');
              provider.clearSelectedReason(); // Clear after success
              Navigator.of(context).pop();
              provider.fetchOrderDetails(orderId: widget.orderId,forceRefresh: true);
            }
          },
          failure: (error) {
            if (mounted) {
              SnackBarUtils.showError('Failed to submit exchange request: ${error.message}');
            }
          },
          orElse: () {},
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError('An error occurred. Please try again.');
      }
    }
  }
}