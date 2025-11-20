import 'home_model.dart';

class RelatedProductsResponse {
  final bool status;
  final String message;
  final RelatedProductsData data;

  RelatedProductsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RelatedProductsResponse.fromJson(Map<String, dynamic> json) {
    return RelatedProductsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: RelatedProductsData.fromJson(json['data'] ?? {})

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson()
    };
  }
}

class RelatedProductsData {
  final Product currentProduct;
  final List<Product> relatedProducts;

  RelatedProductsData({
    required this.currentProduct,
    required this.relatedProducts,
  });

  factory RelatedProductsData.fromJson(Map<String, dynamic> json) {
    return RelatedProductsData(
      currentProduct: Product.fromJson(json['current_product'] ?? {}),
      relatedProducts: (json['related_products'] as List?)
          ?.map((x) => Product.fromJson(x))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_product': currentProduct.toJson(),
      'related_products': relatedProducts.map((x) => x.toJson()).toList(),
    };
  }
}


