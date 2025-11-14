
import 'package:flutter/material.dart';
import 'package:thenexstore/data/models/checkout_model.dart';
import 'package:thenexstore/data/models/coupon_model.dart';
import 'package:thenexstore/data/repository/checkout_repository.dart';
import '../../utils/snack_bar.dart';
import 'api_state_provider.dart';

class CheckoutProvider with ChangeNotifier {
  final CheckoutRepository _repository = CheckoutRepository();
  final ApiStateProvider<CouponResponse> couponState = ApiStateProvider<CouponResponse>();
  final ApiStateProvider<CheckoutResponse> checkoutState = ApiStateProvider<CheckoutResponse>();

  Future<void> fetchCouponListData() async {
    try {
      await _repository.getCouponList(
        stateProvider: couponState,
      );
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchCheckoutData({
    bool forceRefresh = false,
    String distance = "0",
    int? couponId ,
    required int cartId,
    required int addressId,
  }) async {
    try {

      if(forceRefresh) {
        await clearCache();
      }

      await _repository.getCheckout(
          stateProvider: checkoutState,
          forceRefresh: forceRefresh,
          distance: distance,
          cartId: cartId,
          couponId: couponId,
          addressId: addressId
      );

      checkoutState.state.maybeWhen(
        success: (data){
          checkoutResponse=data;
        },
          failure: (error){
            removeSelectedCoupon();
            SnackBarUtils.showError(error.message);
          },
          orElse:(){});

      notifyListeners();
    } catch (e) {
      debugPrint('Checkout error: $e');
    }
  }

  Coupon? _selectedCoupon;
  CheckoutResponse? checkoutResponse;

  CheckoutResponse? get checkoutResponseData => checkoutResponse;
  Coupon? get selectedCoupon => _selectedCoupon;

  void setSelectedCoupon(Coupon coupon) {
    _selectedCoupon = coupon;
    notifyListeners();
  }

  void removeSelectedCoupon() {
    _selectedCoupon = null;
    notifyListeners();
  }
  Future<void> clearCache() async {
    await _repository.clearCheckoutCache();
    notifyListeners();
  }
}