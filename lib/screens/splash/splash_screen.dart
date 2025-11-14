import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/providers/cart_provider.dart';
import '../../data/services/auth_service.dart';
import '../../routes/navigator_services.dart';
import '../../routes/routes_names.dart';
import '../../utils/constants.dart';
import 'components/body.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation(context);
  }

  Future<void> _handleNavigation(BuildContext context) async {
    try {
      final authManager = Provider.of<AuthTokenService>(context, listen: false);
      final isLoggedIn = authManager.isLoggedIn;
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      if (isLoggedIn) {
        await Provider.of<CartProvider>(context, listen: false).fetchCartData();
        await NavigationService.instance.pushNamedAndClearStack(RouteNames.customBottomNavBar);
      } else {
        await NavigationService.instance.pushNamedAndClearStack(RouteNames.introScreen);
      }
    } catch (e) {
      if (mounted) {
        await NavigationService.instance.pushNamedAndClearStack(RouteNames.introScreen);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: kPrimaryColor,
      statusBarIconBrightness: Brightness.light,
    ));

    return  const Scaffold(

      body: SplashScreenBody(),
    );
  }
}