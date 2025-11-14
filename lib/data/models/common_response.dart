class CommonResponse {
  final bool status;
  final String message;

  CommonResponse({
    required this.status,
    required this.message,
  });

  factory CommonResponse.fromJson(Map<String, dynamic> json) {
    return CommonResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? 'Operation completed',
    );
  }
}