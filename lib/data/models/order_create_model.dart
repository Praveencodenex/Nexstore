class OrderCreateResponse {
  final bool status;
  final String message;
  final OrderData data;

  OrderCreateResponse({
    this.status = false,
    this.message = '',
    OrderData? data,
  }) : data = data ?? OrderData();

  factory OrderCreateResponse.fromJson(Map<String, dynamic> json) {
    return OrderCreateResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: OrderData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class OrderData {
  final int orderId;
  final double totalAmount;
  final double deliveryCharge;
  final double handlingCharge;
  final String? paymentStatus;

  OrderData({
    this.orderId = 0,
    this.totalAmount = 0.0,
    this.deliveryCharge = 0.0,
    this.handlingCharge = 0.0,
    this.paymentStatus,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      orderId: json['order_id'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      deliveryCharge: (json['delivery_charge'] ?? 0).toDouble(),
      handlingCharge: (json['handling_charge'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'total_amount': totalAmount,
      'delivery_charge': deliveryCharge,
      'handling_charge': handlingCharge,
      'payment_status': paymentStatus,
    };
  }
}
