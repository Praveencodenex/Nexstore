import 'home_model.dart';

class WishlistResponse {
  final bool status;
  final String message;
  final List<Product> data;
  final Meta meta;

  WishlistResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List).map((e) => Product.fromJson(e)).toList(),
      meta: Meta.fromJson(json['meta']),
    );
  }
}



class Meta {
  final int total;

  Meta({required this.total});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'],
    );
  }
}
