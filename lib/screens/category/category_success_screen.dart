import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import 'components/category_image_cards.dart';

class CategorySuccessScreen extends StatelessWidget {
  final CategoryModel categoryData;
  final Future<void> Function() onRefresh;

  const CategorySuccessScreen({
    super.key,
    required this.categoryData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: categoryData.data.length + 1, // +1 for the banner
        itemBuilder: (context, index) {
          // First item is the banner
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              child: Image.asset(catBanner),
            );
          }

          // Remaining items are categories
          final category = categoryData.data[index - 1];
          return CategorySection(category: category);
        },
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final Category category;

  const CategorySection({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: SizeConfig.screenWidth,
          padding: EdgeInsets.only(
            left: getProportionateScreenWidth(16),
            right: getProportionateScreenWidth(16),
            top: getProportionateScreenHeight(8),
          ),
          child: Text(
            category.name,
            style: bodyStyleStyleB0.copyWith(color: kPrimaryColor),
          ),
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.60,
            crossAxisSpacing: getProportionateScreenHeight(10),
            mainAxisSpacing: getProportionateScreenHeight(10),
          ),
          itemCount: category.subCategories.length,
          itemBuilder: (context, index) {
            final subCategory = category.subCategories[index];
            return SubCategoryCard(subCategory: subCategory);
          },
        ),
      ],
    );
  }
}