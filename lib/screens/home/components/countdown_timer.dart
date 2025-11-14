import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/home_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';

class FlashSaleCountdownWidget extends StatelessWidget {
  const FlashSaleCountdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HomeDataProvider>();

    return ValueListenableBuilder<Duration>(
      valueListenable: provider.timeRemainingNotifier,
      builder: (context, timeRemaining, child) {
        if (timeRemaining == Duration.zero) {
          return const SizedBox.shrink();
        }

        final hours = timeRemaining.inHours.remainder(24);
        final minutes = timeRemaining.inMinutes.remainder(60);
        final seconds = timeRemaining.inSeconds.remainder(60);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Flash Sale',
                    style: bodyStyleStyleB0.copyWith(color: kPrimaryColor),
                  ),
                  SizedBox(width: getProportionateScreenWidth(8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(8),
                      vertical: getProportionateScreenHeight(4),
                    ),
                    decoration: BoxDecoration(
                      color: kAccentTextAccentOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getProportionateScreenWidth(13),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'See More',
                style: bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor),
              ),
            ],
          ),
        );
      },
    );
  }
}