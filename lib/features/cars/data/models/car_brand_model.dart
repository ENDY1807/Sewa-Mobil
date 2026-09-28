import '../../domain/entities/car_brand.dart';

class CarBrandModel extends CarBrand {
  const CarBrandModel({
    required String id,
    required String name,
    String? logoUrl,
    String? country,
    String? description,
    String? websiteUrl,
    required DateTime createdAt,
  }) : super(
          id: id,
          name: name,
          logoUrl: logoUrl,
          country: country,
          description: description,
          websiteUrl: websiteUrl,
          createdAt: createdAt,
        );

  factory CarBrandModel.fromJson(Map<String, dynamic> json) {
    return CarBrandModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      country: json['country'] as String?,
      description: json['description'] as String?,
      websiteUrl: json['website_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'country': country,
      'description': description,
      'website_url': websiteUrl,
    };
  }
}
