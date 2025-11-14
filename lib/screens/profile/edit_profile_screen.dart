import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/models/profile_model.dart';
import 'package:thenexstore/data/providers/auth_provider.dart';
import 'package:thenexstore/data/providers/profile_provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';
import 'package:thenexstore/utils/snack_bar.dart';
import '../components/common_app_bar.dart';
import '../components/custom_bottom_sheet_dialog.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';
import 'component/profile_widget.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileData profileData;

  const EditProfileScreen({
    super.key,
    required this.profileData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profileData.fName);
    _lastNameController = TextEditingController(text: widget.profileData.lName);
    _emailController = TextEditingController(text: widget.profileData.email);
    _initializeProfileData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeProfileData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.initializeFormWithData(widget.profileData);
    });
  }

  void _saveProfile(ProfileProvider profileProvider) async {
    profileProvider.firstNameController.text = _firstNameController.text;
    profileProvider.lastNameController.text = _lastNameController.text;
    profileProvider.emailController.text = _emailController.text;

     await profileProvider.updateProfile();

    profileProvider.editProfileState.state.maybeWhen(
        orElse: (){},
        success: (data){
          SnackBarUtils.showSuccess('Profile updated successfully');
          Navigator.pop(context);
        },
        failure: (error){

          SnackBarUtils.showError('Failed to update profile: ${error?.message ?? "Unknown error"}');
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: const AppBarCommon(title: 'Edit Profile',search: false,cart: true,),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: kAppBarColor,
                    borderRadius: BorderRadius.circular(15),

                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row( mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfileImagePicker(
                            localImage: profileProvider.selectedImage,
                            networkImageUrl: widget.profileData.image,
                            onImageSelected: profileProvider.setSelectedImage,
                            onImageRemoved: profileProvider.removeSelectedImage,
                            radius: 50, // Match the original radius
                            backgroundColor: Colors.grey[300]!, // Match the original background
                            iconColor: Colors.grey, // Default icon color for no image
                          ),
                        ],
                      ),
                      SizedBox(height: getProportionateScreenHeight(25)),

                      CustomTextField(
                        controller: _firstNameController,
                        focusedBorderColor: kPrimaryColor,
                        label: "First Name",
                      ),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      CustomTextField(
                        controller: _lastNameController,
                        focusedBorderColor: kPrimaryColor,
                        label: "Last Name",
                      ),
                      SizedBox(height: getProportionateScreenHeight(20)),
                      CustomTextField(
                        controller: profileProvider.phoneController,
                        focusedBorderColor: kPrimaryColor,
                        keyboardType: TextInputType.phone,
                        label: "Phone number",
                        readOnly: true,
                      ),

                      SizedBox(height: getProportionateScreenHeight(20)),
                      CustomTextField(
                        controller: _emailController,
                        focusedBorderColor: kPrimaryColor,
                        keyboardType: TextInputType.emailAddress,
                        label: "Email",
                        readOnly: true,
                      ),


                      SizedBox(height: getProportionateScreenHeight(20)),
                       Text(
                        'Gender',
                        style: bodyStyleStyleB1Bold.copyWith(color: kPrimaryColor),
                      ),
                      SizedBox(width: getProportionateScreenHeight(10)),
                      Row(
                        children: [
                          Radio<String?>(
                            value: 'male',

                            groupValue: profileProvider.gender,
                            activeColor: Colors.teal,
                            onChanged: (value) {
                              profileProvider.setGender(value);
                            },
                          ),
                           Text('Male',style: bodyStyleStyleB1Bold.copyWith(color: kPrimaryColor),),
                          SizedBox(width: getProportionateScreenHeight(16)),
                          Radio<String?>(
                            value: 'female',
                            groupValue: profileProvider.gender,
                            activeColor: Colors.teal,
                            onChanged: (value) {
                              profileProvider.setGender(value);
                            },
                          ),
                           Text('Female',style: bodyStyleStyleB1Bold.copyWith(color: kPrimaryColor),),
                        ],
                      ),
                      SizedBox(height: getProportionateScreenHeight(16)),
                      InkWell(
                        onTap: () {
                          _showDeleteConfirmation(context);
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            SizedBox(width: getProportionateScreenWidth(10)),
                            Text(
                              'Delete Account Permanently',
                              style: bodyStyleStyleB1Bold.copyWith(color: Colors.red),),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(16),
                vertical: getProportionateScreenWidth(26)),
            child: CustomButton(
              text: profileProvider.isLoading ? "Saving..." : "Save Profile",
              press: profileProvider.isLoading
                  ? null
                  : () => _saveProfile(profileProvider),
              btnColor: kPrimaryColor,
              txtColor: kWhiteColor,
            ),
          );
        },
      ),
    );
  }


  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Delete Account?',
          subtitle:
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
          positiveButtonText: 'Delete',
          negativeButtonText: 'Cancel',
          onPositivePressed: () {
            ProfileProvider  profileProvider = Provider.of<ProfileProvider>(context, listen: false);
            profileProvider.deleteAccount(widget.profileData.id);
            profileProvider.deleteAccountState.state.maybeWhen(orElse: (){},
            success: (data){
              Provider.of<AuthenticationProvider>(context, listen: false).logout();
            },failure: (error){
              SnackBarUtils.showError(error.message);
             }
            );
          },
          onNegativePressed: () {},
        );
      },
    );
    if (shouldDelete == true && context.mounted) {
      // Handle delete logic if needed
    }
  }
}