import 'package:flutter/material.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/utils/constants.dart';
import 'package:thenexstore/utils/size_config.dart';

import '../../data/models/faq_model.dart';
import '../components/common_app_bar.dart';


class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  FaqScreenState createState() => FaqScreenState();
}

class FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;

  List<FAQItem> faqItems = [
    FAQItem(
      question: "What is thenexstore?",
      answer:
      "thenexstore is a fast delivery service that brings groceries, household essentials, and daily needs to your doorstep in minutes. We partner with trusted stores in your area.",
    ),
    FAQItem(
      question: "Where is thenexstore available?",
      answer:
      "Currently, thenexstore operates Only in Mannarkkad. You can check service availability by entering your PIN code in the app.",
    ),
    FAQItem(
      question: "How do I place an order?",
      answer:
      "Open the thenexstore app.\nSelect your preferred category.\nAdd items to your cart.\nProceed to checkout.\nConfirm your delivery address and payment method.\nPlace your order.\nYou will receive an order confirmation.",
    ),
    FAQItem(
      question: "What are the delivery hours?",
      answer:
      "Our delivery hours typically run from 8 AM to 10 PM every day. Hours may vary by location or during holidays.",
    ),
    FAQItem(
      question: "How long does delivery take?",
      answer:
      "Orders are delivered within 15 minutes, depending on your location and traffic it may vary.",
    ),
    FAQItem(
      question: "What payment methods are accepted?",
      answer:
      "We accept:\nUPI (Google Pay, PhonePe, Paytm)\nDebit and Credit Cards\nNet Banking\nCash on Delivery",
    ),
    FAQItem(
      question: "Is there a delivery fee?",
      answer:
      "A delivery fee may apply based on your order value and distance. The exact fee will be displayed at checkout before you place your order.",
    ),
    FAQItem(
      question: "What if an item is missing or damaged?",
      answer:
      "If any item is missing or damaged:\nOur delivery partner will verify the products in the order before completing the order.",
    ),
    FAQItem(
      question: "Can I cancel an order?",
      answer:
      "You can cancel an order within one minute of placing the order. After the time period, cancellation may not be possible. To cancel:\nGo to your orders in the app.\nTap “Cancel Order.”\nIf cancellation is successful, you will see confirmation on screen.",
    ),
    FAQItem(
      question: "How do I contact customer support?",
      answer:
      "You can reach our support team through:\nEmail: Info@thenexstore.com\nPhone: +91 9207060400",
    ),
    FAQItem(
      question: "How do I update my delivery address?",
      answer:
      "To update your address:\nGo to “My Account.”\nSelect “Addresses.”\nAdd or edit your address details.\nSet your preferred address as default.",
    ),
    FAQItem(
      question: "Are my payments secure?",
      answer:
      "Yes. We use secure payment gateways and encryption to protect your payment information. Your card or UPI details are never stored on our servers.",
    ),
    FAQItem(
      question: "How do I provide feedback?",
      answer:
      "After each order, you can rate your experience and leave feedback. Your input helps us improve our service.\nIf you have any other questions, please contact our support team. We are here to help you.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:kAppBarColor,
      appBar: const AppBarCommon(title: "FAQ",search: false,cart: true,),
      body: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ListView(
          padding: EdgeInsets.all(getProportionateScreenWidth(16)),
          children: faqItems.asMap().entries.map((entry) {
            int index = entry.key;
            FAQItem item = entry.value;
            return Container(
              decoration: const BoxDecoration(

                color: kWhiteColor,
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              margin: EdgeInsets.symmetric(vertical: getProportionateScreenWidth(6)),
              padding: EdgeInsets.symmetric(vertical: getProportionateScreenWidth(10)),
              child: ExpansionTile(
                title: Text(
                  item.question,
                  style: bodyStyleStyleB2SemiBold.copyWith(color: kPrimaryColor)
              ),
                trailing: Container(
                  padding: EdgeInsets.all(getProportionateScreenWidth(6)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Icon(
                    index == _expandedIndex
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: kAccentTextAccentOrange,
                    size: 25,
                  ),
                ),
                initiallyExpanded: index == _expandedIndex,
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    _expandedIndex = expanded ? index : null;
                  });
                },
                children: [
                  Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(10)),
                    child: Text(
                      item.answer,
                      style: bodyStyleStyleB3.copyWith(color: kTextColor),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),

      ),

    );
  }
}