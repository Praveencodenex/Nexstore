import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thenexstore/data/providers/providers.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../utils/utility.dart';
import '../common/error_screen_new.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/profile_provider.dart';
import '../../data/models/profile_model.dart';
import '../components/custom_bottom_sheet_dialog.dart';
import '../components/language_bottom_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchData(forceRefresh: false);
      }
    });
  }

  Future<void> _fetchData({required bool forceRefresh}) async {
    if (!mounted) return;
    await context.read<ProfileProvider>().fetchProfile(
      forceRefresh: forceRefresh,
    );
  }

  void _handleProfileEdit(BuildContext context, ProfileData profileData) {
    NavigationService.instance.navigateTo(
        RouteNames.editProfileScreen,
        arguments: {'profileData': profileData}
    );
  }

  void _handleWishlist(BuildContext context) {
    NavigationService.instance.navigateTo(RouteNames.wishListScreen);
  }

  void _handleAddressBook(BuildContext context) {
    NavigationService.instance.navigateTo(RouteNames.addressScreen);
  }

  void _handleShareApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing app...')),
    );
  }

  void _handleAboutUs(String url) {
    launchAnyUrl(url);
  }

  void _handleNotifications(BuildContext context) {
    NavigationService.instance.navigateTo(RouteNames.notificationScreen);
  }

  void _handleTermsConditions(String url) {
    launchAnyUrl(url);
  }

  void _handleSupport(BuildContext context) {
    NavigationService.instance.navigateTo(RouteNames.contactScreen);
  }

  void _handleFAQs(BuildContext context) {
    NavigationService.instance.navigateTo(RouteNames.faqScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: const AppBarCommon(title: "Settings",isBottom: true,),

      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return provider.profileState.state.when(
            initial: () => _buildShimmerLoading(),
            loading: () => _buildShimmerLoading(),
            success: (profileResponse) {
              return _buildSettingsContent(context, profileResponse.data);
            },
            failure: (error) => ErrorScreenNew(
              error: error,
              onRetry: () => provider.fetchProfile(forceRefresh: true),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(getProportionateScreenWidth(20)),
                  padding: EdgeInsets.all(getProportionateScreenWidth(20)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: getProportionateScreenWidth(15)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 120,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, ProfileData profileData) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Card
          Container(
            margin: EdgeInsets.all(getProportionateScreenWidth(16)),
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(15),

            ),
            child: Row(
              children: [
                // Profile Picture
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kPrimaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: profileData.image != null
                        ? Image.network(
                      profileData.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        color: kPrimaryColor,
                        size: 35,
                      ),
                    ) : const Icon(
                      Icons.person,
                      color: kPrimaryColor,
                      size: 35,
                    ),
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(15)),
                // Name and Phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileData.fullName,
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(18),
                          fontWeight: FontWeight.bold,
                          color: kWhiteColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profileData.phone!=""?profileData.phone:"No Phone",
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(14),
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit Icon
                GestureDetector(
                  onTap: () => _handleProfileEdit(context, profileData),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kAccentTextAccentYellow,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: kPrimaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // General Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'General',
                    style: bodyStyleStyleB0.copyWith(color: kPrimaryColor),
                  ),
                ),
                _buildSettingsItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Your Orders',
                  onTap: () => NavigationService.instance.navigateTo(RouteNames.orderScreen,arguments: {'backNeeded': true}),
                ),
                _buildSettingsItem(
                  icon: Icons.location_on_outlined,
                  title: 'Address Book',
                  onTap: () => _handleAddressBook(context),
                ),
                _buildSettingsItem(
                  icon: Icons.share_outlined,
                  title: 'Share the app',
                  onTap: () => _handleShareApp(context),
                ),
                _buildSettingsItem(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () => _handleAboutUs("https://thenexstore.com"),
                ),
                _buildSettingsItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () => _handleNotifications(context),
                  showDivider: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Preferences Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'Preferences',
                    style: bodyStyleStyleB0.copyWith(color: kPrimaryColor),
                  ),
                ),
                _buildSettingsItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () => _handleTermsConditions("https://thenexstore.com/terms-and-conditions"),
                ),

                /*_buildSettingsItem(
                  icon: Icons.language,
                  title: 'Language',
                  onTap: () => _showLanguageBottomSheet(),
                ),*/
                _buildSettingsItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Support & Contact',
                  onTap: () => _handleSupport(context),
                ),
                _buildSettingsItem(
                  icon: Icons.question_answer_outlined,
                  title: 'FAQs',
                  onTap: () => _handleFAQs(context),
                ),
                _buildSettingsItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () => _showLogoutConfirmation(context),
                  showDivider: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const LanguageBottomSheet(),
      ),
    );
  }


  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kAppBarColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? kPrimaryColor,
                    size: 22,
                  ),
                ),
                SizedBox(width: getProportionateScreenWidth(15)),
                Expanded(
                  child: Text(
                    title,
                    style: bodyStyleStyleB25.copyWith(
                        color: kBlackColor,fontSize: getProportionateScreenFont(16),
                        letterSpacing: 0,fontWeight: FontWeight.w800
                    ),),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: kPrimaryColor,
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: 'Logout Account?',
          subtitle: 'Are you sure you want to logout your account? This action cannot be undone.',
          positiveButtonText: 'Logout',
          negativeButtonText: 'Cancel',
          onPositivePressed: () async {
            await Provider.of<UserProvider>(context, listen: false).setCurrentIndex(0);
            await Provider.of<AuthenticationProvider>(context, listen: false).logout();
          },
          onNegativePressed: () {},
        );
      },
    );
    if (shouldDelete == true && context.mounted) {
      // Handle logout logic if needed
    }
  }
}