
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thenexstore/utils/snack_bar.dart';


void makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}
void openWhatsApp(whatsappUrl) async {

  if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
    await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
  } else {
    SnackBarUtils.showError('Could not launch WhatsApp');
  }
}

void launchAnyUrl(url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
  } else {
    SnackBarUtils.showError('Could not launch WhatsApp');
  }
}


