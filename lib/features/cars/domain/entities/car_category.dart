/// Pure domain entity representing a vehicle category (e.g. SUV, MPV, Sedan, Electric).
class CarCategory {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? iconName;
  final DateTime createdAt;

  const CarCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.iconName,
    required this.createdAt,
  });
}
