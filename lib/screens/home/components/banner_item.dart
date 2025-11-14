import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/models/home_model.dart';

class BannerItem extends StatelessWidget {
  final Banners banner;

  const BannerItem({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(banner.image,),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}