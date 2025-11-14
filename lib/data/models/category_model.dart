// Category Response Model
class CategoryModel {
  final bool status;
  final String message;
  final List<Category> data;

  CategoryModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List?)
          ?.map((x) => Category.fromJson(x))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

// Category Model
class Category {
  final int id;
  final String name;
  final String icon;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      subCategories: (json['sub_categories'] as List?)
          ?.map((x) => SubCategory.fromJson(x))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'sub_categories': subCategories.map((x) => x.toJson()).toList(),
    };
  }
}

// SubCategory Model
class SubCategory {
  final int id;
  final String name;
  final String icon;

  SubCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }
}