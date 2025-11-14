class AuthResponse<T> {
  final bool status;
  final String message;
  final T? data;

  AuthResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic> json)? fromJson,
      ) {
    return AuthResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : null,
    );
  }
}

class PhoneLoginResponse {
  final String phone;

  PhoneLoginResponse({required this.phone});

  factory PhoneLoginResponse.fromJson(Map<String, dynamic> json) {
    return PhoneLoginResponse(phone: json['phone'] ?? '');
  }
}

class UserData {
  final String fullName;
  final String phone;
  final String email;
  final String token;

  UserData({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.token,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      fullName: json['f_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'f_name': fullName,
      'phone': phone,
      'email': email,
      'token': token,
    };
  }
}