import '../../domain/entities/car_image.dart';

class CarImageModel extends CarImage {
  const CarImageModel({
    required String id,
    required String carId,
    required String imageUrl,
    String? thumbnailUrl,
    String? altText,
    String category = 'exterior',
    int sortOrder = 0,
    String? license,
    required DateTime createdAt,
  }) : super(
          id: id,
          carId: carId,
          imageUrl: imageUrl,
          thumbnailUrl: thumbnailUrl,
          altText: altText,
          category: category,
          sortOrder: sortOrder,
          license: license,
          createdAt: createdAt,
        );

  factory CarImageModel.fromJson(Map<String, dynamic> json) {
    return CarImageModel(
      id: json['id'] as String,
      carId: json['car_id'] as String,
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      altText: json['alt_text'] as String?,
      category: json['category'] as String? ?? 'exterior',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      license: json['license'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      'image_url': imageUrl,
      'thumbnail_url': thumbnailUrl,
      'alt_text': altText,
      'category': category,
      'sort_order': sortOrder,
      'license': license,
    };
  }
}
