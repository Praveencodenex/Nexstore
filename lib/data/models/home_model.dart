import 'category_model.dart';

class HomeResponse {
  final bool status;
  final String message;
  final HomeData data;

  HomeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: HomeData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class HomeData {
  final Zeromins? zeromins;
  final List<Banners> banners;
  final Banners? categoryBanner;
  final List<Category> categories;
  final List<Product> topProducts;
  final List<String> marquees;

  HomeData({
    this.zeromins,
    required this.banners,
    this.categoryBanner,
    required this.categories,
    required this.topProducts,
    required this.marquees,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      zeromins: json['zeromins'] != null
          ? Zeromins.fromJson(json['zeromins'])
          : null,
      banners: (json['banners'] as List?)
          ?.map((x) => Banners.fromJson(x))
          .toList() ?? [],
      categoryBanner: json['category_banner'] != null
          ? Banners.fromJson(json['category_banner'])
          : null,
      categories: (json['categories'] as List?)
          ?.map((x) => Category.fromJson(x))
          .toList() ?? [],
      topProducts: (json['top_products'] as List?)
          ?.map((x) => Product.fromJson(x))
          .toList() ?? [],
      marquees: (json['marquees'] as List?)
          ?.map((x) => x.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zeromins': zeromins?.toJson(),
      'banners': banners.map((x) => x.toJson()).toList(),
      'category_banner': categoryBanner?.toJson(),
      'categories': categories.map((x) => x.toJson()).toList(),
      'top_products': topProducts.map((x) => x.toJson()).toList(),
      'marquees': marquees,
    };
  }
}

class Zeromins {
  final ZerominsEvent? current;
  final ZerominsEvent? upcoming;

  Zeromins({
    this.current,
    this.upcoming,
  });

  factory Zeromins.fromJson(Map<String, dynamic> json) {
    return Zeromins(
      current: json['current'] != null
          ? ZerominsEvent.fromJson(json['current'])
          : null,
      upcoming: json['upcoming'] != null
          ? ZerominsEvent.fromJson(json['upcoming'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current?.toJson(),
      'upcoming': upcoming?.toJson(),
    };
  }
}

class ZerominsEvent {
  final int id;
  final String name;
  final String scheduleType;
  final String startDateTime;
  final String endDateTime;
  final String? startDate;
  final String? endDate;
  final List<String>? days;
  final bool isActive;
  final String? description;
  final String bannerUrl;

  ZerominsEvent({
    required this.id,
    required this.name,
    required this.scheduleType,
    required this.startDateTime,
    required this.endDateTime,
    this.startDate,
    this.endDate,
    this.days,
    required this.isActive,
    this.description,
    required this.bannerUrl,
  });

  factory ZerominsEvent.fromJson(Map<String, dynamic> json) {
    return ZerominsEvent(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      scheduleType: json['schedule_type'] ?? '',
      startDateTime: json['startDateTime'] ?? '',
      endDateTime: json['endDateTime'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      days: json['days'] != null
          ? List<String>.from(json['days'])
          : null,
      isActive: json['is_active'] ?? false,
      description: json['description'],
      bannerUrl: json['banner_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'schedule_type': scheduleType,
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'start_date': startDate,
      'end_date': endDate,
      'days': days,
      'is_active': isActive,
      'description': description,
      'banner_url': bannerUrl,
    };
  }
}

class Banners {
  final int id;
  final String title;
  final String image;
  final Product? product;
  final Category? category;

  Banners({
    required this.id,
    required this.title,
    required this.image,
    this.product,
    this.category,
  });

  factory Banners.fromJson(Map<String, dynamic> json) {
    return Banners(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'category': category?.toJson(),
    };
  }
}

class Product{
  final int id;
  final String name;
  final String? description;
  final dynamic price;
  final dynamic sellingPrice;
  final String? discountType;
  final dynamic discount;
  final dynamic totalStock;
  final int maximumOrderQuantity;
  final String weight;
  final int viewCount;
  int inCart;
  final String? brand;
  final String? type;
  final String featuredImage;
  final List<String>? productImages;
  final bool inWishlist;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.sellingPrice,
    this.discountType,
    required this.discount,
    required this.totalStock,
    required this.maximumOrderQuantity,
    required this.weight,
    required this.viewCount,
    required this.inCart,
    this.brand,
    this.type,
    required this.featuredImage,
    this.productImages,
    required this.inWishlist,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      sellingPrice: json['selling_price'] ?? 0,
      discountType: json['discount_type'],
      discount: json['discount'] ?? 0,
      totalStock: json['total_stock'] ?? 0,
      inCart: json['in_cart'] ?? 0,
      maximumOrderQuantity: json['maximum_order_quantity'] ?? 1,
      weight: json['weight'] ?? "",
      viewCount: json['view_count'] ?? 0,
      brand: json['brand'],
      type: json['type'],
      featuredImage: json['featured_image'] ?? "",
      productImages: (json['product_images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      inWishlist: json['in_wishlist'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'selling_price': sellingPrice,
      'discount_type': discountType,
      'discount': discount,
      'total_stock': totalStock,
      'maximum_order_quantity': maximumOrderQuantity,
      'weight': weight,
      'view_count': viewCount,
      'brand': brand,
      'type': type,
      'featured_image': featuredImage,
      'product_images': productImages,
      'in_wishlist': inWishlist,
    };
  }
}