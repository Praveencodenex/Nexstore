import 'package:flutter/material.dart';
import 'package:thenexstore/routes/route_animations.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/screens/account/settings_screen.dart';
import 'package:thenexstore/screens/cart/cart_screen.dart';
import 'package:thenexstore/screens/checkout/payment_screen.dart';
import 'package:thenexstore/screens/home/home_screen.dart';
import 'package:thenexstore/screens/order/success_screen.dart';
import 'package:thenexstore/screens/signin/email_signin.dart';
import 'package:thenexstore/screens/signin/otp_screen.dart';
import 'package:thenexstore/screens/splash/splash_screen.dart';

import '../data/models/address_model.dart';
import '../data/models/cart_model.dart';
import '../data/models/profile_model.dart';
import '../screens/account/contact_screen.dart';
import '../screens/account/faq_screen.dart';
import '../screens/address/add_edit_address_screen.dart';
import '../screens/address/address_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/components/custom_bottom_nav_bar.dart';
import '../screens/details/detail_screen.dart';
import '../screens/intro/intro_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/order/failed_screen.dart';
import '../screens/order/order_details_screen.dart';
import '../screens/order/order_screen.dart';
import '../screens/order/order_track_screen.dart';
import '../screens/products/product_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/signin/mobile_signing.dart';
import '../screens/signin/sign_in_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {

      case (RouteNames.login):
        return SlideRightRoute(page: const LoginSignupScreen());
      case (RouteNames.mobileLoginScreen):
        return SlideRightRoute(page:  MobileLoginScreen());
      case (RouteNames.emailLogin):
        return SlideRightRoute(page:  EmailSignInScreen());
      case (RouteNames.customBottomNavBar):
        return SlideRightRoute(page: const CustomBottomNavBar());
      case (RouteNames.homeScreen):
        return SlideRightRoute(page: const HomeScreen());
      case (RouteNames.splashScreen):
        return SlideRightRoute(page: const SplashScreen());
      case (RouteNames.introScreen):
        return SlideRightRoute(page: const OnboardingScreen());
      case (RouteNames.searchScreen):
        return SlideRightRoute(page: const SearchScreen());
      case (RouteNames.wishListScreen):
        return SlideRightRoute(page: const WishListScreen());
      case (RouteNames.checkoutScreen):
        return SlideRightRoute(page:  CheckoutScreen(cartResponse: args?['checkout'] as CartResponse?));
      case (RouteNames.addressScreen):
        return SlideRightRoute(page: const AddressScreen());
      case (RouteNames.settingsScreen):
        return SlideRightRoute(page: const SettingsScreen());
      case (RouteNames.faqScreen):
        return SlideRightRoute(page: const FaqScreen());
      case (RouteNames.successScreen):
        return SlideRightRoute(page: const SuccessScreen());
      case (RouteNames.failedScreen):
        return SlideRightRoute(page: const FailedScreen());
      case (RouteNames.cartScreen):
        return SlideRightRoute(page:  CartScreen(isBottom: args?['isBottom'] ?? false,));
      case (RouteNames.notificationScreen):
        return SlideRightRoute(page: const NotificationScreen());
      case (RouteNames.orderScreen):
        return SlideRightRoute(page:  OrderScreen(backNeeded: args?['backNeeded'] ?? 0));
      case (RouteNames.contactScreen):
        return SlideRightRoute(page: const ContactSupportScreen());
      case (RouteNames.paymentScreen):
        return SlideRightRoute(page: PaymentScreen(cartId: args?['cartId'] ?? 0,amount:args?['amount'] ?? 0));
      case (RouteNames.productsListingScreen):
        return SlideRightRoute(page: ProductsScreen(categoryId: args?['catId'] ?? 0, categoryTitle: args?['catTitle'] ?? '',));
      case (RouteNames.productDetailScreen):
        return SlideRightRoute(page: ProductDetailScreen(product: args?['product'] ?? ''));
      case (RouteNames.editProfileScreen):
        return SlideRightRoute(page: EditProfileScreen(profileData: args?['profileData'] as ProfileData));
      case (RouteNames.orderDetailsScreen):
        return SlideRightRoute(page: OrderDetailsScreen(orderId: args?['orderId'] ?? ''));
      case (RouteNames.orderTrackScreen):
        return SlideRightRoute(page: OrderTrackScreen(orderId: args?['orderId'] ?? ''));
      case (RouteNames.addEditAddressScreen):
        return SlideRightRoute(page: AddEditAddressScreen(address: args?['address'] as Address?));
      case (RouteNames.otpScreen):
        return SlideRightRoute(page: OtpScreen(phoneNumber: args?['phone'] ?? '', isEmail:  args?['isEmail'] ??false));

      default:
        return SlideRightRoute(
          page: const Scaffold(
            body: Center(
              child: Text("No route is configured"),
            ),
          ),
        );
    }
  }
}