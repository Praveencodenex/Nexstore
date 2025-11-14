class AddressResponse {
  final bool status;
  final String message;
  final List<Address> data;
  final Meta meta;

  AddressResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class Address {
  final int id;
  final String name;
  final String? contactName;
  final String? contactPhone;
  final String address;
  final String pincode;
  final String type;
  final String? note;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  Address({
    required this.id,
    required this.isDefault,
    required this.name,
    this.contactName,
    this.contactPhone,
    this.note,
    required this.address,
    required this.pincode,
    required this.type,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      note: json['note'] ?? '',
      isDefault: json['is_default'] ?? false,
      contactName: json['contact_name'],
      contactPhone: json['contact_phone'],
      address: json['address'] ?? '',
      pincode: json['pincode'] ?? '',
      type: json['type'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_default': isDefault,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'address': address,
      'pincode': pincode,
      'note': note,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
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