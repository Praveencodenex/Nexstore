import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/size_config.dart';
import '../../../data/models/home_model.dart';
import '../../../data/providers/home_provider.dart';
import 'banner_indicator.dart';
import 'banner_item.dart';

class BannerSlider extends StatelessWidget {
  final List<Banners> banners;

  const BannerSlider({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeDataProvider>(context);

    return SizedBox(
      height: getProportionateScreenHeight(190),
      child: Stack(
        children: [
          PageView.builder(
            controller: homeProvider.bannerController,
            onPageChanged: homeProvider.changeBannerPage,
            itemCount: banners.length,
            itemBuilder: (context, index) => BannerItem(banner: banners[index]),
          ),
          if (banners.length > 1)
            BannerIndicators(
              count: banners.length,
              currentIndex: homeProvider.currentBannerIndex,
            ),
        ],
      ),
    );
  }
}