import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../../data/models/category_model.dart';
import '../../../routes/navigator_services.dart';

class SubCategoryCard extends StatelessWidget {
  final SubCategory subCategory;

  const SubCategoryCard({
    super.key,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.navigateTo(RouteNames.productsListingScreen,arguments:  {
        'catId':  subCategory.id,
        'catTitle': subCategory.name.toString(),
        },);
      },
      child: Column(
        children: [
          Container(
            height: getProportionateScreenHeight(90),
            width: getProportionateScreenWidth(80),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,

            ),
            child: Padding(
             padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(14)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: subCategory.icon,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) =>  Icon(
                    Icons.broken_image,
                    size: getProportionateScreenHeight(50),
                    color: kGreyColorLightMed,
                  ),
                ),
              ),
            ),
          ),
          Text(
              subCategory.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: bodyStyleStyleB3.copyWith(color: kPrimaryColor,fontWeight: FontWeight.w800)
          ),
        ],
      ),
    );
  }
}