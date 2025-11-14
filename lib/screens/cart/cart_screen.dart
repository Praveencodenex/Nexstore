import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import '../../data/providers/address_provider.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/providers/checkout_provider.dart';
import '../../data/providers/user_provider.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../components/app_bar_common.dart';
import '../components/common_app_bar.dart';
import 'cart_success_screen.dart';
import 'components/cart_loader.dart';

class CartScreen extends StatefulWidget {
  final bool isBottom;
  const CartScreen({super.key, required this.isBottom});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>  {
  Future<void> _initializeData() async {
    await _loadAddressData();
    await _fetchData(forceRefresh: false);
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          if(widget.isBottom){
            Provider.of<UserProvider>(context, listen: false).setCurrentIndex(0);
          }else{
            NavigationService.instance.goBack();
          }
        }
      },
      child: Scaffold(
        backgroundColor: kAppBarColor,
        appBar: const AppBarCommon(title: 'My Cart',cart: false,),
        body: Consumer<CartProvider>(
          builder: (context, provider, child) {
            return provider.cartState.state.when(
              initial: () => const CartLoader(),
              loading: () => const CartLoader(),
              success: (cartData) {
                if (cartData.data.cartItems.isEmpty) {
                  return const NoDataScreen(
                    title: "Cart is Empty",
                    subTitle: "Add items to your cart",
                    icon: emptyError
                  );
                }
                return CartSuccessScreen(
                  onRefresh: () => _fetchData(forceRefresh: true),
                  cartData: cartData,
                );
              },
              failure: (error) => ErrorScreenNew(
                error: error,
                onRetry: () => provider.fetchCartData(forceRefresh: true),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _fetchData({required bool forceRefresh}) async {
    context.read<CheckoutProvider>().removeSelectedCoupon();
    final addressProvider = context.read<AddressProvider>();
    final selectedAddress = addressProvider.selectedAddress;
     context.read<CartProvider>().fetchCartData(
       addressId: selectedAddress!.id,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> _loadAddressData() async {
    if (!mounted) return;
    final provider = context.read<AddressProvider>();
    await provider.fetchAddressData();

    if (!mounted) return;

    provider.addressState.state.maybeWhen(
      success: (addressResponse) async {
        if (addressResponse.data.isNotEmpty) {
          final defaultAddress = provider.getDefaultAddress();
          if (defaultAddress != null) {
            provider.setSelectedAddress(defaultAddress);
          }
        }
      },
      orElse: () {

      },
    );
  }
}