import 'home_model.dart';

class ProductResponse {
  final bool status;
  final String message;
  final ProductData data;
  final Meta meta;

  ProductResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ProductData.fromJson(json['data'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
      'meta': meta.toJson(),
    };
  }
}

class ProductData {
  final List<Product> products;
  final List<Types> types;

  ProductData({
    required this.products,
    required this.types,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      types: (json['types'] as List<dynamic>?)
          ?.map((e) => Types.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [], // Fixed: Added proper type conversion
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
      'types': types.map((e) => e.toJson()).toList(), // Fixed: Added proper conversion
    };
  }
}
class Types {
  final int id;
  final String name;


  Types({
    required this.id,
    required this.name,

  });

  factory Types.fromJson(Map<String, dynamic> json) {
    return Types(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
class Meta {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final Filters filters;

  Meta({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.filters,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 0,
      currentPage: json['current_page'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      filters: Filters.fromJson(json['filters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'per_page': perPage,
      'current_page': currentPage,
      'last_page': lastPage,
      'filters': filters.toJson(),
    };
  }
}

class Filters {
  final dynamic brand;
  final dynamic type;

  Filters({
    this.brand,
    this.type,
  });

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      brand: json['brand'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'type': type,
    };
  }
}