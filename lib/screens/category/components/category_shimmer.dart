import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/constants.dart';

class CategoryLoader extends StatelessWidget {
  const CategoryLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCategoryGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height, {double radius = 4}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 9,
      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildShimmerBox(120, 120),
            const SizedBox(height: 8),
            _buildShimmerBox(60, 12),
          ],
        );
      },
    );
  }

}