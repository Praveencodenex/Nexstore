import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/utils/assets.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';
import 'package:thenexstore/utils/utility.dart';

import '../components/common_app_bar.dart';
import 'components/feedback_bottom_sheet.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,
      appBar: const AppBarCommon(title: "Support & Contact",search: false,cart: true,),
      body: Padding(
        padding: EdgeInsets.all(getProportionateScreenWidth(20)),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),

              ),
              child: Column(
                children: [
                  _buildContactOption(
                    icon: call,
                    title: 'Call',
                    iconColor: kPrimaryColor,
                    onTap: () => makePhoneCall("+919207060400"),
                  ),
                  _buildDivider(),
                  _buildContactOption(
                    icon: whatsapp,
                    title: 'Whatsapp',
                    iconColor: const Color(0xFF25D366),
                    onTap: () => openWhatsApp('https://wa.me/+919207060400'),
                  ),
                  _buildDivider(),
                  _buildContactOption(
                    icon: feedback,
                    title: 'Feedback',
                    iconColor: kPrimaryColor,
                    onTap: () => _showFeedbackBottomSheet(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required String  icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(20),
          vertical: getProportionateScreenWidth(16),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon
            ),
            SizedBox(width: getProportionateScreenWidth(16)),
            Text(
              title,
              style: TextStyle(
                fontSize: getProportionateScreenWidth(16),
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: getProportionateScreenWidth(16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: getProportionateScreenWidth(20),
      endIndent: getProportionateScreenWidth(20),
    );
  }




  void _showFeedbackBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeedbackBottomSheet(),
    );
  }
}
