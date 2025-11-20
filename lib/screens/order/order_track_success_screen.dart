import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thenexstore/screens/components/custom_button.dart';
import '../../data/models/order_track_model.dart';
import '../../routes/navigator_services.dart';
import '../../routes/routes_names.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../../utils/utility.dart';

class OrderTrackSuccessScreen extends StatelessWidget {
  final OrderStatusResponse orderTrackData;
  final Future<void> Function() onRefresh;

  const OrderTrackSuccessScreen({
    super.key,
    required this.orderTrackData,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus = orderTrackData.data.orderStatus.toLowerCase();

    return RefreshIndicator(
      color: kPrimaryColor,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              SvgPicture.asset(orderTrack, height: getProportionateScreenHeight(200)),


              // Order ID Card
              Container(

                decoration: BoxDecoration(
                  color: kWhiteColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding:  EdgeInsets.all(getProportionateScreenHeight(12)),
                          child: Row(
                            children: [
                              Text(
                                'Order ID: ',
                                style: bodyStyleStyleB1Bold.copyWith(color: kPrimaryColor,fontWeight: FontWeight.w900)
                              ),
                              Text(
                                '#ORD${orderTrackData.data.orderId}',
                                style: bodyStyleStyleB1Bold.copyWith(color: kAccentTextAccentOrange,fontWeight: FontWeight.w900)
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding:  EdgeInsets.all(getProportionateScreenHeight(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          SizedBox(height: getProportionateScreenHeight(20)),


                          // Simplified timeline with merged statuses
                          _buildTimelineItem(
                            isActive: _isStatusActive(['pending', 'confirmed'], currentStatus),
                            icon: pendingOrder,
                            title: 'Order Received',
                            subtitle: 'Your order has been received and is being processed',
                            isLast: false,
                          ),

                          _buildTimelineItem(
                            isActive: _isStatusActive(['processing'], currentStatus),
                            icon: pickupOrder,
                            title: 'Order Picked up',
                            subtitle: 'Your order has been prepared and picked up',
                            isLast: false,
                          ),

                          _buildTimelineItem(
                            isActive: _isStatusActive(['out_for_delivery', 'reached_at_delivery_point', 'payment_collected'], currentStatus),
                            icon: outForDelivery,
                            title: 'Out for delivery',
                            subtitle: 'Your order is on its way to your location',
                            isLast: false,
                            // Add delivery partner info if applicable
                            additionalContent: _showDeliveryPartnerInfo(currentStatus)
                                ? _buildDeliveryPartnerInfo(orderTrackData.data.deliveryAgent)
                                : null,
                          ),

                          // Delivered status
                          _buildTimelineItem(
                            isActive: _isStatusActive(['delivered'], currentStatus),
                            icon: delivered,
                            title: 'Delivered',
                            subtitle: 'Your order has been successfully delivered',
                            isLast: currentStatus != 'cancelled',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              CustomButton(text: "Need Help?", press: (){
                NavigationService.instance.navigateTo(RouteNames.contactScreen);
              },btnColor: kPrimaryColor,borderEnabled: false,txtColor: kWhiteColor,

              ),

              SizedBox(height: getProportionateScreenHeight(16)),
            ],
          ),
        ),
      ),
    );
  }

  // Updated method to build a timeline item with dynamic line height
  Widget _buildTimelineItem({
    required bool isActive,
    required String icon,
    required String title,
    String? subtitle,
    required bool isLast,
    Widget? additionalContent, // For delivery partner info
  }) {
    return Stack(
      children: [
        // Content (icon and text)
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
              Container(
                height: getProportionateScreenHeight(40),
                width: getProportionateScreenHeight(40),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFE0F2F1) : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    icon,
                    height: getProportionateScreenHeight(20),
                    color: isActive ? kPrimaryColor : kBlackColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Text content and additional content (if any)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isActive ? kPrimaryColor : Colors.grey,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    // Add extra space if needed
                    if (subtitle == null) const SizedBox(height: 16),
                    // Add delivery partner info if provided
                    if (additionalContent != null) ...[
                      const SizedBox(height: 8),
                      additionalContent,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Vertical line (positioned behind the content)
        if (!isLast)
          Positioned(
            left: getProportionateScreenHeight(40) / 2 - 1, // Center the line under the icon
            top: getProportionateScreenHeight(40), // Start below the icon
            bottom: 0, // Extend to the bottom of the Stack
            child: Container(
              width: 2,
              color: isActive ? const Color(0xFF009688).withOpacity(0.3) : Colors.grey.shade300,
            ),
          ),
      ],
    );
  }

  // Helper method for the delivery partner info card
  Widget _buildDeliveryPartnerInfo(DeliveryAgent deliveryAgent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: kAccentTextAccentOrange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: SvgPicture.asset(
              deliveryBoy,
              height: getProportionateScreenHeight(20),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item is on the way...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Contact our delivery partner',
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              makePhoneCall(deliveryAgent.phone);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(60, 36),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Icon(Icons.call, size: 16,color: kWhiteColor,),
                const SizedBox(width: 4),
                Text('Call',style: bodyStyleStyleB3SemiBold.copyWith(color: kWhiteColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to determine if a status should be shown as active
  bool _isStatusActive(List<String> statusesToCheck, String currentStatus) {
    const statusOrder = {
      'pending': 0,
      'confirmed': 1,
      'processing': 2,
      'out_for_delivery': 3,
      'reached_at_delivery_point': 4,
      'payment_collected': 5,
      'delivered': 6,
      'cancelled': 7,
    };

    if (currentStatus == 'cancelled') {
      return statusesToCheck.contains('cancelled') || statusesToCheck.contains('pending');
    }

    final currentStatusOrder = statusOrder[currentStatus] ?? -1;

    for (final status in statusesToCheck) {
      final statusToCheckOrder = statusOrder[status] ?? -1;
      if (statusToCheckOrder <= currentStatusOrder) {
        return true;
      }
    }

    return false;
  }

  bool _showDeliveryPartnerInfo(String status) {
    return status == 'out_for_delivery' || status == 'reached_at_delivery_point'|| status == 'payment_collected';
  }
}