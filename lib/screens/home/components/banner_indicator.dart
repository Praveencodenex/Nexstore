import 'package:flutter/material.dart';

class BannerIndicators extends StatelessWidget {
  final int count;
  final int currentIndex;

  const BannerIndicators({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
              (index) => Container(
            width: 16,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: currentIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
