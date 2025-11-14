import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../data/models/intro_model.dart';
import '../../routes/navigator_services.dart';
import '../../routes/routes_names.dart';
import '../../utils/assets.dart';
import '../components/custom_button.dart';
import 'components/intro_item.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: intro1,
      title: 'Groceries in 15 Minutes!',
      description: 'Fresh groceries, delivered faster than ever just 15 minutes',
    ),
    OnboardingData(
      image: intro2,
      title: 'Shopping without stress',
      description: 'Quickly search and add healthy food to your cart',
    ),
    OnboardingData(
      image: intro3,
      title: 'Let’s get started!',
      description: 'Choose a way to login or signup',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
        
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),
            Column(
              children: [
                // In the _OnboardingScreenState class, update the Row widget containing the indicators:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: getProportionateScreenWidth(8),
                      width: _currentPage == index ? 32 : 10, // Wider when active
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6), // Rounded corners
                        color: _currentPage == index
                            ? kPrimaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
                 SizedBox(height: getProportionateScreenWidth(30)),
                CustomButton(
                  txtColor: Colors.white,
                  btnColor: kPrimaryColor,
                  text: _currentPage < _pages.length - 1
                      ? 'Next'
                      : 'Get Started',
                  press: () async{
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      await NavigationService.instance.pushReplacementNamed(RouteNames.login,);
                    }

                  },
                ),

                SizedBox(height: getProportionateScreenWidth(26)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


