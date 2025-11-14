import 'home_model.dart';

class HotPickResponse {
  final bool status;
  final String message;
  final List<Product> data;
  final Meta meta;

  HotPickResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory HotPickResponse.fromJson(Map<String, dynamic> json) {
    return HotPickResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)?.map((x) => Product.fromJson(x)).toList() ?? [],
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((x) => x.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class Meta {

  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  Meta({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 0,
      currentPage: json['current_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'per_page': perPage,
      'current_page': currentPage,
      'last_page': lastPage,
    };
  }
}