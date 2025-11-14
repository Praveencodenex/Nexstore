class Brand {
  final int id;
  final String name;
  final String logo;

  Brand({required this.id, required this.name, required this.logo});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
    );
  }
}

class ProductType {
  final int id;
  final String name;

  ProductType({required this.id, required this.name});

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id'],
      name: json['name'],
    );
  }
}

class SelectedData {
  final int? categoryId;

  SelectedData({this.categoryId});

  factory SelectedData.fromJson(Map<String, dynamic> json) {
    return SelectedData(
      categoryId: _parseIntOrNull(json['category_id']),
    );
  }

  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null; // Fallback for unexpected types
  }
}

class MetaData {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final Map<String, dynamic> filters;

  MetaData({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.filters,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      total: json['total'],
      perPage: json['per_page'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      filters: json['filters'],
    );
  }
}

class CombinedResponse {
  final bool status;
  final String message;
  final List<Brand>? brands;
  final List<ProductType>? types;
  final SelectedData selected;
  final MetaData meta;

  CombinedResponse({
    required this.status,
    required this.message,
    this.brands,
    this.types,
    required this.selected,
    required this.meta,
  });

  factory CombinedResponse.fromJson(Map<String, dynamic> json, String type) {
    return CombinedResponse(
      status: json['status'],
      message: json['message'],
      brands: type == "brand"
          ? (json['data']['brands'] as List?)?.map((e) => Brand.fromJson(e)).toList()
          : null,
      types: type == "type"
          ? (json['data']['types'] as List?)?.map((e) => ProductType.fromJson(e)).toList()
          : null,
      selected: SelectedData.fromJson(json['data']['selected']),
      meta: MetaData.fromJson(json['meta']),
    );
  }
}