class OrderStatusResponse {
  final bool status;
  final String message;
  final OrderStatusData data;

  OrderStatusResponse({
    this.status = false,
    this.message = '',
    OrderStatusData? data,
  }) : data = data ?? OrderStatusData();

  factory OrderStatusResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: OrderStatusData.fromJson(json['data'] ?? {}),
    );
  }
}

class OrderStatusData {
  final int orderId;
  final String dateTime;
  final String orderStatus;
  final DeliveryAgent deliveryAgent;

  OrderStatusData({
    this.orderId = 0,
    this.dateTime = '',
    this.orderStatus = '',
    DeliveryAgent? deliveryAgent,
  }) : deliveryAgent = deliveryAgent ?? DeliveryAgent();

  factory OrderStatusData.fromJson(Map<String, dynamic> json) {
    return OrderStatusData(
      orderId: json['order_id'] ?? 0,
      dateTime: json['date_time'] ?? '',
      orderStatus: json['order_status'] ?? '',
      deliveryAgent:
      DeliveryAgent.fromJson(json['delivery_agent'] ?? {}),
    );
  }
}

class DeliveryAgent {
  final String name;
  final String phone;

  DeliveryAgent({
    this.name = '',
    this.phone = '',
  });

  factory DeliveryAgent.fromJson(Map<String, dynamic> json) {
    return DeliveryAgent(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
