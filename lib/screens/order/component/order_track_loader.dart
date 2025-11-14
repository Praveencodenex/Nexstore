import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OrderTrackLoader extends StatelessWidget {
  const OrderTrackLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header

                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                ...List.generate(6, (index) => _timelineItem()),
                const SizedBox(height: 12),
                const SizedBox(height: 24),
                _buttonPlaceholder(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _timelineItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step icon
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Text blocks
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 180, height: 14, color: Colors.white),
              const SizedBox(height: 8),
              Container(width: 100, height: 12, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buttonPlaceholder() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
