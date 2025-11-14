import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';


ThemeData theme() {
  return ThemeData(
    primaryColor: kWhiteColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: appBarTheme(),

   bottomNavigationBarTheme: BottomNavigationBarThemeData(
       selectedItemColor:  kBlackColor,
       selectedLabelStyle:bodyStyleStyleB3SemiBold,
       unselectedLabelStyle: bodyStyleStyleB3SemiBold.copyWith(color: kTextColor),
       unselectedItemColor: kSecondaryColor,
   backgroundColor: kWhiteColor),

    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}



AppBarTheme appBarTheme() {
  return const AppBarTheme(
    color: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    toolbarTextStyle: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
  systemOverlayStyle: SystemUiOverlayStyle(
  statusBarColor: Colors.white, // Default color for all screens
  statusBarIconBrightness: Brightness.dark,)
  );
}
