import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/address_model.dart';
import '../../../data/providers/address_provider.dart';
import '../../../routes/navigator_services.dart';
import '../../../routes/routes_names.dart';
import '../../../utils/constants.dart';
import '../../../utils/size_config.dart';
import '../../components/bottom_sheet_shimmer.dart';
import '../../components/product_list_loader.dart';

class AddressListBottomSheet extends StatefulWidget {
  final VoidCallback onClose;
  final Function(Address) onAddressSelected;

  const AddressListBottomSheet({
    super.key,
    required this.onClose,
    required this.onAddressSelected,
  });

  @override
  State<AddressListBottomSheet> createState() => _AddressListBottomSheetState();
}

class _AddressListBottomSheetState extends State<AddressListBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AddressProvider>();
      provider.fetchAddressData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: getProportionateScreenWidth(20)),

          Container(
            width: getProportionateScreenWidth(40),
            height: getProportionateScreenWidth(4),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'Select an Address',
                    style: headingH3Style.copyWith(color: kPrimaryColor)
                ),
                SizedBox(height: getProportionateScreenHeight(15)),
                Text(
                    'Select your preferred address manual selection.',
                    style: bodyStyleStyleB2.copyWith(color: kTextColor)
                ),
              ],
            ),
          ),


          Consumer<AddressProvider>(
            builder: (context, provider, _) {
              return provider.addressState.state.maybeWhen(
                initial: () => const BottomSheetShimmer(),
                loading: () => const BottomSheetShimmer(),
                success: (addressData) {
                  if (addressData.data.isEmpty) {
                    return Center(
                      child: Padding(
                        padding:  EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10),vertical: getProportionateScreenHeight(80)),
                        child: Text("No Address available", style: bodyStyleStyleB1),
                      ),
                    );
                  }

                  return Container(color: kWhiteColor,
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding:  EdgeInsets.only(left: getProportionateScreenWidth(16),right:getProportionateScreenWidth(16),bottom: getProportionateScreenHeight(25),top: getProportionateScreenHeight(16)),
                      itemCount: addressData.data.length,
                      itemBuilder: (context, index) {
                        final address = addressData.data[index];
                        final isSelected = provider.selectedAddress?.id == address.id;

                        return GestureDetector(
                          onTap: () {
                            provider.setSelectedAddress(address);
                            widget.onAddressSelected(address);
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(

                              color: isSelected ? kPrimaryColorCardBack : kAppBarColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            address.type,
                                            style: bodyStyleStyleB1Bold.copyWith(
                                              fontWeight: FontWeight.w800,color: kPrimaryColor
                                            ),
                                          ),
                                          if (address.isDefault)
                                            Container(
                                              margin: const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: kWhiteColor,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Default',
                                                style: bodyStyleStyleB3SemiBold.copyWith(
                                                  color: kAccentTextAccentOrange,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: getProportionateScreenHeight(5)),
                                      Text(
                                        "${address.contactName}, ${address.name}, ${address.address}",
                                        style: bodyStyleStyleB3SemiBold.copyWith(
                                          color: kTextColor,
                                        ),
                                      ),
                                      Text(
                                        "Pin: ${address.pincode}",
                                        style: bodyStyleStyleB3SemiBold.copyWith(
                                          color: kTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    NavigationService.instance.navigateTo(
                                      RouteNames.addEditAddressScreen,
                                      arguments: {'address': address},
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      color: kWhiteColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                failure: (error) => Center(
                  child:Padding(
                    padding:  EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10),vertical: getProportionateScreenHeight(80)),
                    child: Text("Something went wrong", style: bodyStyleStyleB1),
                  ),
                ),
                orElse: () => const ProductLoader(),
              );
            },
          ),
        ],
      ),
    );
  }
}

void showAddressSelector(
    BuildContext context,
    Function(Address) onAddressSelected,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AddressListBottomSheet(
          onClose: () => Navigator.pop(context),
          onAddressSelected: onAddressSelected,
        ),
      ),
    ),
  );
}