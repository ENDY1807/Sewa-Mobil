/// Pure domain entity representing an image belonging to a car.
class CarImage {
  final String id;
  final String carId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String? altText;
  final String category; // 'exterior', 'interior', 'dashboard', 'gallery'
  final int sortOrder;
  final String? license;
  final DateTime createdAt;

  const CarImage({
    required this.id,
    required this.carId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.altText,
    this.category = 'exterior',
    this.sortOrder = 0,
    this.license,
    required this.createdAt,
  });
}
