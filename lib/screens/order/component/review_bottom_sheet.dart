import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/providers/order_provider.dart';
import 'package:thenexstore/screens/components/custom_button.dart';
import 'package:thenexstore/screens/components/custom_text_field.dart';
import 'package:thenexstore/utils/snack_bar.dart';
import '../../../routes/navigator_services.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';

class ReviewBottomSheet extends StatefulWidget {
  final String productName;
  final String productDescription;
  final int initialRating;
  final int orderId;
  final ValueChanged<int> onRatingChanged;

  const ReviewBottomSheet({
    super.key,
    required this.productName,
    required this.productDescription,
    required this.initialRating,
    required this.orderId,
    required this.onRatingChanged,
  });

  @override
  State<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<ReviewBottomSheet> {
  final TextEditingController _reviewController = TextEditingController();
  OrderProvider? _orderProvider;
  bool _isListenerAttached = false;

  @override
  void initState() {
    super.initState();
    // Setup listener after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setupStateListener();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _orderProvider = Provider.of<OrderProvider>(context, listen: false);
  }

  void _setupStateListener() {
    if (_orderProvider != null && !_isListenerAttached && mounted) {
      _orderProvider!.addListener(_handleStateChange);
      _isListenerAttached = true;
    }
  }

  void _handleStateChange() {
    // Check if widget is still mounted and provider is available
    if (!mounted || _orderProvider == null) {
      _removeListener();
      return;
    }

    _orderProvider!.reviewOrderState.state.maybeWhen(
      success: (data) {
        // Use post frame callback to ensure UI operations happen after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            NavigationService.instance.goBack();
            SnackBarUtils.showSuccess("Review Updated Successfully");
          }
        });
        // Remove listener to prevent multiple calls
        _removeListener();
      },
      failure: (error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            NavigationService.instance.goBack();
            SnackBarUtils.showError("Failed to update Review: ${error.message}");
          }
        });
        _removeListener();
      },
      orElse: () {},
    );
  }

  void _removeListener() {
    if (_orderProvider != null && _isListenerAttached) {
      _orderProvider!.removeListener(_handleStateChange);
      _isListenerAttached = false;
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9, // Increased max height
      ),
      padding: EdgeInsets.only(
        left: getProportionateScreenWidth(20),
        right: getProportionateScreenWidth(20),
        top: getProportionateScreenWidth(20),
        bottom: MediaQuery.of(context).viewInsets.bottom + getProportionateScreenWidth(20), // Add keyboard padding
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: getProportionateScreenWidth(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Placeholder for alignment
                Text(
                  'Write your review',
                  style: headingH3Style,
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: getProportionateScreenWidth(20)),
            Consumer<OrderProvider>(
              builder: (context, ratingProvider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        ratingProvider.setRating(index + 1);
                        widget.onRatingChanged(index + 1);
                      },
                      child: Icon(
                        index < ratingProvider.selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: getProportionateScreenWidth(30),
                      ),
                    );
                  }),
                );
              },
            ),
            SizedBox(height: getProportionateScreenWidth(20)),
            CustomTextField(
              controller: _reviewController,
              hint: 'Write your review here...',
              maxLines: 4,
              filled: true,
              fillColor: Colors.white,
              borderRadius: 8,
              borderWidth: 1,
              focusedBorderWidth: 1,
              enabledBorderColor: Colors.grey.withOpacity(0.5),
              focusedBorderColor: kPrimaryColor,
              contentPadding: EdgeInsets.all(getProportionateScreenWidth(12)),
              onChanged: (value) {
                // Handle review text changes if needed
              },
            ),
            SizedBox(height: getProportionateScreenWidth(20)),
            Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                return CustomButton(
                  text: orderProvider.isReviewing ? "Submitting..." : "Submit",
                  btnColor: kPrimaryColor,
                  txtColor: kWhiteColor,
                  press: orderProvider.isReviewing ? null : () => _submitReview(context, orderProvider),
                );
              },
            ),
            SizedBox(height: getProportionateScreenWidth(20)),
          ],
        ),
      ),
    );
  }

  void _submitReview(BuildContext context, OrderProvider orderProvider) async {
    if (orderProvider.selectedRating == 0) {
      NavigationService.instance.goBack();
      SnackBarUtils.showError("Please select a rating");

      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      NavigationService.instance.goBack();
      SnackBarUtils.showError("Please write a review");
      return;
    }

    await orderProvider.orderReview(
      widget.orderId,
      orderProvider.selectedRating,
      _reviewController.text.trim(),
    );
  }
}