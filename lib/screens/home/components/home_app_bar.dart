import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/utils/size_config.dart';

import '../../../routes/navigator_services.dart';
import '../../../routes/routes_names.dart';
import '../../../utils/assets.dart';
import '../../../utils/constants.dart';
import '../../../data/providers/cart_provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      surfaceTintColor: Colors.transparent, // Add this to prevent color tinting
      scrolledUnderElevation: 0,
      backgroundColor: kAppBarColor,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: kAppBarColor,
        statusBarIconBrightness: Brightness.dark,
      ),
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Image.asset(logo, height: getProportionateScreenHeight(40)),
      actions: [

        GestureDetector(onTap: (){
          NavigationService.instance.navigateTo(RouteNames.notificationScreen);
        },
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SvgPicture.asset(
                notification,
                height: getProportionateScreenHeight(23),
              ),
            ),
          ),
        ),
        // Cart Icon with Badge
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            int totalItems = 0;
            cartProvider.cartState.state.maybeWhen(
              success: (response) {
                totalItems = response.meta.totalItems;
              },
              orElse: () {},
            );

            return GestureDetector(onTap: (){
              NavigationService.instance.navigateTo(RouteNames.cartScreen);
            },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SvgPicture.asset(
                        cartIcon,
                        height: getProportionateScreenHeight(23),
                      ),
                      if (totalItems > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF3B30),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              totalItems > 99 ? '99+' : '$totalItems',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // Notification Icon

      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}