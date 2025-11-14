class CheckoutResponse {
  final bool status;
  final String message;
  final CheckoutData? data;

  CheckoutResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CheckoutData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class CheckoutData {
  final dynamic total;
  final String deliveryCharge;
  final dynamic handlingCharge;
  final dynamic amountPayable;
  final dynamic couponAmount;

  CheckoutData({
    required this.total,
    required this.deliveryCharge,
    required this.handlingCharge,
    required this.amountPayable,
    required this.couponAmount,
  });

  factory CheckoutData.fromJson(Map<String, dynamic> json) {
    return CheckoutData(
      total: json['total'] ?? 0,
      deliveryCharge: json['deliveryCharge']?.toString() ?? "0.00",
      handlingCharge: json['handlingCharge'] ?? 0,
      couponAmount: json['couponAmount'] ?? 0,
      amountPayable: json['amountPayable'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'deliveryCharge': deliveryCharge,
      'handlingCharge': handlingCharge,
      'couponAmount': couponAmount,
      'amountPayable': amountPayable,
    };
  }

  String formatAsCurrency(num value) {
    return '₹${value.toStringAsFixed(2)}';
  }
}