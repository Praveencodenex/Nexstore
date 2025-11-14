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
import '../../data/providers/user_provider.dart';

class AppBarCommon extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? search;
  final bool? cart;
  final bool? isBottom;
  final bool? backNeeded;
  final int? elevation;
  const AppBarCommon({required this.title, super.key, this.search, this.cart, this.elevation, this.isBottom, this.backNeeded});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0, // Add this line to prevent elevation change
      backgroundColor: kAppBarColor,
      surfaceTintColor: Colors.transparent, // Add this to prevent color tinting
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: kAppBarColor,
        statusBarIconBrightness: Brightness.dark,
      ),
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Text(title, style: bodyStyleStyleB0.copyWith(color: kPrimaryColor,fontSize: getProportionateScreenHeight(23))),
      titleSpacing: 0,
      leadingWidth: 63,
      leading:
      GestureDetector(
          onTap: (){
            if((isBottom??false)&& (backNeeded??false)) {
              NavigationService.instance.goBack();

            }
            else if((isBottom??false)) {
              Provider.of<UserProvider>(context, listen: false).setCurrentIndex(0);

            }else{
              NavigationService.instance.goBack();
            }
          },
          child:
          Container(
            margin: const EdgeInsets.only(left: 16),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                back,
                fit: BoxFit.contain,
              ),
            ),
          )),
      actions: [
        cart??true?  Consumer<CartProvider>(
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
        ):const SizedBox(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}