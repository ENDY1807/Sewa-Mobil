import '../../domain/entities/car_category.dart';

class CarCategoryModel extends CarCategory {
  const CarCategoryModel({
    required String id,
    required String name,
    required String slug,
    String? description,
    String? iconName,
    required DateTime createdAt,
  }) : super(
          id: id,
          name: name,
          slug: slug,
          description: description,
          iconName: iconName,
          createdAt: createdAt,
        );

  factory CarCategoryModel.fromJson(Map<String, dynamic> json) {
    return CarCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon_name': iconName,
    };
  }
}
