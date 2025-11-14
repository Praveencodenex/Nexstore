import 'package:flutter/material.dart';
import 'package:thenexstore/routes/routes_names.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  static NavigationService get instance => _instance;

  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    ) ?? Future.value(null);
  }

  Future<dynamic> pushNamedAndClearStack(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
          (route) => false, // This predicate always returns false, clearing the entire stack
      arguments: arguments,
    ) ?? Future.value(null);
  }

  Future<dynamic> pushReplacementNamedUntil(
      String routeName,
      String untilRouteName, {
        Object? arguments,
      }) {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      ModalRoute.withName(untilRouteName),
      arguments: arguments,
    ) ?? Future.value(null);
  }

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    ) ?? Future.value(null);
  }

  void goBack() {
    navigatorKey.currentState?.pop();
  }

  void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
  }


  Future<dynamic> navigateToSuccessFromCheckout() {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil(
      RouteNames.successScreen,
      ModalRoute.withName(RouteNames.customBottomNavBar),
    ) ?? Future.value(null);
  }


}