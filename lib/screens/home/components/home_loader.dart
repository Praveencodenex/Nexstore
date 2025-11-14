import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';

class HomeLoader extends StatelessWidget {
  const HomeLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: getProportionateScreenHeight(5),),
                Row(
                  children: [
                    _buildShimmerBox(height: getProportionateScreenHeight(30), width: getProportionateScreenWidth(200)),

                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(20),),

                // Banner

                _buildShimmerBox(height: getProportionateScreenHeight(200), width: double.infinity, radius: 12),


                SizedBox(height: getProportionateScreenHeight(15),),
                // Timer Section
                Row(
                  children: [
                    _buildShimmerBox(height: getProportionateScreenHeight(30), width: getProportionateScreenWidth(200)),

                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(15),),
                // Grid Categories
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: List.generate(8, (index) => _buildShimmerGridItem()),
                  ),
                ),
               SizedBox(height: getProportionateScreenHeight(15),),
                // Timer Section
                Row(
                  children: [
                    _buildShimmerBox(height: getProportionateScreenHeight(30), width: getProportionateScreenWidth(200)),

                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(15),),
                // Grid Categories
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: List.generate(8, (index) => _buildShimmerGridItem()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double height,
    required double width,
    double radius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }


  Widget _buildShimmerGridItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: getProportionateScreenHeight(80),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}