/// Pure domain entity representing a car brand / manufacturer.
class CarBrand {
  final String id;
  final String name;
  final String? logoUrl;
  final String? country;
  final String? description;
  final String? websiteUrl;
  final DateTime createdAt;

  const CarBrand({
    required this.id,
    required this.name,
    this.logoUrl,
    this.country,
    this.description,
    this.websiteUrl,
    required this.createdAt,
  });
}
