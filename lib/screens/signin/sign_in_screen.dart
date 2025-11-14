import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/providers/providers.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../components/custom_button.dart';

class LoginSignupScreen extends StatelessWidget {
  const LoginSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kAppBarColor,
        toolbarHeight: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: kAppBarColor,
          statusBarIconBrightness: Brightness.dark, // For Android
          statusBarBrightness: Brightness.light, // For iOS
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20),vertical: getProportionateScreenHeight(20)),
          child: Column(
            children: [
              // Illustration image
              SvgPicture.asset(
                login, // Add your image path here
                height: getProportionateScreenHeight(300),
                fit: BoxFit.contain,
              ),

              SizedBox(height: getProportionateScreenHeight(40)),

              Text(
                "Let's get started!",
                style: headingH2Style.copyWith(color: kPrimaryColor)
              ),

              SizedBox(height: getProportionateScreenHeight(8)),

              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Choose a way to login",
                    style:bodyStyleStyleB1
                  ),Text(
                    " or signup",
                    style:bodyStyleStyleB1.copyWith(color: kAccentTextAccentOrange)
                  ),
                ],
              ),

              SizedBox(height: getProportionateScreenHeight(40)),

              // Email Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, getProportionateScreenHeight(50)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                    side: const BorderSide(color: kPrimaryColor,width: 0.5),
                  ),
                ),
                onPressed: () {
                  NavigationService.instance.navigateTo(RouteNames.emailLogin);
                },
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email_outlined,color: kPrimaryColor,),
                    SizedBox(width: getProportionateScreenWidth(10)),
                    Text('Login with Email',style: buttonStyleStyle,),
                  ],
                ),
              ),

              SizedBox(height: getProportionateScreenWidth(16)),

              CustomButton(
                  txtColor:kWhiteColor,
                  btnColor: kPrimaryColor,
                  text: 'Continue with Phone',
                  icon: callFilled,
                  press: () {
                    Navigator.pushNamed(context, RouteNames.mobileLoginScreen);
                  }
              ),

              SizedBox(height: getProportionateScreenWidth(20)),
               Row(
                children: [
                  const Expanded(child: Divider()),
                  Text(' or ',
                    style: bodyStyleStyleB1.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              SizedBox(height: getProportionateScreenWidth(20)),
              // Guest Link
              TextButton(
                onPressed: () {
                  Provider.of<UserProvider>(context,listen: false).setCurrentIndex(0);
                  Navigator.pushNamed(context, RouteNames.customBottomNavBar);
                },
                child: Text(
                  'Continue as a guest',
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}