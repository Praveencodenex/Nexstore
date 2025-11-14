// add_edit_address_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import '../components/common_app_bar.dart';
import '../../data/models/address_model.dart';
import '../../data/providers/address_provider.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import 'components/address_type.dart';
import 'location_pick_screen.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().clearLocationData();
      context.read<AddressProvider>().initializeForm(widget.address);

    });
  }

  Future<void> _pickLocation(context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );
    if (result != null) {
      final addressProvider = context.read<AddressProvider>();
      String locationName = addressProvider.pickedAddress.split(',').first.trim();

      addressProvider.nameController.text = locationName;
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final addressProvider = context.read<AddressProvider>();

    try {
      if (widget.address == null) {
        await addressProvider.addAddress(
          addressProvider.nameController.text,
          addressProvider.userNameController.text,
          addressProvider.addressController.text,
          addressProvider.pincodeController.text,
          addressProvider.selectedType,
          addressProvider.selectedLocation.latitude.toString(),
          addressProvider.selectedLocation.longitude.toString(),
          addressProvider.isDefaultAddress,
          addressProvider.phoneController.text,
          addressProvider.instructionsController.text,
        );
      } else {
        await addressProvider.updateToCart(
          addressProvider.nameController.text,
          addressProvider.userNameController.text,
          addressProvider.addressController.text,
          addressProvider.pincodeController.text,
          widget.address!.id.toString(),
          addressProvider.selectedType,
          addressProvider.selectedLocation.latitude.toString(),
          addressProvider.selectedLocation.longitude.toString(),
          addressProvider.isDefaultAddress,
          addressProvider.phoneController.text,
          addressProvider.instructionsController.text,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: AppBarCommon(search: false,
        title: widget.address == null ? "Add Address" : "Edit Address",
      ),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(getProportionateScreenWidth(16)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap:()=> _pickLocation(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: getProportionateScreenWidth(16)),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child:Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: kAccentTextAccentOrange,
                                size: getProportionateScreenWidth(24),
                              ),
                              SizedBox(width: getProportionateScreenWidth(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      addressProvider.pickedAddress.isNotEmpty
                                          ? addressProvider.pickedAddress.split(',').first
                                          : widget.address == null ?'Select Location':'Update Location',
                                      style: TextStyle(
                                        fontSize: getProportionateScreenWidth(16),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (addressProvider.pickedAddress.isNotEmpty)
                                      Text(
                                        addressProvider.pickedAddress,
                                        style: TextStyle(
                                          fontSize: getProportionateScreenWidth(12),
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: getProportionateScreenWidth(16),
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: getProportionateScreenHeight(16)),

                    CustomTextField(
                      controller: addressProvider.userNameController,
                      focusedBorderColor: kPrimaryColor,
                      label: "User name",
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter user name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(16)),

                    CustomTextField(
                      controller: addressProvider.nameController,
                      focusedBorderColor: kPrimaryColor,
                      label: "Address name",
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter address name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(16)),

                    CustomTextField(
                      controller: addressProvider.addressController,
                      focusedBorderColor: kPrimaryColor,
                      label: "Full address",
                      maxLines: 3,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter full address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(16)),

                    CustomTextField(
                      controller: addressProvider.pincodeController,
                      label: "Pincode",
                      keyboardType: TextInputType.number,
                      focusedBorderColor: kPrimaryColor,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter pincode';
                        }
                        if (value!.length != 6) {
                          return 'Please enter valid pincode';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(16)),

                    CustomTextField(
                      controller: addressProvider.phoneController,
                      label: "Phone Number",
                      keyboardType: TextInputType.phone,
                      focusedBorderColor: kPrimaryColor,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter phone number';
                        }
                        if (value!.length != 10) {
                          return 'Please enter valid phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(24)),

                    Text("Address Type", style: bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor)),
                    SizedBox(height: getProportionateScreenHeight(12)),

                    Row(
                      children: [
                        AddressTypeButton(
                          type: "Home",
                          isSelected: addressProvider.selectedType == "home",
                          onTap: () => addressProvider.setType("home"),
                        ),
                        SizedBox(width: getProportionateScreenWidth(16)),
                        AddressTypeButton(
                          type: "Work",
                          isSelected: addressProvider.selectedType == "work",
                          onTap: () => addressProvider.setType("work"),
                        ),
                      ],
                    ),

                    if (addressProvider.selectedType == "work") ...[
                      SizedBox(height: getProportionateScreenHeight(4)),
                      Text(
                        "(Work time: 9 AM to 6 PM)",
                        style: bodyStyleStyleB3.copyWith(color: kTextColor),
                      ),
                    ],

                    SizedBox(height: getProportionateScreenHeight(25)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: getProportionateScreenWidth(12),
                        vertical: getProportionateScreenHeight(8),
                      ),
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Set as Default Address",
                                style: bodyStyleStyleB2Bold.copyWith(color: kPrimaryColor),
                              ),
                              Text(
                                "Use this as your primary address",
                                style: bodyStyleStyleB3.copyWith(
                                  color: kSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: addressProvider.isDefaultAddress,
                            onChanged: (value) => addressProvider.setDefaultAddress(value),
                            activeColor: kPrimaryColor,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: getProportionateScreenHeight(25)),

                    CustomTextField(
                      controller: addressProvider.instructionsController,
                      focusedBorderColor: kPrimaryColor,
                      label: "Additional Instructions",
                      maxLines: 3,
                    ),

                    SizedBox(height: getProportionateScreenHeight(24)),

                    CustomButton(
                      text: addressProvider.isLoading ? "Saving..." : "Save Address",
                      press: addressProvider.isLoading ? null : _saveAddress,
                      btnColor: kPrimaryColor,
                      txtColor: kWhiteColor,
                    ),
                    SizedBox(height: getProportionateScreenHeight(16)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}