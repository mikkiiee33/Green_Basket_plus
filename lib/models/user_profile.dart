// lib/models/user_profile.dart
// Data model for the user's health profile

import '../core/constants/app_constants.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final int age;
  final Gender gender;
  final double weight; // kg
  final double height; // cm
  final List<HealthCondition> healthConditions;
  final FoodPreference foodPreference;
  final ActivityLevel activityLevel;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.healthConditions,
    required this.foodPreference,
    required this.activityLevel,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  bool get hasDiabetes => healthConditions.contains(HealthCondition.diabetes);
  bool get hasBP => healthConditions.contains(HealthCondition.bloodPressure);
  bool get hasThyroid => healthConditions.contains(HealthCondition.thyroid);

  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    Gender? gender,
    double? weight,
    double? height,
    List<HealthCondition>? healthConditions,
    FoodPreference? foodPreference,
    ActivityLevel? activityLevel,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      healthConditions: healthConditions ?? this.healthConditions,
      foodPreference: foodPreference ?? this.foodPreference,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'age': age,
        'gender': gender.index,
        'weight': weight,
        'height': height,
        'healthConditions': healthConditions.map((e) => e.index).toList(),
        'foodPreference': foodPreference.index,
        'activityLevel': activityLevel.index,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        age: json['age'],
        gender: Gender.values[json['gender']],
        weight: json['weight'].toDouble(),
        height: json['height'].toDouble(),
        healthConditions: (json['healthConditions'] as List)
            .map((e) => HealthCondition.values[e])
            .toList(),
        foodPreference: FoodPreference.values[json['foodPreference']],
        activityLevel: ActivityLevel.values[json['activityLevel']],
      );

  // Mock default profile
  static UserProfile get mock => UserProfile(
        id: 'user_001',
        name: 'Ramesh Kumar',
        email: 'ramesh@example.com',
        age: 52,
        gender: Gender.male,
        weight: 78.0,
        height: 170.0,
        healthConditions: [HealthCondition.diabetes, HealthCondition.bloodPressure],
        foodPreference: FoodPreference.veg,
        activityLevel: ActivityLevel.moderate,
      );
}
