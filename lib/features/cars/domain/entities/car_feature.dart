/// Pure domain entity representing a vehicle feature (e.g. GPS, Sunroof, 360 Camera, ADAS).
class CarFeature {
  final String id;
  final String carId;
  final String featureName;
  final String? iconName;

  const CarFeature({
    required this.id,
    required this.carId,
    required this.featureName,
    this.iconName,
  });
}
