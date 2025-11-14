import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';


class AddressLoader extends StatelessWidget {
  const AddressLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: EdgeInsets.all(getProportionateScreenWidth(16)),
        itemCount: 4, // Show 4 shimmer items
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: getProportionateScreenWidth(15)),
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 0.8),
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Address type shimmer
                      Container(
                        height: getProportionateScreenHeight(18),
                        width: getProportionateScreenWidth(80),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: getProportionateScreenWidth(8)),

                      // Address line 1 shimmer
                      Container(
                        height: getProportionateScreenHeight(14),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: getProportionateScreenWidth(6)),

                      // Address line 2 shimmer
                      Container(
                        height: getProportionateScreenHeight(14),
                        width: getProportionateScreenWidth(180),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Edit button shimmer
                    Container(
                      height: getProportionateScreenWidth(32),
                      width: getProportionateScreenWidth(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(width: getProportionateScreenWidth(10)),

                    // Delete button shimmer
                    Container(
                      height: getProportionateScreenWidth(32),
                      width: getProportionateScreenWidth(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}