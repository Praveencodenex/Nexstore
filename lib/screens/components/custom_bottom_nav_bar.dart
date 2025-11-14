import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thenexstore/screens/account/settings_screen.dart';
import 'package:thenexstore/screens/order/order_screen.dart';
import 'package:thenexstore/screens/wishlist/wishlist_screen.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';
import 'package:provider/provider.dart';
import '../../data/providers/user_provider.dart';
import '../../utils/assets.dart';
import '../category/category_screen.dart';
import '../home/home_screen.dart';
import '../order/reorder_screen.dart';


class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});
  @override
  State<CustomBottomNavBar> createState() => _BottomNavigationBarState();
}

class NavItem {
  final String label;
  final String svgPath;

  const NavItem(this.label, this.svgPath);
}

class _BottomNavigationBarState extends State<CustomBottomNavBar> {

  final List _pages = [
    const HomeScreen(),
    const CategoryScreen(),
    const WishListScreen(),
    const OrderScreen(backNeeded: false,),
    const SettingsScreen(),
  ];

  final List<NavItem> navItems = const [
    NavItem('Home', home),
    NavItem('Category', category),
    NavItem('Favorite', fav),
    NavItem('Orders', order),
    NavItem('Account', account),
  ];

  _changeTab(int index, themeNotifier) {
    themeNotifier.setCurrentIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Scaffold(
            extendBody: true, // Add this line
            backgroundColor: kWhiteColor,
            body: _pages[userProvider.currentIndex],
            bottomNavigationBar: Container(
              margin: const EdgeInsets.all(16),
              height: Platform.isAndroid ? 70 : 80,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(navItems.length, (index) {
                    return _buildNavButton(
                      navItems[index],
                      index,
                      userProvider.currentIndex == index,
                          () => _changeTab(index, userProvider),
                    );
                  }),
                ),
              ),
            ),
          );
        }
    );
  }

  Widget _buildNavButton(NavItem item, int index, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ?kAccentTextAccentYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              item.svgPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isSelected ? kPrimaryColor : Colors.white,
                BlendMode.srcIn,
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: kPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}