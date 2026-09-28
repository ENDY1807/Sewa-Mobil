import '../../domain/entities/car_feature.dart';

class CarFeatureModel extends CarFeature {
  const CarFeatureModel({
    required String id,
    required String carId,
    required String featureName,
    String? iconName,
  }) : super(
          id: id,
          carId: carId,
          featureName: featureName,
          iconName: iconName,
        );

  factory CarFeatureModel.fromJson(Map<String, dynamic> json) {
    return CarFeatureModel(
      id: json['id'] as String,
      carId: json['car_id'] as String,
      featureName: json['feature_name'] as String,
      iconName: json['icon_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      'feature_name': featureName,
      'icon_name': iconName,
    };
  }
}
