import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/utils/utility.dart';
import '../../data/providers/auth_provider.dart';

import '../../routes/navigator_services.dart';
import '../../routes/routes_names.dart';
import '../../utils/assets.dart';
import '../../utils/size_config.dart';
import '../../utils/constants.dart';
import '../../utils/snack_bar.dart';
import '../components/custom_button.dart';
import '../components/custom_text_field.dart';

class EmailSignInScreen extends StatelessWidget {
  EmailSignInScreen({super.key});

  final TextEditingController _emailController = TextEditingController();

  Future<void> _handleContinue(BuildContext context) async {

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      SnackBarUtils.showError('Please enter a valid email address');
      return;
    }
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    await authProvider.loginWithEmail(_emailController.text);

    authProvider.emailLoginState.state.maybeWhen(
      success: (response) {
        NavigationService.instance.navigateTo(
          RouteNames.otpScreen,
          arguments: {
            'phone': _emailController.text,
            'isEmail': true,
          },
        );
      },
      failure: (error){
        SnackBarUtils.showError(error.message);
      },
      orElse: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: kAppBarColor,
          statusBarIconBrightness: Brightness.dark, // For Android
          statusBarBrightness: Brightness.light, // For iOS
        ),
        leading:  InkWell(
            onTap: (){
              NavigationService.instance.goBack();

            },
            child:
            Container(
              margin: const EdgeInsets.only(left: 16),
              width: 50, // Explicit width
              height: 50, // Explicit height
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0), // Reduced padding
                child: SvgPicture.asset(
                  back,
                  fit: BoxFit.contain,
                ),
              ),
            )),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(20),
            vertical: getProportionateScreenHeight(20)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Enter your email address to get started',
                style: headingH2Style.copyWith(color: kPrimaryColor)
            ),
            SizedBox(height: getProportionateScreenWidth(8)),
            Row(
              children: [
                Text(
                  'Enter your ',
                  style: bodyStyleStyleB1,
                ),
                Text(
                  'email address',
                  style: bodyStyleStyleB1.copyWith(color: kAccentTextAccentOrange),
                ),
              ],
            ),
            SizedBox(height: getProportionateScreenWidth(30)),
            CustomTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email address',
              keyboardType: TextInputType.emailAddress,
              borderRadius: 15,
              borderWidth: 1.5,
              focusedBorderColor: kPrimaryColor,
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: getProportionateScreenHeight(16)),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style:bodyStyleStyleB2SemiBold.copyWith(color: kTextColor),
                  children: [
                    const TextSpan(
                      text: 'By continuing, you agree to thenexstore ',
                    ),
                    TextSpan(
                      text: 'Terms of Service',
                      style: bodyStyleStyleB2SemiBold.copyWith(color: kPrimaryColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchAnyUrl('https://thenexstore.com/terms-and-conditions');
                        },
                    ),
                    const TextSpan(
                      text: ' and ',
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: bodyStyleStyleB2SemiBold.copyWith(color: kPrimaryColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchAnyUrl('https://thenexstore.com/privacy-policy');
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            Consumer<AuthenticationProvider>(
              builder: (context, authProvider, _) => CustomButton(
                txtColor: Colors.white,
                btnColor: kPrimaryColor,
                text: authProvider.isSendingOtp
                    ? 'Please wait...'
                    : 'Continue',
                press: authProvider.isSendingOtp
                    ? null
                    : () => _handleContinue(context),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(16),)
          ],
        ),
      ),
    );
  }

  void dispose() {
    _emailController.dispose();
  }
}