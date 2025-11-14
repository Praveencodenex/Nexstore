import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/utils/size_config.dart';

import '../../data/providers/cart_provider.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';


class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool? search;
  final bool? cart;
  final int? elevation;

  const CommonAppBar({required this.title, super.key, this.search, this.cart, this.elevation});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: elevation==null?[
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ]:null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: true,
            elevation: 0,
            title: Text(title, style: headingH3Style),
            centerTitle: true,
            actions: [
              search==null?IconButton(
                icon: SvgPicture.asset(searchIcon),
                onPressed: () {
                  NavigationService.instance.navigateTo(RouteNames.searchScreen);
                },
              ):const SizedBox(),

              cart!=null? _buildCartIcon():const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildCartIcon( ) {
    return Padding(padding: EdgeInsets.only(right: getProportionateScreenWidth(15)),
      child: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          // Get total items from cart state
          int totalItems = 0;
          cartProvider.cartState.state.maybeWhen(
            success: (response) {
              totalItems = response.meta.totalItems;
            },
            orElse: () {},
          );

          return InkWell(onTap: (){
            NavigationService.instance.navigateTo(RouteNames.cartScreen,arguments: {"isBottom":false});
          },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(carts,height: getProportionateScreenWidth(20),),

                if (totalItems > 0)
                  Positioned(
                    right: -7,
                    top: -8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          totalItems > 99 ? '99+' : totalItems.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10  ,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  @override
  Size get preferredSize =>
      Size.fromHeight(getProportionateScreenHeight(65));
}