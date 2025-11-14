class CartResponse {
  final bool status;
  final String message;
  final CartData data;
  final CartMeta meta;

  CartResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: CartData.fromJson(json['data'] ?? {}),
      meta: CartMeta.fromJson(json['meta'] ?? {}),
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

class CartData {
  final int id;
  final List<CartItem> cartItems;

  CartData({
    required this.id,
    required this.cartItems,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      id: json['id'] ?? 0,
      cartItems: (json['cartItems'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
    };
  }
}

class CartItem {
  final int productId;
  final String name;
  final String image;
  final dynamic productStock;
  final String unit;
  final dynamic weight;
  final dynamic price;
  final dynamic discount;
  final dynamic originalPrice;
  final dynamic quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.productStock,
    required this.unit,
    required this.weight,
    required this.discount,
    required this.originalPrice,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      discount: json['discount'] ?? '',
      originalPrice: json['originalPrice'] ?? '',
      unit: json['unit'] ?? '',
      weight: json['weight'] ?? 0,
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 0,
      productStock: json['product_stock']??0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'image': image,
      'unit': unit,
      'weight': weight,
      'price': price,
      'quantity': quantity,
    };
  }
}

class CartMeta {
  final int totalItems;
  final double totalAmount;
  final double deliveryCharge;
  final double handlingCharge;
  final double couponAmount;
  final double amountPayable;
  final double distance;

  CartMeta({
    required this.totalItems,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.handlingCharge,
    required this.couponAmount,
    required this.amountPayable,
    required this.distance,
  });

  factory CartMeta.fromJson(Map<String, dynamic> json) {
    return CartMeta(
      totalItems: json['total_items'] ?? 0,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      deliveryCharge: (json['delivery_charge'] ?? 0).toDouble(),
      handlingCharge: (json['handling_charge'] ?? 0).toDouble(),
      couponAmount: (json['coupon_amount'] ?? 0).toDouble(),
      amountPayable: (json['amount_payable'] ?? 0).toDouble(),
      distance: (json['distance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_items': totalItems,
      'total_amount': totalAmount,
      'delivery_charge': deliveryCharge,
      'handling_charge': handlingCharge,
      'coupon_amount': couponAmount,
      'amount_payable': amountPayable,
      'distance': distance,
    };
  }
}
