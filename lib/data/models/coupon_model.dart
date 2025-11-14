class CouponResponse {
  final bool status;
  final String message;
  final List<Coupon> data;
  final Meta meta;

  CouponResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)?.map((x) => Coupon.fromJson(x)).toList() ?? [],
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

class Coupon {
  final int id;
  final String title;
  final String code;
  final int discount;
  final String discountType;
  final String type;
  final int minPurchase;
  final int maxDiscount;
  final String startDate;
  final String endDate;
  final int limit;

  Coupon({
    required this.id,
    required this.title,
    required this.code,
    required this.discountType,
    required this.type,
    required this.discount,
    required this.minPurchase,
    required this.maxDiscount,
    required this.startDate,
    required this.endDate,
    required this.limit,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      code: json['code'] ?? '',
      discount: json['discount'] ?? '',
      minPurchase: json['min_purchase'] ?? 0,
      maxDiscount: json['max_discount'] ?? 0,
      startDate: json['start_date'] ?? '',
      discountType: json['discount_type'] ?? '',
      type: json['type'] ?? '',
      endDate: json['end_date'] ?? '',
      limit: json['limit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'discount': discount,
      'min_purchase': minPurchase,
      'max_discount': maxDiscount,
      'discount_type': discountType,
      'type': type,
      'start_date': startDate,
      'end_date': endDate,
      'limit': limit,
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