class NotificationResponse {
  final bool status;
  final String message;
  final NotificationData data;

  NotificationResponse({
    this.status = false,
    this.message = '',
    NotificationData? data,
  }) : data = data ?? NotificationData();

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: NotificationData.fromJson(json['data'] ?? {}),
    );
  }
}

class NotificationData {
  final List<NotificationItem> notifications;
  final Pagination pagination;

  NotificationData({
    List<NotificationItem>? notifications,
    Pagination? pagination,
  })  : notifications = notifications ?? [],
        pagination = pagination ?? Pagination();

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((item) => NotificationItem.fromJson(item))
          .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class NotificationItem {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String type;
  final String createdAt;
  final String updatedAt;

  NotificationItem({
    this.id = 0,
    this.userId = 0,
    this.title = '',
    this.description = '',
    this.type = '',
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Pagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Pagination({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
