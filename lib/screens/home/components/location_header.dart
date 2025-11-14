import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/address_provider.dart';
import '../../../utils/size_config.dart';
import '../../../utils/constants.dart';
import '../../address/location_pick_screen.dart';

class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        String displayAddress = addressProvider.pickedAddress.isNotEmpty
            ? addressProvider.pickedAddress.split(',').first
            : addressProvider.selectedAddress?.address.split(',').first ??
            'Select Location';

        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const LocationPickerScreen()),
            );

            if (result != null && result is Map<String, dynamic>) {
              addressProvider.pickedAddress = result['address'];
              addressProvider.updateLocation(
                LatLng(
                  double.parse(result['latitude']),
                  double.parse(result['longitude']),
                ),
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(16),
              vertical: getProportionateScreenHeight(12),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: kPrimaryColor,
                  size: getProportionateScreenWidth(24),
                ),
                SizedBox(width: getProportionateScreenWidth(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deliver to',
                        style: TextStyle(
                          fontSize: getProportionateScreenFont(12),
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        displayAddress,
                        style: TextStyle(
                          fontSize: getProportionateScreenFont(14),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black,
                  size: getProportionateScreenWidth(24),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}