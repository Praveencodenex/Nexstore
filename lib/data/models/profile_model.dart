class ProfileResponse {
  final bool status;
  final String message;
  final ProfileData data;

  ProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ProfileData.fromJson(json['data'] ?? {}),
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

class ProfileData {
  final int id;
  final String fName;
  final String lName;
  final String email;
  final String phone;
  final String? image;
  final String languageCode;
  final String? gender;

  ProfileData({
    required this.id,
    required this.fName,
    required this.lName,
    required this.email,
    required this.phone,
    this.image,
    required this.languageCode,
    this.gender,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id'] ?? 0,
      fName: json['f_name'] ?? 'New',
      lName: json['l_name'] ?? 'User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['profile_image'],
      languageCode: json['language_code'] ?? 'en',
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'f_name': fName,
      'l_name': lName,
      'email': email,
      'phone': phone,
      'profile_image': image,
      'language_code': languageCode,
      'gender': gender,
    };
  }

  // Helper method to get full name
  String get fullName => '$fName $lName';
}