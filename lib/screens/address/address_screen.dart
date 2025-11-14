import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/screens/components/common_app_bar.dart';
import 'package:thenexstore/screens/components/custom_button.dart';
import 'package:thenexstore/utils/size_config.dart';
import 'address_success_screen.dart';
import '../../data/providers/address_provider.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import 'components/address_loader.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarCommon(title: "Address",cart: true),
      backgroundColor: kAppBarColor,
      body: SafeArea(
        child: Column(
          children: [
           SizedBox(height: getProportionateScreenHeight(10),),
            // Address List with API Integration
            Expanded(
              child: Consumer<AddressProvider>(
                builder: (context, provider, child) {
                  return provider.addressState.state.when(
                    initial: () => const AddressLoader(),
                    loading: () => const AddressLoader(),
                    success: (addressData) {
                      if (addressData.data.isEmpty) {
                        return const NoDataScreen(
                          title: "Address",
                          subTitle: "No address fount",
                          icon: emptyError,
                        );
                      }
                      return AddressSuccessScreen(
                        onRefresh: () => _fetchData(forceRefresh: true),
                        addressData: addressData,
                      );
                    },
                    failure: (error) => ErrorScreenNew(
                      error: error,
                      onRetry: () =>
                          provider.fetchAddressData(forceRefresh: true),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16),vertical: getProportionateScreenHeight(16)),
              child: CustomButton(text: 'Add New Address',
                  btnColor: kPrimaryColor,
                  txtColor: kWhiteColor,
                  press: () {
                NavigationService.instance.navigateTo(RouteNames.addEditAddressScreen,arguments: {'address': null});
                },),
            ),

          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData(forceRefresh: false);
  }

  Future<void> _fetchData({required bool forceRefresh}) async {
    if (!mounted) return;
    await context.read<AddressProvider>().fetchAddressData(
      forceRefresh: forceRefresh,
    );
  }
}
