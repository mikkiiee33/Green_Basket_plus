// lib/core/constants/app_constants.dart
// App-wide constants: strings, keys, enums

class AppConstants {
  static const String appName = 'GreenBasket+';
  static const String appTagline = 'Your Preventive Health Companion';
  static const String botName = 'GreenBot';
  static const String botDisclaimer =
      '⚠️ This is not a medical diagnosis. GreenBot provides general wellness information only. Always consult a qualified healthcare professional for medical advice.';
  static const String riskDisclaimer =
      '📋 This is a basic wellness risk estimate and not a medical diagnosis. Consult your doctor for accurate health assessments.';

  // SharedPreferences keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserProfile = 'user_profile';
  static const String keyMedications = 'medications';
  static const String keyHabits = 'habits';
  static const String keyCheckups = 'checkups';
  static const String keyAccessibilityMode = 'accessibility_mode';
  static const String keyHealthScore = 'health_score';

  // Health score thresholds
  static const int scoreExcellent = 80;
  static const int scoreGood = 60;
  static const int scoreFair = 40;

  // Lifestyle reminders
  static const List<Map<String, dynamic>> defaultLifestyleReminders = [
    {'id': '1', 'title': 'Morning Walk', 'subtitle': '20 minutes brisk walk', 'icon': 'walk', 'time': '07:00', 'done': false},
    {'id': '2', 'title': 'Drink Water', 'subtitle': '2-3 liters throughout day', 'icon': 'water', 'time': '08:00', 'done': false},
    {'id': '3', 'title': 'Eat a Fruit', 'subtitle': 'Fresh seasonal fruit', 'icon': 'fruit', 'time': '10:00', 'done': false},
    {'id': '4', 'title': 'Stretch Break', 'subtitle': '5-minute stretching', 'icon': 'stretch', 'time': '15:00', 'done': false},
    {'id': '5', 'title': 'Sleep Early', 'subtitle': 'Wind down by 10 PM', 'icon': 'sleep', 'time': '22:00', 'done': false},
    {'id': '6', 'title': 'Weekly Weigh-in', 'subtitle': 'Check your weight', 'icon': 'weight', 'time': '08:00', 'done': false, 'weekly': true},
  ];
}

enum HealthCondition { diabetes, bloodPressure, thyroid, none }
enum FoodPreference { veg, nonVeg }
enum ActivityLevel { low, moderate, active }
enum Gender { male, female, other }
enum RiskLevel { low, moderate, high }
enum MedicationStatus { taken, missed, pending }

extension HealthConditionExtension on HealthCondition {
  String get label {
    switch (this) {
      case HealthCondition.diabetes: return 'Diabetes';
      case HealthCondition.bloodPressure: return 'Blood Pressure';
      case HealthCondition.thyroid: return 'Thyroid';
      case HealthCondition.none: return 'None';
    }
  }
}

extension ActivityLevelExtension on ActivityLevel {
  String get label {
    switch (this) {
      case ActivityLevel.low: return 'Low (Mostly sedentary)';
      case ActivityLevel.moderate: return 'Moderate (Some exercise)';
      case ActivityLevel.active: return 'Active (Regular exercise)';
    }
  }
}

extension RiskLevelExtension on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low: return 'Low Risk';
      case RiskLevel.moderate: return 'Moderate Risk';
      case RiskLevel.high: return 'Higher Risk';
    }
  }
}
