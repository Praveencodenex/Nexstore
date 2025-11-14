class OrdersResponse {
  final bool status;
  final String message;
  final List<OrderListData> data;
  final Meta meta;

  OrdersResponse({
    this.status = false,
    this.message = '',
    this.data = const [],
    Meta? meta,
  }) : meta = meta ?? Meta();

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List?)?.map((x) => OrderListData.fromJson(x)).toList() ?? [],
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : Meta(),
    );
  }
}

class OrderListData {
  final int id;
  final String status;
  final int items;
  final String date;

  OrderListData({
    this.id = 0,
    this.status = '',
    this.items = 0,
    this.date = '',
  });

  factory OrderListData.fromJson(Map<String, dynamic> json) {
    return OrderListData(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      items: json['items'] as int? ?? 0,
      date: json['date'] as String? ?? '',
    );
  }
}

class Meta {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int from;
  final int to;

  Meta({
    this.total = 0,
    this.perPage = 0,
    this.currentPage = 0,
    this.lastPage = 0,
    this.from = 0,
    this.to = 0,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 0,
      currentPage: json['current_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
    );
  }
}