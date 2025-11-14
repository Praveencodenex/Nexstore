import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/routes/routes_names.dart';
import '../../data/models/home_model.dart';
import '../../data/providers/home_provider.dart';
import '../../routes/navigator_services.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import 'components/product_card.dart';
import 'components/countdown_timer.dart'; // Import the new widget

class HomeSuccessScreen extends StatelessWidget {
  final HomeResponse homeData;
  final Future<void> Function() onRefresh;

  const HomeSuccessScreen({
    super.key,
    required this.homeData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kPrimaryColor,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            InkWell(
              onTap: (){
                NavigationService.instance.navigateTo(RouteNames.searchScreen);
              },
              child: Container(
                margin: EdgeInsets.only(
                  left: getProportionateScreenWidth(16),
                  right: getProportionateScreenHeight(16),
                  top: getProportionateScreenHeight(0),
                  bottom: getProportionateScreenHeight(8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                  vertical: getProportionateScreenHeight(16),
                ),
                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      searchIcon,
                      height: getProportionateScreenWidth(26),
                    ),
                    SizedBox(width: getProportionateScreenWidth(12)),
                    Expanded(
                      child: Text(
                        'Search products and stores',
                        style: bodyStyleStyleB1Bold.copyWith(
                          color: kBlackColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Banner
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(16),
                vertical: getProportionateScreenHeight(8),
              ),
              height: getProportionateScreenHeight(160),
              child: _BannerSlider(banners: homeData.data.banners),
            ),

            SizedBox(height: getProportionateScreenHeight(20)),

            // Categories
            SizedBox(
              height: getProportionateScreenHeight(100),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                ),
                itemCount: homeData.data.categories.length,
                itemBuilder: (context, index) {
                  final category = homeData.data.categories[index];
                  return Container(
                    width: getProportionateScreenWidth(70),
                    margin: EdgeInsets.only(
                      right: getProportionateScreenWidth(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: kWhiteColor,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: CachedNetworkImage(
                                imageUrl: category.icon,
                                fit: BoxFit.contain,
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.category,
                                  size: 30,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: bodyStyleStyleB25.copyWith(
                            color: kPrimaryColor,
                            letterSpacing: 0,fontWeight: FontWeight.w800
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(15)),

            // Flash Sale Header with Countdown
            const FlashSaleCountdownWidget(),


            Container(margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16),vertical: getProportionateScreenHeight(16)),
              child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Top Products',
                        style: bodyStyleStyleB0.copyWith(color: kPrimaryColor),
                      ),
                    ],
                  ),
                  Text(
                    'See More',
                    style: bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor),
                  ),
                ],
              ),
            ),


            // Products Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(16),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: homeData.data.topProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(product: homeData.data.topProducts[index]);
              },
            ),

            SizedBox(height: getProportionateScreenHeight(100)),
          ],
        ),
      ),
    );
  }
}

class _BannerSlider extends StatefulWidget {
  final List<Banners> banners;

  const _BannerSlider({required this.banners});

  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _current = index),
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.banners[index].image,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                    (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}