import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thenexstore/utils/size_config.dart';

import '../../utils/constants.dart';

class ProductLoader extends StatelessWidget {
  const ProductLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.67,
        crossAxisSpacing:  getProportionateScreenHeight(16),
        mainAxisSpacing:  getProportionateScreenHeight(16),
      ),
      itemCount: 4, // Number of shimmer items to show
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: kAppBarColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image placeholder
                Container(
                  height: getProportionateScreenHeight(200),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name placeholder
                      Container(
                        width: double.infinity,
                        height:  getProportionateScreenHeight(25),
                        color: Colors.white,
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
