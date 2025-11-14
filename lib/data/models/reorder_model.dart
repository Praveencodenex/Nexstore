class ReorderResponse {
  final bool status;
  final String message;
  final List<ReorderProduct> data;
  final Meta meta;

  ReorderResponse({
    this.status = false,
    this.message = '',
    this.data = const [],
    Meta? meta,
  }) : meta = meta ?? Meta();

  factory ReorderResponse.fromJson(Map<String, dynamic> json) {
    return ReorderResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ReorderProduct.fromJson(e))
          .toList() ??
          [],
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }
}

class ReorderProduct {
  final int productId;
  final String title;
  final String image;
  final String price;
  final num weight;
  final String unit;
  final int totalStock;

  ReorderProduct({
    this.productId = 0,
    this.title = '',
    this.image = '',
    this.price = '0.0',
    this.weight = 0,
    this.unit = '',
    this.totalStock = 0,
  });

  factory ReorderProduct.fromJson(Map<String, dynamic> json) {
    return ReorderProduct(
      productId: json['product_id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      price: json['price'] ?? '0.0',
      weight: json['weight'] ?? 0,
      unit: json['unit'] ?? '',
      totalStock: json['total_stock'] ?? 0,
    );
  }
}

class Meta {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final String lang;

  Meta({
    this.total = 0,
    this.perPage = 0,
    this.currentPage = 0,
    this.lastPage = 0,
    this.lang = '',
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 0,
      currentPage: json['current_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      lang: json['lang'] ?? '',
    );
  }
}
