import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/coupon_model.dart';
import '../../../data/providers/checkout_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';
import '../../common/error_screen_new.dart';
import '../../components/product_list_loader.dart';

class CouponListBottomSheet extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Coupon) onCouponSelected;
  final String? selectedCouponCode;

  const CouponListBottomSheet({
    super.key,
    required this.onClose,
    required this.onCouponSelected,
    this.selectedCouponCode,
  });

  @override
  State<CouponListBottomSheet> createState() => _CouponListBottomSheetState();
}

class _CouponListBottomSheetState extends State<CouponListBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CheckoutProvider>().fetchCouponListData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: getProportionateScreenWidth(20)),

          // Bottom sheet indicator
          Container(
            width: getProportionateScreenWidth(40),
            height: getProportionateScreenWidth(4),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Add Coupons',
                  style: headingH3Style.copyWith(color: kPrimaryColor),
                ),
                SizedBox(height: getProportionateScreenHeight(15)),
                Text(
                  'Apply coupons to enjoy special discounts on your order',
                  style: bodyStyleStyleB2.copyWith(color: kTextColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: getProportionateScreenHeight(15)),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Coupons',
                hintStyle: bodyStyleStyleB2Bold.copyWith(color: kTextColor.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: kTextColor.withOpacity(0.5)),
                filled: true,
                fillColor: kAppBarColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: kTextColor.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: kSecondaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: kPrimaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          Consumer<CheckoutProvider>(
            builder: (context, provider, _) {
              return provider.couponState.state.maybeWhen(
                initial: () =>  SizedBox(height: getProportionateScreenHeight(100),width: getProportionateScreenWidth(100),
                    child:  Center(child: SizedBox(height:getProportionateScreenHeight(25),width:getProportionateScreenWidth(25),child: const CircularProgressIndicator(color: kPrimaryColor,),))),
                loading: () =>  SizedBox(height: getProportionateScreenHeight(100),width: getProportionateScreenWidth(100),
                    child:  Center(child: SizedBox(height:getProportionateScreenHeight(25),width:getProportionateScreenWidth(25),child: const CircularProgressIndicator(color: kPrimaryColor,),))),
                success: (couponData) {
                  if (couponData.data.isEmpty) {
                    return Center(
                      child: Padding(
                        padding:  EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10),vertical: getProportionateScreenHeight(80)),
                        child: Text("No coupons available", style: bodyStyleStyleB1),
                      ),
                    );
                  }

                  final coupons = couponData.data.where((coupon) {
                    return coupon.code.toLowerCase().contains(_searchQuery) ||
                        coupon.title.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (coupons.isEmpty) {
                    return Center(
                      child: Padding(
                        padding:  EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10),vertical: getProportionateScreenHeight(80)),
                        child: Text("No coupons found", style: bodyStyleStyleB1),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    padding:  EdgeInsets.only(left: getProportionateScreenWidth(16),right:getProportionateScreenWidth(16),bottom: getProportionateScreenHeight(25),top: getProportionateScreenHeight(16)),
                    itemCount: coupons.length,
                    itemBuilder: (context, index) {
                      final coupon = coupons[index];
                      final isSelected = coupon.code == widget.selectedCouponCode;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: () {
                            widget.onCouponSelected(coupon);
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        coupon.title.toUpperCase(),
                                        style: bodyStyleStyleB2Bold.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      coupon.type == "first_order"
                                          ? Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(text: 'Get extra ', style: bodyStyleStyleB2),
                                            TextSpan(
                                              text: '${coupon.discountType == "percent" ? "" : "₹"}${coupon.discount}${coupon.discountType == "percent" ? "%" : ""}',
                                              style: bodyStyleStyleB2.copyWith(color: kAccentTextAccentOrange),
                                            ),
                                            if (coupon.discountType == "percent")
                                              TextSpan(
                                                text: ' upto Rs ${coupon.maxDiscount}',
                                                style: bodyStyleStyleB2,
                                              ),
                                            TextSpan(
                                              text: ' on a cart value of ${coupon.minPurchase} and above for first order',
                                              style: bodyStyleStyleB2,
                                            ),
                                          ],
                                        ),
                                      )
                                          : Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(text: 'Get extra ', style: bodyStyleStyleB2),
                                            TextSpan(
                                              text: '${coupon.discountType == "percent" ? "" : "₹"}${coupon.discount}${coupon.discountType == "percent" ? "%" : ""}',
                                              style: bodyStyleStyleB2.copyWith(color: kAccentTextAccentOrange),
                                            ),
                                            if (coupon.discountType == "percent")
                                              TextSpan(
                                                text: ' upto Rs ${coupon.maxDiscount}',
                                                style: bodyStyleStyleB2,
                                              ),
                                            TextSpan(
                                              text: ' on a cart value of ${coupon.minPurchase} and above',
                                              style: bodyStyleStyleB2,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(width: getProportionateScreenWidth(10)),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected ? kPrimaryColor : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(30), // Make it rectangular
                                  ),
                                  child: isSelected
                                      ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: kPrimaryColor,
                                    ),
                                  )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                failure: (error) =>   Center(
                  child:Padding(
                    padding:  EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10),vertical: getProportionateScreenHeight(80)),
                    child: Text("Something went wrong", style: bodyStyleStyleB1),
                  ),
                 ),
                orElse: () => const ProductLoader(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Helper function to show the bottom sheet
void showCouponSelector(
    BuildContext context,
    Function(Coupon) onCouponSelected,
    String? selectedCouponCode, // Add this parameter
    ) {
  final checkoutProvider = Provider.of<CheckoutProvider>(context, listen: false);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ChangeNotifierProvider.value(
          value: checkoutProvider,
          child: CouponListBottomSheet(
            onClose: () => Navigator.pop(context),
            onCouponSelected: onCouponSelected,
            selectedCouponCode: selectedCouponCode, // Pass the selected coupon code
          ),
        ),
      ),
    ),
  );
}