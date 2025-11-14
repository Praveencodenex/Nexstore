class OrderDetailsResponse {
  bool status;
  String message;
  OrderData data;

  OrderDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: OrderData.fromJson(json['data'] as Map<String, dynamic>),
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

class OrderData {
  int id;
  int requestId;
  String orderStatus;
  String paymentMethod;
  String paymentStatus;
  double totalAmount;
  int totalItems;
  BranchAddress? branchAddress; // Made nullable
  DeliveryAddress deliveryAddress;
  List<Product> products;
  dynamic total;
  dynamic deliveryCharge;
  dynamic amountPayable;
  dynamic handlingCharge;
  dynamic taxAmount; // Added new field from API
  bool isCancellable;
  Review? review;
  String date;
  String createdAt; // Added new field from API

  OrderData({
    required this.id,
    required this.requestId,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    required this.totalItems,
    this.branchAddress, // Made nullable
    required this.deliveryAddress,
    required this.products,
    required this.total,
    required this.deliveryCharge,
    required this.amountPayable,
    required this.handlingCharge,
    required this.taxAmount,
    required this.isCancellable,
    this.review,
    this.date = "",
    this.createdAt = "",
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'] ?? 0,
      requestId: json['request_id'] ?? json['id'] ?? 0, // Fallback to id if request_id not available
      orderStatus: json['order_status'] ?? "",
      paymentMethod: json['payment_method'] ?? "",
      paymentStatus: json['payment_status'] ?? json['order_status'] ?? "", // Fallback to order_status
      totalAmount: (json['total_amount'] ?? json['total'] ?? 0).toDouble(),
      totalItems: json['total_items'] ?? (json['products'] as List?)?.length ?? 0, // Calculate from products
      branchAddress: json['branch_address'] != null
          ? BranchAddress.fromJson(json['branch_address'] as Map<String, dynamic>)
          : null, // Handle null case
      deliveryAddress: DeliveryAddress.fromJson(json['delivery_address'] as Map<String, dynamic>),
      isCancellable: json['is_cancellable'] ?? false,
      products: json['products'] != null
          ? (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList()
          : [],
      total: json['total'],
      deliveryCharge: json['delivery_charge'],
      amountPayable: json['amount_payable'],
      handlingCharge: json['handling_charge'],
      taxAmount: json['tax_amount'],
      review: json['review'] != null
          ? Review.fromJson(json['review'] as Map<String, dynamic>)
          : null,
      date: json['date'] ?? "",
      createdAt: json['created_at'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'order_status': orderStatus,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'total_amount': totalAmount,
      'total_items': totalItems,
      'branch_address': branchAddress?.toJson(),
      'delivery_address': deliveryAddress.toJson(),
      'products': products.map((e) => e.toJson()).toList(),
      'total': total,
      'delivery_charge': deliveryCharge,
      'amount_payable': amountPayable,
      'handling_charge': handlingCharge,
      'tax_amount': taxAmount,
      'is_cancellable': isCancellable,
      'review': review?.toJson(),
      'date': date,
      'created_at': createdAt,
    };
  }
}

class BranchAddress {
  String address;
  String pincode;
  String latitude;
  String longitude;

  BranchAddress({
    required this.address,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  factory BranchAddress.fromJson(Map<String, dynamic> json) {
    return BranchAddress(
      address: json['address'] ?? "",
      pincode: json['pincode'] ?? "",
      latitude: json['latitude'] ?? "",
      longitude: json['longitude'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class DeliveryAddress {
  String contactName;
  String contactPhone;
  String name;
  String address;
  String pincode;
  String latitude;
  String longitude;
  int? id; // Added from API
  String? addressType; // Added from API
  String? landmark; // Added from API
  String? contactPersonName; // Added from API
  String? contactPersonPhone; // Added from API

  DeliveryAddress({
    required this.contactName,
    required this.contactPhone,
    required this.name,
    required this.address,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.id,
    this.addressType,
    this.landmark,
    this.contactPersonName,
    this.contactPersonPhone,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      // Map the actual API fields to expected fields with fallbacks
      contactName: json['contact_name'] ??
          json['contact_person_name'] ??
          "N/A",
      contactPhone: json['contact_phone'] ??
          json['contact_person_phone'] ?? "N/A",
      name: json['name'] ?? json['address_type'] ?? "N/A",
      address: json['address'] ?? "",
      pincode: json['pincode'] ?? "",
      latitude: json['latitude']?.toString() ?? "",
      longitude: json['longitude']?.toString() ?? "",
      id: json['id'],
      addressType: json['address_type'],
      landmark: json['landmark'],
      contactPersonName: json['contact_person_name'],
      contactPersonPhone: json['contact_person_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'name': name,
      'address': address,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'id': id,
      'address_type': addressType,
      'landmark': landmark,
      'contact_person_name': contactPersonName,
      'contact_person_phone': contactPersonPhone,
    };
  }
}

class Product {
  String name;
  int id;
  String image;
  String unit;
  dynamic weight;
  dynamic qty;
  dynamic price;
  bool isExchangeable;
  bool isExchanged;

  Product({
    required this.name,
    required this.image,
    required this.unit,
    required this.weight,
    required this.id,
    required this.price,
    required this.qty,
    required this.isExchangeable,
    required this.isExchanged,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] ?? "",
      image: json['image'] ?? "",
      unit: json['unit'] ?? "",
      weight: json['weight'] ?? 0,
      price: json['price'] ?? 0,
      qty: json['quantity'] ?? 0,
      id: json['id'] ?? 0,
      isExchangeable: json['is_exchangeable'] ?? false,
      isExchanged: json['is_exchanged'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'unit': unit,
      'weight': weight,
      'price': price,
      'quantity': qty,
      'id': id,
      'is_exchangeable': isExchangeable,
      'is_exchanged': isExchanged,
    };
  }
}

class Review {
  int id;
  int rating;
  String comment;
  String createdAt;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
    };
  }
}