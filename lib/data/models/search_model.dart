import 'home_model.dart';

class SearchResponse {
  final bool status;
  final String message;
  final List<Product> data;
  final Meta meta;

  SearchResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List).map((item) => Product.fromJson(item)).toList(),
      meta: Meta.fromJson(json['meta']),
    );
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
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
    );
  }
}