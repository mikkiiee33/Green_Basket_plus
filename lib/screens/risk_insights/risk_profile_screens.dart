// // lib/screens/risk_insights/risk_profile_screens.dart
// // Health Risk Insights + User Profile + Accessibility settings

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/constants/app_constants.dart';
// import '../../providers/app_provider.dart';
// import '../../widgets/common_widgets.dart';


// // RISK INSIGHTS SCREEN

// class RiskInsightsScreen extends StatefulWidget {
//   const RiskInsightsScreen({super.key});
//   @override
//   State<RiskInsightsScreen> createState() => _RiskInsightsScreenState();
// }

// class _RiskInsightsScreenState extends State<RiskInsightsScreen> {
//   int    _age           = 45;
//   double _weight        = 72.0;
//   double _height        = 165.0;
//   double _exerciseHours = 1.0;
//   double _sleepHours    = 6.5;
//   bool   _isSmoker      = false;
//   bool   _showResults   = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final p = context.read<UserProfileProvider>().profile;
//       if (p != null) setState(() { _age = p.age; _weight = p.weight; _height = p.height; });
//     });
//   }

//   double get _bmi => _weight / ((_height / 100) * (_height / 100));

//   RiskLevel _diabetesRisk() {
//     int s = 0;
//     if (_age >= 45) s += 2;
//     if (_age >= 60) s += 1;
//     if (_bmi >= 25) s += 2;
//     if (_bmi >= 30) s += 2;
//     if (_exerciseHours < 2) s += 2;
//     if (_sleepHours < 6)  s += 1;
//     if (_isSmoker)        s += 1;
//     return s >= 7 ? RiskLevel.high : (s >= 4 ? RiskLevel.moderate : RiskLevel.low);
//   }

//   RiskLevel _heartRisk() {
//     int s = 0;
//     if (_age >= 50) s += 2;
//     if (_age >= 60) s += 2;
//     if (_isSmoker)  s += 3;
//     if (_bmi >= 28) s += 2;
//     if (_exerciseHours < 1.5) s += 2;
//     if (_sleepHours < 6)      s += 1;
//     return s >= 8 ? RiskLevel.high : (s >= 4 ? RiskLevel.moderate : RiskLevel.low);
//   }

//   RiskLevel _obesityRisk() =>
//       _bmi >= 30 ? RiskLevel.high : (_bmi >= 25 ? RiskLevel.moderate : RiskLevel.low);

//   Color  _riskColor(RiskLevel l) => l == RiskLevel.low ? AppColors.lowRisk  : (l == RiskLevel.moderate ? AppColors.moderateRisk : AppColors.highRisk);
//   String _riskEmoji(RiskLevel l) => l == RiskLevel.low ? '🟢' : (l == RiskLevel.moderate ? '🟡' : '🔴');

//   String _advice(String cond, RiskLevel l) {
//     final map = {
//       'Diabetes':     { RiskLevel.low: 'Great habits! Keep balanced diet and regular exercise.',
//                         RiskLevel.moderate: 'Consider a blood sugar test. Reduce refined carbs and increase activity.',
//                         RiskLevel.high: 'Please consult a doctor for diabetes screening urgently.' },
//       'Heart Disease':{ RiskLevel.low: 'Heart health indicators look good. Keep exercising and eating well.',
//                         RiskLevel.moderate: 'Consider a cardiovascular checkup. Reduce saturated fats and be more active.',
//                         RiskLevel.high: 'High risk detected. Please see a cardiologist for evaluation soon.' },
//       'Obesity':      { RiskLevel.low: 'BMI is in a healthy range. Maintain your current lifestyle.',
//                         RiskLevel.moderate: 'BMI suggests overweight. Small diet and activity changes can help significantly.',
//                         RiskLevel.high: 'BMI indicates obesity. Please consult a doctor for a weight management plan.' },
//     };
//     return map[cond]?[l] ?? '';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: const Text('Health Risk Insights')),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         children: [
//           GBCard(
//             color: AppColors.primarySurface,
//             child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Text('📊', style: TextStyle(fontSize: 32)),
//               const SizedBox(width: 12),
//               Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Risk Assessment', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
//                 Text('Answer a few questions to see your estimated health risk levels.', style: Theme.of(context).textTheme.bodyMedium),
//               ])),
//             ]),
//           ),

//           const SizedBox(height: 14),

//           GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text('Your Health Data', style: Theme.of(context).textTheme.titleSmall),
//             const SizedBox(height: 12),

//             _SF('Age: $_age years', _age.toDouble(), 18, 90, 72, AppColors.primary, (v) => setState(() => _age = v.round())),
//             const Divider(),
//             _SF('Weight: ${_weight.toStringAsFixed(1)} kg', _weight, 30, 150, 120, AppColors.accent, (v) => setState(() => _weight = double.parse(v.toStringAsFixed(1)))),
//             const Divider(),
//             _SF('Height: ${_height.toStringAsFixed(0)} cm', _height, 100, 220, 120, AppColors.info, (v) => setState(() => _height = double.parse(v.toStringAsFixed(0)))),
//             const Divider(),
//             _SF('Exercise: ${_exerciseHours.toStringAsFixed(1)} hrs/week', _exerciseHours, 0, 20, 40, AppColors.success, (v) => setState(() => _exerciseHours = double.parse(v.toStringAsFixed(1)))),
//             const Divider(),
//             _SF('Sleep: ${_sleepHours.toStringAsFixed(1)} hrs/night', _sleepHours, 3, 12, 18, AppColors.primaryLighter, (v) => setState(() => _sleepHours = double.parse(v.toStringAsFixed(1)))),
//             const Divider(),
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Smoking Status', style: Theme.of(context).textTheme.titleSmall),
//                 Text(_isSmoker ? 'Current Smoker' : 'Non-Smoker', style: Theme.of(context).textTheme.bodySmall),
//               ]),
//               Switch(value: _isSmoker, onChanged: (v) => setState(() => _isSmoker = v), activeColor: AppColors.error),
//             ]),
//           ])),

//           const SizedBox(height: 8),
//           GBCard(
//             color: AppColors.primarySurface,
//             child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Your BMI', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
//                 Text(_bmi.toStringAsFixed(1), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
//               ]),
//               StatusChip(
//                 label: _bmi < 18.5 ? 'Underweight' : (_bmi < 25 ? 'Normal' : (_bmi < 30 ? 'Overweight' : 'Obese')),
//                 color: _bmi < 25 ? AppColors.success : (_bmi < 30 ? AppColors.warning : AppColors.error),
//               ),
//             ]),
//           ),

//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: () => setState(() => _showResults = true),
//             icon: const Icon(Icons.bar_chart_rounded, size: 20),
//             label: const Text('Calculate My Risk'),
//           ),

//           if (_showResults) ...[
//             const SizedBox(height: 20),
//             Text('Your Risk Assessment', style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 10),

//             _RiskCard(condition: 'Diabetes',     emoji: '🩸', level: _diabetesRisk(), advice: _advice('Diabetes',     _diabetesRisk()), riskColor: _riskColor(_diabetesRisk()), riskEmoji: _riskEmoji(_diabetesRisk())),
//             const SizedBox(height: 10),
//             _RiskCard(condition: 'Heart Disease', emoji: '❤️', level: _heartRisk(),   advice: _advice('Heart Disease', _heartRisk()),   riskColor: _riskColor(_heartRisk()),   riskEmoji: _riskEmoji(_heartRisk())),
//             const SizedBox(height: 10),
//             _RiskCard(condition: 'Obesity',       emoji: '⚖️', level: _obesityRisk(), advice: _advice('Obesity',       _obesityRisk()), riskColor: _riskColor(_obesityRisk()), riskEmoji: _riskEmoji(_obesityRisk())),

//             const SizedBox(height: 16),
//             const DisclaimerCard(message: 'This is a basic wellness risk estimate and NOT a medical diagnosis. Please consult your doctor for accurate health assessments.'),
//           ],
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }
// }

// // Slider helper widget
// class _SF extends StatelessWidget {
//   final String label; final double value; final double min; final double max;
//   final int div; final Color color; final ValueChanged<double> onChanged;
//   const _SF(this.label, this.value, this.min, this.max, this.div, this.color, this.onChanged);

//   @override
//   Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Text(label, style: Theme.of(context).textTheme.titleSmall),
//     Slider(value: value, min: min, max: max, divisions: div, activeColor: color, inactiveColor: AppColors.divider, label: value.toStringAsFixed(1), onChanged: onChanged),
//   ]);
// }

// // Risk result card
// class _RiskCard extends StatelessWidget {
//   final String condition, emoji, advice, riskEmoji;
//   final RiskLevel level; final Color riskColor;
//   const _RiskCard({required this.condition, required this.emoji, required this.level, required this.advice, required this.riskColor, required this.riskEmoji});

//   @override
//   Widget build(BuildContext context) => GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//     Row(children: [
//       Text(emoji, style: const TextStyle(fontSize: 28)), const SizedBox(width: 12),
//       Expanded(child: Text(condition, style: Theme.of(context).textTheme.titleSmall)),
//       StatusChip(label: '$riskEmoji ${level.label}', color: riskColor),
//     ]),
//     const SizedBox(height: 10),
//     GBProgressBar(value: level == RiskLevel.low ? 0.2 : (level == RiskLevel.moderate ? 0.6 : 0.9), color: riskColor, height: 8),
//     const SizedBox(height: 10),
//     Text(advice, style: Theme.of(context).textTheme.bodyMedium),
//   ]));
// }

// // PROFILE SCREEN
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final profile       = context.watch<UserProfileProvider>().profile;
//     final accessibility = context.watch<AccessibilityProvider>();
//     final auth          = context.read<AuthProvider>();

//     if (profile == null) {
//       return Scaffold(
//         backgroundColor: AppColors.background,
//         body: EmptyStateWidget(emoji: '👤', title: 'No Profile Found',
//           subtitle: 'Please complete your profile setup',
//           actionLabel: 'Setup Profile',
//           onAction: () => Navigator.of(context).pushNamed('/profile-setup')),
//       );
//     }

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(title: const Text('My Profile')),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         children: [

//           // Avatar + Name 
//           GBCard(child: Row(children: [
//             Container(width: 72, height: 72,
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
//                 shape: BoxShape.circle),
//               child: Center(child: Text(
//                 profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
//                 style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)))),
//             const SizedBox(width: 16),
//             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
//               Text(profile.email, style: Theme.of(context).textTheme.bodySmall),
//               const SizedBox(height: 6),
//               StatusChip(label: 'Age ${profile.age}  •  BMI ${profile.bmi.toStringAsFixed(1)}', color: AppColors.primary),
//             ])),
//           ])),

//           const SizedBox(height: 12),

//           // Health stats 
//           const SectionTitle(title: 'Health Profile'),
//           const SizedBox(height: 8),
//           GBCard(child: Column(children: [
//             InfoRow(label: 'Weight',         value: '${profile.weight.toStringAsFixed(1)} kg', icon: Icons.monitor_weight_outlined),
//             InfoRow(label: 'Height',         value: '${profile.height.toStringAsFixed(0)} cm', icon: Icons.height),
//             InfoRow(label: 'BMI',            value: '${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})', icon: Icons.bar_chart),
//             InfoRow(label: 'Activity',       value: profile.activityLevel.label.split('(').first.trim(), icon: Icons.directions_walk),
//             InfoRow(label: 'Food',           value: profile.foodPreference == FoodPreference.veg ? '🥦 Vegetarian' : '🍗 Non-Veg', icon: Icons.restaurant_outlined),
//           ])),

//           const SizedBox(height: 8),
//           GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text('Health Conditions', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
//             const SizedBox(height: 10),
//             Wrap(spacing: 8, runSpacing: 6,
//               children: profile.healthConditions.map((c) => StatusChip(
//                 label: c.label,
//                 color: c == HealthCondition.none ? AppColors.success : AppColors.warning,
//               )).toList()),
//           ])),

//           const SizedBox(height: 16),

//           // Accessibility 
//           const SectionTitle(title: '♿ Accessibility'),
//           const SizedBox(height: 8),
//           GBCard(child: Column(children: [
//             _Toggle('Accessibility Mode',  'Large fonts, high contrast, bigger buttons',
//               accessibility.accessibilityMode, (_) => context.read<AccessibilityProvider>().toggleAccessibilityMode()),
//             const Divider(),
//             _Toggle('Large Text',          'Increase font size throughout the app',
//               accessibility.largeText,        (_) => context.read<AccessibilityProvider>().toggleLargeText()),
//             const Divider(),
//             _Toggle('High Contrast',       'Dark background for better readability',
//               accessibility.highContrast,     (_) => context.read<AccessibilityProvider>().toggleHighContrast()),
//             const Divider(),
//             ListTile(contentPadding: EdgeInsets.zero,
//               leading: const Icon(Icons.record_voice_over_outlined, color: AppColors.textSecondary),
//               title: const Text('Voice Guidance'),
//               subtitle: const Text('Text-to-speech for navigation'),
//               trailing: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
//                 child: const Text('Coming Soon', style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w700)))),
//           ])),

//           const SizedBox(height: 16),

//           // Settings 
//           const SectionTitle(title: 'Settings'),
//           const SizedBox(height: 8),
//           GBCard(child: Column(children: [
//             _Setting(Icons.edit_outlined,        'Edit Profile',              onTap: () {}),
//             const Divider(),
//             _Setting(Icons.notifications_outlined,'Notification Settings',    onTap: () {}),
//             const Divider(),
//             _Setting(Icons.privacy_tip_outlined,  'Privacy Policy',           onTap: () {}),
//             const Divider(),
//             _Setting(Icons.help_outline,          'Help & Support',           onTap: () {}),
//             const Divider(),
//             _Setting(Icons.logout,                'Sign Out', color: AppColors.error,
//               onTap: () {
//                 auth.logout();
//                 Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
//               }),
//           ])),
//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }
// }

// class _Toggle extends StatelessWidget {
//   final String title, subtitle;
//   final bool value;
//   final ValueChanged<bool> onChanged;
//   const _Toggle(this.title, this.subtitle, this.value, this.onChanged);

//   @override
//   Widget build(BuildContext context) => Row(children: [
//     Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(title,    style: Theme.of(context).textTheme.titleSmall),
//       Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
//     ])),
//     Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
//   ]);
// }

// class _Setting extends StatelessWidget {
//   final IconData icon; final String title; final VoidCallback onTap; final Color? color;
//   const _Setting(this.icon, this.title, {required this.onTap, this.color});

//   @override
//   Widget build(BuildContext context) => ListTile(
//     contentPadding: EdgeInsets.zero,
//     leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
//     title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color)),
//     trailing: Icon(Icons.chevron_right, color: color ?? AppColors.textSecondary, size: 20),
//     onTap: onTap,
//   );
// }























// lib/screens/risk_insights/risk_profile_screens.dart
// Enhanced: Disease Prediction + Nutrient Deficiency + Profile + Accessibility
// Drop-in replacement for your existing risk_profile_screens.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RISK INSIGHTS SCREEN (Enhanced: Disease Prediction + Nutrient Deficiency)
// ─────────────────────────────────────────────────────────────────────────────

class RiskInsightsScreen extends StatefulWidget {
  const RiskInsightsScreen({super.key});
  @override
  State<RiskInsightsScreen> createState() => _RiskInsightsScreenState();
}

class _RiskInsightsScreenState extends State<RiskInsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Health inputs
  int    _age           = 45;
  double _weight        = 72.0;
  double _height        = 165.0;
  double _exerciseHours = 1.0;
  double _sleepHours    = 6.5;
  bool   _isSmoker      = false;
  bool   _showResults   = false;

  // Nutrient inputs
  bool _eatsGreenVeg    = true;
  bool _eatsDairy       = true;
  bool _eatsFruits      = true;
  bool _eatsNuts        = false;
  bool _eatsLegumes     = true;
  bool _drinksMilk      = true;
  bool _eatsEggs        = false;
  bool _sunExposure     = true;
  bool _showNutrient    = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<UserProfileProvider>().profile;
      if (p != null) {
        setState(() {
          _age    = p.age;
          _weight = p.weight;
          _height = p.height;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── BMI ──────────────────────────────────────────────────────────────────
  double get _bmi => _weight / ((_height / 100) * (_height / 100));

  // ── DISEASE RISK LOGIC ───────────────────────────────────────────────────
  RiskLevel _diabetesRisk() {
    int s = 0;
    if (_age >= 45) s += 2;
    if (_age >= 60) s += 1;
    if (_bmi >= 25) s += 2;
    if (_bmi >= 30) s += 2;
    if (_exerciseHours < 2) s += 2;
    if (_sleepHours < 6)    s += 1;
    if (_isSmoker)          s += 1;
    return s >= 7 ? RiskLevel.high : (s >= 4 ? RiskLevel.moderate : RiskLevel.low);
  }

  RiskLevel _heartRisk() {
    int s = 0;
    if (_age >= 50)           s += 2;
    if (_age >= 60)           s += 2;
    if (_isSmoker)            s += 3;
    if (_bmi >= 28)           s += 2;
    if (_exerciseHours < 1.5) s += 2;
    if (_sleepHours < 6)      s += 1;
    return s >= 8 ? RiskLevel.high : (s >= 4 ? RiskLevel.moderate : RiskLevel.low);
  }

  RiskLevel _bpRisk() {
    int s = 0;
    if (_age >= 40)           s += 2;
    if (_bmi >= 27)           s += 2;
    if (_isSmoker)            s += 2;
    if (_exerciseHours < 1)   s += 2;
    if (_sleepHours < 6)      s += 1;
    return s >= 7 ? RiskLevel.high : (s >= 4 ? RiskLevel.moderate : RiskLevel.low);
  }

  RiskLevel _obesityRisk() =>
      _bmi >= 30 ? RiskLevel.high : (_bmi >= 25 ? RiskLevel.moderate : RiskLevel.low);

  // ── NUTRIENT DEFICIENCY LOGIC ────────────────────────────────────────────

  /// Returns list of detected deficiencies with full details
  List<_NutrientResult> _analyseNutrients() {
    final results = <_NutrientResult>[];

    // Iron
    if (!_eatsGreenVeg && !_eatsLegumes && !_eatsEggs) {
      results.add(_NutrientResult(
        nutrient: 'Iron',
        emoji: '🩸',
        level: RiskLevel.high,
        symptoms: ['Fatigue & weakness', 'Pale skin', 'Dizziness', 'Shortness of breath'],
        foods: ['Spinach', 'Rajma', 'Lentils', 'Eggs', 'Beetroot'],
        warning: 'Low iron can cause anaemia — affects oxygen supply to the body.',
      ));
    } else if (!_eatsGreenVeg || !_eatsLegumes) {
      results.add(_NutrientResult(
        nutrient: 'Iron',
        emoji: '🩸',
        level: RiskLevel.moderate,
        symptoms: ['Mild fatigue', 'Occasional dizziness'],
        foods: ['Spinach', 'Rajma', 'Lentils', 'Eggs'],
        warning: 'Consider eating more iron-rich foods daily.',
      ));
    }

    // Calcium
    if (!_eatsDairy && !_drinksMilk && !_eatsGreenVeg) {
      results.add(_NutrientResult(
        nutrient: 'Calcium',
        emoji: '🦴',
        level: RiskLevel.high,
        symptoms: ['Brittle bones', 'Muscle cramps', 'Weak teeth', 'Numbness in hands/feet'],
        foods: ['Milk', 'Curd', 'Paneer', 'Sesame seeds', 'Ragi'],
        warning: 'Severe calcium deficiency weakens bones and increases fracture risk.',
      ));
    } else if (!_eatsDairy || !_drinksMilk) {
      results.add(_NutrientResult(
        nutrient: 'Calcium',
        emoji: '🦴',
        level: RiskLevel.moderate,
        symptoms: ['Mild cramps', 'Slightly weak nails'],
        foods: ['Milk', 'Curd', 'Paneer', 'Ragi'],
        warning: 'Add dairy or calcium-rich foods to your daily diet.',
      ));
    }

    // Vitamin D
    if (!_sunExposure && !_eatsDairy) {
      results.add(_NutrientResult(
        nutrient: 'Vitamin D',
        emoji: '☀️',
        level: RiskLevel.high,
        symptoms: ['Bone pain', 'Muscle weakness', 'Depression', 'Frequent infections'],
        foods: ['Egg yolk', 'Fortified milk', 'Mushrooms', 'Fatty fish'],
        warning: 'Vitamin D deficiency is very common in India. Spend 20 min in morning sun daily.',
      ));
    } else if (!_sunExposure || !_eatsDairy) {
      results.add(_NutrientResult(
        nutrient: 'Vitamin D',
        emoji: '☀️',
        level: RiskLevel.moderate,
        symptoms: ['Mild fatigue', 'Low mood'],
        foods: ['Egg yolk', 'Fortified milk', 'Morning sunlight'],
        warning: 'Try to get 15–20 minutes of morning sunlight daily.',
      ));
    }

    // Vitamin A
    if (!_eatsFruits && !_eatsGreenVeg) {
      results.add(_NutrientResult(
        nutrient: 'Vitamin A',
        emoji: '👁️',
        level: RiskLevel.high,
        symptoms: ['Dry eyes', 'Night blindness', 'Dry skin', 'Frequent infections'],
        foods: ['Carrot', 'Mango', 'Papaya', 'Sweet potato', 'Spinach'],
        warning: 'Low Vitamin A causes eye dryness and weakens immunity.',
      ));
    }

    // Vitamin B (B12 / B Complex)
    if (!_eatsEggs && !_eatsDairy) {
      results.add(_NutrientResult(
        nutrient: 'Vitamin B12',
        emoji: '🧠',
        level: RiskLevel.high,
        symptoms: ['Skin peeling', 'Tingling in hands/feet', 'Memory issues', 'Fatigue'],
        foods: ['Eggs', 'Milk', 'Curd', 'Paneer', 'Fortified cereals'],
        warning: 'B12 deficiency is very common in vegetarians. Consider supplements.',
      ));
    }

    // Zinc
    if (!_eatsLegumes && !_eatsNuts && !_eatsEggs) {
      results.add(_NutrientResult(
        nutrient: 'Zinc',
        emoji: '🛡️',
        level: RiskLevel.moderate,
        symptoms: ['Slow wound healing', 'Hair loss', 'Low immunity', 'Taste/smell changes'],
        foods: ['Pumpkin seeds', 'Groundnuts', 'Rajma', 'Eggs', 'Cashews'],
        warning: 'Zinc supports immunity and wound healing. Add nuts and seeds.',
      ));
    }

    // Potassium (warning for excess)
    if (_exerciseHours > 10 && !_eatsFruits && !_eatsGreenVeg) {
      results.add(_NutrientResult(
        nutrient: 'Potassium',
        emoji: '⚡',
        level: RiskLevel.moderate,
        symptoms: ['Muscle weakness', 'Cramps', 'Irregular heartbeat'],
        foods: ['Banana', 'Potato', 'Coconut water', 'Spinach', 'Tomato'],
        warning: 'Very high potassium (hyperkalemia) can cause cardiac arrest. Balance is key.',
      ));
    }

    // Magnesium
    if (!_eatsNuts && !_eatsGreenVeg && !_eatsLegumes) {
      results.add(_NutrientResult(
        nutrient: 'Magnesium',
        emoji: '💤',
        level: RiskLevel.moderate,
        symptoms: ['Poor sleep', 'Anxiety', 'Muscle twitches', 'Constipation'],
        foods: ['Almonds', 'Dark leafy greens', 'Banana', 'Whole grains'],
        warning: 'Magnesium helps sleep and muscle function. Add nuts and greens.',
      ));
    }

    // If all good
    if (results.isEmpty) {
      results.add(_NutrientResult(
        nutrient: 'All Good!',
        emoji: '✅',
        level: RiskLevel.low,
        symptoms: ['No deficiencies detected based on your diet'],
        foods: ['Keep maintaining a balanced diet'],
        warning: 'Your diet appears balanced. Regular blood tests are still recommended.',
      ));
    }

    return results;
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────
  Color  _riskColor(RiskLevel l) => l == RiskLevel.low ? AppColors.lowRisk  : (l == RiskLevel.moderate ? AppColors.moderateRisk : AppColors.highRisk);
  String _riskEmoji(RiskLevel l) => l == RiskLevel.low ? '🟢' : (l == RiskLevel.moderate ? '🟡' : '🔴');
  String _riskLabel(RiskLevel l) => l == RiskLevel.low ? 'Low Risk' : (l == RiskLevel.moderate ? 'Moderate' : 'High Risk');

  String _diseaseAdvice(String cond, RiskLevel l) {
    final map = {
      'Diabetes': {
        RiskLevel.low:      'Great habits! Keep a balanced diet and regular exercise.',
        RiskLevel.moderate: 'Consider a blood sugar test. Reduce refined carbs and increase activity.',
        RiskLevel.high:     'Please consult a doctor for diabetes screening urgently.',
      },
      'Heart Disease': {
        RiskLevel.low:      'Heart health indicators look good. Keep exercising and eating well.',
        RiskLevel.moderate: 'Consider a cardiovascular checkup. Reduce saturated fats and be more active.',
        RiskLevel.high:     'High risk detected. Please see a cardiologist for evaluation soon.',
      },
      'Blood Pressure': {
        RiskLevel.low:      'BP risk is low. Maintain low-sodium diet and stay active.',
        RiskLevel.moderate: 'Monitor your BP regularly. Reduce salt, stress, and increase activity.',
        RiskLevel.high:     'High BP risk. Please consult a doctor and get your BP checked immediately.',
      },
      'Obesity': {
        RiskLevel.low:      'BMI is in a healthy range. Maintain your current lifestyle.',
        RiskLevel.moderate: 'BMI suggests overweight. Small diet and activity changes can help significantly.',
        RiskLevel.high:     'BMI indicates obesity. Please consult a doctor for a weight management plan.',
      },
    };
    return map[cond]?[l] ?? '';
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Risk Insights'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Disease Risk'),
            Tab(icon: Icon(Icons.science_outlined),  text: 'Nutrient Check'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiseaseTab(),
          _buildNutrientTab(),
        ],
      ),
    );
  }

  // ── TAB 1: DISEASE PREDICTION ────────────────────────────────────────────
  Widget _buildDiseaseTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        GBCard(
          color: AppColors.primarySurface,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📊', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Disease Risk Assessment', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
              Text('Adjust your health data below to see your estimated risk for common conditions.', style: Theme.of(context).textTheme.bodyMedium),
            ])),
          ]),
        ),

        const SizedBox(height: 14),

        GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your Health Data', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          _SF('Age: $_age years',                          _age.toDouble(),    18,  90, 72,  AppColors.primary,      (v) => setState(() => _age    = v.round())),
          const Divider(),
          _SF('Weight: ${_weight.toStringAsFixed(1)} kg',  _weight,            30,  150, 120, AppColors.accent,       (v) => setState(() => _weight = double.parse(v.toStringAsFixed(1)))),
          const Divider(),
          _SF('Height: ${_height.toStringAsFixed(0)} cm',  _height,            100, 220, 120, AppColors.info,         (v) => setState(() => _height = double.parse(v.toStringAsFixed(0)))),
          const Divider(),
          _SF('Exercise: ${_exerciseHours.toStringAsFixed(1)} hrs/week', _exerciseHours, 0, 20, 40, AppColors.success, (v) => setState(() => _exerciseHours = double.parse(v.toStringAsFixed(1)))),
          const Divider(),
          _SF('Sleep: ${_sleepHours.toStringAsFixed(1)} hrs/night',      _sleepHours,    3, 12, 18, AppColors.primaryLighter, (v) => setState(() => _sleepHours = double.parse(v.toStringAsFixed(1)))),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Smoking Status', style: Theme.of(context).textTheme.titleSmall),
              Text(_isSmoker ? 'Current Smoker' : 'Non-Smoker', style: Theme.of(context).textTheme.bodySmall),
            ]),
            Switch(value: _isSmoker, onChanged: (v) => setState(() => _isSmoker = v), activeColor: AppColors.error),
          ]),
        ])),

        const SizedBox(height: 8),
        GBCard(
          color: AppColors.primarySurface,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your BMI', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              Text(_bmi.toStringAsFixed(1), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
            ]),
            StatusChip(
              label: _bmi < 18.5 ? 'Underweight' : (_bmi < 25 ? 'Normal' : (_bmi < 30 ? 'Overweight' : 'Obese')),
              color: _bmi < 25 ? AppColors.success : (_bmi < 30 ? AppColors.warning : AppColors.error),
            ),
          ]),
        ),

        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => setState(() => _showResults = true),
          icon: const Icon(Icons.bar_chart_rounded, size: 20),
          label: const Text('Calculate My Risk'),
        ),

        if (_showResults) ...[
          const SizedBox(height: 20),
          Text('Your Risk Assessment', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          _DiseaseRiskCard(condition: 'Diabetes',     emoji: '🩸', level: _diabetesRisk(),  advice: _diseaseAdvice('Diabetes',     _diabetesRisk()),  riskColor: _riskColor(_diabetesRisk()),  riskLabel: _riskLabel(_diabetesRisk()),  riskEmoji: _riskEmoji(_diabetesRisk())),
          const SizedBox(height: 10),
          _DiseaseRiskCard(condition: 'Heart Disease', emoji: '❤️', level: _heartRisk(),    advice: _diseaseAdvice('Heart Disease', _heartRisk()),    riskColor: _riskColor(_heartRisk()),    riskLabel: _riskLabel(_heartRisk()),    riskEmoji: _riskEmoji(_heartRisk())),
          const SizedBox(height: 10),
          _DiseaseRiskCard(condition: 'Blood Pressure',emoji: '💉', level: _bpRisk(),       advice: _diseaseAdvice('Blood Pressure', _bpRisk()),       riskColor: _riskColor(_bpRisk()),       riskLabel: _riskLabel(_bpRisk()),       riskEmoji: _riskEmoji(_bpRisk())),
          const SizedBox(height: 10),
          _DiseaseRiskCard(condition: 'Obesity',       emoji: '⚖️', level: _obesityRisk(),  advice: _diseaseAdvice('Obesity',       _obesityRisk()),  riskColor: _riskColor(_obesityRisk()),  riskLabel: _riskLabel(_obesityRisk()),  riskEmoji: _riskEmoji(_obesityRisk())),
          const SizedBox(height: 16),
          const DisclaimerCard(message: 'This is a basic wellness risk estimate and NOT a medical diagnosis. Please consult your doctor for accurate health assessments.'),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  // ── TAB 2: NUTRIENT DEFICIENCY ───────────────────────────────────────────
  Widget _buildNutrientTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        GBCard(
          color: AppColors.primarySurface,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🥗', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Nutrient Deficiency Check', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
              Text('Tell us about your daily diet to detect possible nutrient gaps and their real causes.', style: Theme.of(context).textTheme.bodyMedium),
            ])),
          ]),
        ),

        const SizedBox(height: 14),

        GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('What do you eat regularly?', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text('Toggle what you typically include in your daily diet', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _DietToggle('🥬 Green Vegetables',  'Spinach, methi, broccoli',       _eatsGreenVeg,  (v) => setState(() => _eatsGreenVeg  = v)),
          const Divider(),
          _DietToggle('🥛 Dairy Products',    'Milk, curd, paneer, cheese',     _eatsDairy,     (v) => setState(() => _eatsDairy     = v)),
          const Divider(),
          _DietToggle('🍎 Fruits',            'Banana, mango, papaya, berries', _eatsFruits,    (v) => setState(() => _eatsFruits    = v)),
          const Divider(),
          _DietToggle('🥜 Nuts & Seeds',      'Almonds, peanuts, sesame',       _eatsNuts,      (v) => setState(() => _eatsNuts      = v)),
          const Divider(),
          _DietToggle('🫘 Legumes & Dal',     'Rajma, chana, moong, toor dal',  _eatsLegumes,   (v) => setState(() => _eatsLegumes   = v)),
          const Divider(),
          _DietToggle('🥛 Drinks Milk Daily', 'At least 1 glass per day',       _drinksMilk,    (v) => setState(() => _drinksMilk    = v)),
          const Divider(),
          _DietToggle('🥚 Eggs',              'At least 3x per week',           _eatsEggs,      (v) => setState(() => _eatsEggs      = v)),
          const Divider(),
          _DietToggle('☀️ Morning Sunlight',  '15–20 min exposure daily',       _sunExposure,   (v) => setState(() => _sunExposure   = v)),
        ])),

        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => setState(() => _showNutrient = true),
          icon: const Icon(Icons.science_outlined, size: 20),
          label: const Text('Check My Nutrients'),
        ),

        if (_showNutrient) ...[
          const SizedBox(height: 20),
          Text('Nutrient Analysis', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Based on your diet habits', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 10),

          ..._analyseNutrients().map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _NutrientCard(result: r, riskColor: _riskColor(r.level), riskEmoji: _riskEmoji(r.level)),
          )),

          const SizedBox(height: 16),
          const DisclaimerCard(message: 'Nutrient analysis is based on diet inputs only and is NOT a medical diagnosis. Please consult a doctor or dietitian for a proper assessment.'),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// Slider helper
class _SF extends StatelessWidget {
  final String label; final double value; final double min; final double max;
  final int div; final Color color; final ValueChanged<double> onChanged;
  const _SF(this.label, this.value, this.min, this.max, this.div, this.color, this.onChanged);

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: Theme.of(context).textTheme.titleSmall),
    Slider(value: value.clamp(min, max), min: min, max: max, divisions: div, activeColor: color, inactiveColor: AppColors.divider, label: value.toStringAsFixed(1), onChanged: onChanged),
  ]);
}

// Diet toggle row
class _DietToggle extends StatelessWidget {
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _DietToggle(this.title, this.subtitle, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,    style: Theme.of(context).textTheme.titleSmall),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
    ])),
    Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
  ]);
}

// Disease risk card
class _DiseaseRiskCard extends StatelessWidget {
  final String condition, emoji, advice, riskEmoji, riskLabel;
  final RiskLevel level;
  final Color riskColor;
  const _DiseaseRiskCard({
    required this.condition, required this.emoji, required this.level,
    required this.advice, required this.riskColor, required this.riskEmoji,
    required this.riskLabel,
  });

  @override
  Widget build(BuildContext context) => GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 28)), const SizedBox(width: 12),
      Expanded(child: Text(condition, style: Theme.of(context).textTheme.titleSmall)),
      StatusChip(label: '$riskEmoji $riskLabel', color: riskColor),
    ]),
    const SizedBox(height: 10),
    GBProgressBar(
      value: level == RiskLevel.low ? 0.2 : (level == RiskLevel.moderate ? 0.6 : 0.9),
      color: riskColor, height: 8,
    ),
    const SizedBox(height: 10),
    Text(advice, style: Theme.of(context).textTheme.bodyMedium),
  ]));
}

// Nutrient result data class
class _NutrientResult {
  final String nutrient, emoji, warning;
  final RiskLevel level;
  final List<String> symptoms, foods;
  const _NutrientResult({
    required this.nutrient, required this.emoji, required this.level,
    required this.symptoms, required this.foods, required this.warning,
  });
}

// Nutrient deficiency card
class _NutrientCard extends StatefulWidget {
  final _NutrientResult result;
  final Color riskColor;
  final String riskEmoji;
  const _NutrientCard({required this.result, required this.riskColor, required this.riskEmoji});

  @override
  State<_NutrientCard> createState() => _NutrientCardState();
}

class _NutrientCardState extends State<_NutrientCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header row
      GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Row(children: [
          Text(r.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.nutrient, style: Theme.of(context).textTheme.titleSmall),
            Text(r.level == RiskLevel.low ? 'No deficiency detected' : 'Possible deficiency',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ])),
          StatusChip(label: '${widget.riskEmoji} ${r.level.label}', color: widget.riskColor),
          const SizedBox(width: 8),
          Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textSecondary),
        ]),
      ),

      // Warning banner
      if (r.level != RiskLevel.low) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.riskColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.riskColor.withValues(alpha: 0.3)),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.warning_amber_rounded, color: widget.riskColor, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(r.warning, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: widget.riskColor))),
          ]),
        ),
      ],

      // Expanded details
      if (_expanded) ...[
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),

        // Symptoms
        Text('Symptoms you may notice', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: r.symptoms.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Text(s, style: const TextStyle(fontSize: 11, color: AppColors.error)),
          )).toList(),
        ),

        const SizedBox(height: 12),

        // Foods to eat
        Text('Foods to include', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: r.foods.map((f) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
            ),
            child: Text('🍽 $f', style: const TextStyle(fontSize: 11, color: AppColors.success)),
          )).toList(),
        ),
      ],
    ]));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE SCREEN (unchanged from your original)
// ─────────────────────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile       = context.watch<UserProfileProvider>().profile;
    final accessibility = context.watch<AccessibilityProvider>();
    final auth          = context.read<AuthProvider>();

    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: EmptyStateWidget(
          emoji: '👤', title: 'No Profile Found',
          subtitle: 'Please complete your profile setup',
          actionLabel: 'Setup Profile',
          onAction: () => Navigator.of(context).pushNamed('/profile-setup'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [

          // Avatar + Name
          GBCard(child: Row(children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(
                profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
              )),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(profile.name,  style: Theme.of(context).textTheme.titleLarge),
              Text(profile.email, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              StatusChip(label: 'Age ${profile.age}  •  BMI ${profile.bmi.toStringAsFixed(1)}', color: AppColors.primary),
            ])),
          ])),

          const SizedBox(height: 12),

          const SectionTitle(title: 'Health Profile'),
          const SizedBox(height: 8),
          GBCard(child: Column(children: [
            InfoRow(label: 'Weight',   value: '${profile.weight.toStringAsFixed(1)} kg',              icon: Icons.monitor_weight_outlined),
            InfoRow(label: 'Height',   value: '${profile.height.toStringAsFixed(0)} cm',              icon: Icons.height),
            InfoRow(label: 'BMI',      value: '${profile.bmi.toStringAsFixed(1)} (${profile.bmiCategory})', icon: Icons.bar_chart),
            InfoRow(label: 'Activity', value: profile.activityLevel.label.split('(').first.trim(),     icon: Icons.directions_walk),
            InfoRow(label: 'Food',     value: profile.foodPreference == FoodPreference.veg ? '🥦 Vegetarian' : '🍗 Non-Veg', icon: Icons.restaurant_outlined),
          ])),

          const SizedBox(height: 8),
          GBCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Health Conditions', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 6,
              children: profile.healthConditions.map((c) => StatusChip(
                label: c.label,
                color: c == HealthCondition.none ? AppColors.success : AppColors.warning,
              )).toList()),
          ])),

          const SizedBox(height: 16),

          const SectionTitle(title: '♿ Accessibility'),
          const SizedBox(height: 8),
          GBCard(child: Column(children: [
            _Toggle('Accessibility Mode', 'Large fonts, high contrast, bigger buttons',
              accessibility.accessibilityMode, (_) => context.read<AccessibilityProvider>().toggleAccessibilityMode()),
            const Divider(),
            _Toggle('Large Text',         'Increase font size throughout the app',
              accessibility.largeText,        (_) => context.read<AccessibilityProvider>().toggleLargeText()),
            const Divider(),
            _Toggle('High Contrast',      'Dark background for better readability',
              accessibility.highContrast,     (_) => context.read<AccessibilityProvider>().toggleHighContrast()),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.record_voice_over_outlined, color: AppColors.textSecondary),
              title: const Text('Voice Guidance'),
              subtitle: const Text('Text-to-speech for navigation'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('Coming Soon', style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w700)),
              ),
            ),
          ])),

          const SizedBox(height: 16),

          const SectionTitle(title: 'Settings'),
          const SizedBox(height: 8),
          GBCard(child: Column(children: [
            _Setting(Icons.edit_outlined,         'Edit Profile',           onTap: () {}),
            const Divider(),
            _Setting(Icons.notifications_outlined, 'Notification Settings', onTap: () {}),
            const Divider(),
            _Setting(Icons.privacy_tip_outlined,   'Privacy Policy',        onTap: () {}),
            const Divider(),
            _Setting(Icons.help_outline,           'Help & Support',        onTap: () {}),
            const Divider(),
            _Setting(Icons.logout, 'Sign Out', color: AppColors.error,
              onTap: () {
                auth.logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
              }),
          ])),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle(this.title, this.subtitle, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,    style: Theme.of(context).textTheme.titleSmall),
      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
    ])),
    Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
  ]);
}

class _Setting extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap; final Color? color;
  const _Setting(this.icon, this.title, {required this.onTap, this.color});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
    title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color)),
    trailing: Icon(Icons.chevron_right, color: color ?? AppColors.textSecondary, size: 20),
    onTap: onTap,
  );
}