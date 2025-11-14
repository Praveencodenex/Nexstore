import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/utils/assets.dart';
import 'package:thenexstore/utils/size_config.dart';
import 'package:thenexstore/utils/snack_bar.dart';
import '../../data/models/address_model.dart';
import '../../data/providers/address_provider.dart';
import '../../routes/navigator_services.dart';
import '../../routes/routes_names.dart';
import '../../utils/constants.dart';
import '../components/custom_bottom_sheet_dialog.dart';

class AddressSuccessScreen extends StatelessWidget {
  final AddressResponse addressData;
  final Future<void> Function() onRefresh;

  const AddressSuccessScreen({
    super.key,
    required this.addressData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kPrimaryColor,
      onRefresh: onRefresh,
      child: Consumer<AddressProvider>(
        builder: (context, addressProvider, _) {
          return ListView.builder(
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            itemCount: addressData.data.length,
            itemBuilder: (context, index) {
              final address = addressData.data[index];
              return Container(
                margin: EdgeInsets.only(bottom: getProportionateScreenWidth(15)),
                padding: EdgeInsets.all(getProportionateScreenWidth(16)),
                decoration: BoxDecoration(

                  color: address.isDefault?kPrimaryColorCardBack:kWhiteColor,
                  borderRadius: BorderRadius.circular(15),
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
                          Text(
                              address.type,
                              style: bodyStyleStyleB1Bold.copyWith(fontWeight: FontWeight.w900,color: kPrimaryColor,fontSize: getProportionateScreenFont(19))
                          ),
                          SizedBox(height: getProportionateScreenWidth(5)),
                          Text(
                              "${address.contactName}, ${address.name}, ${address.address} ",
                              style: bodyStyleStyleB2SemiBold.copyWith(color: kTextColor)
                          ),

                          Text(
                              "Pin: ${address.pincode}",
                              style: bodyStyleStyleB2SemiBold.copyWith(color: kAccentTextAccentOrange)
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            NavigationService.instance.navigateTo(
                                RouteNames.addEditAddressScreen,
                                arguments: {'address': address}
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: kAppBarColor,
                                borderRadius: BorderRadius.all(Radius.circular(30))
                            ),
                            height: getProportionateScreenWidth(35),
                            width: getProportionateScreenWidth(35),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: SvgPicture.asset(
                                edit,
                                colorFilter: const ColorFilter.mode(
                                  kBlackColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: getProportionateScreenWidth(10)),
                        InkWell(
                          onTap: () => _showDeleteConfirmation(context, address.id, addressProvider),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius: BorderRadius.all(Radius.circular(30))
                            ),
                            height: getProportionateScreenWidth(35),
                            width: getProportionateScreenWidth(35),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SvgPicture.asset(
                                delete,
                                colorFilter: const ColorFilter.mode(
                                  kWhiteColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context,
      int addressId,
      AddressProvider addressProvider
      ) async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Are you sure you want to remove this address?',
          subtitle: 'This action cannot be undone',
          positiveButtonText: 'Delete',
          negativeButtonText: 'Cancel',
          onPositivePressed: () {
          },
          onNegativePressed: () {
          },
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      await addressProvider.removeAddress(addressId);
      addressProvider.deleteState.state.maybeWhen(
        loading: () {
        },
        failure: (error) {
         SnackBarUtils.showError(error.message);
        },
        orElse: () {},
      );


    }
  }
}