
// lib/screens/profile_setup/profile_setup_screen.dart
// Multi-step profile setup wizard to collect health information

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Form state
  final _nameCtrl = TextEditingController();
  int _age = 45;
  Gender _gender = Gender.male;
  double _weight = 72.0;
  double _height = 165.0;
  final List<HealthCondition> _selectedConditions = [];
  FoodPreference _foodPref = FoodPreference.veg;
  ActivityLevel _activityLevel = ActivityLevel.moderate;

  @override
  void initState() {
    super.initState();
    // Pre-fill name from Firebase Auth if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.displayName.isNotEmpty && _nameCtrl.text.isEmpty) {
        _nameCtrl.text = auth.displayName;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveProfile() {
    final profile = UserProfile(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim().isEmpty ? 'User' : _nameCtrl.text.trim(),
      email: context.read<AuthProvider>().userEmail,
      age: _age,
      gender: _gender,
      weight: _weight,
      height: _height,
      healthConditions: _selectedConditions.isEmpty ? [HealthCondition.none] : _selectedConditions,
      foodPreference: _foodPref,
      activityLevel: _activityLevel,
    );
    context.read<UserProfileProvider>().setProfile(profile);
    context.read<HabitsProvider>().loadHabitsForProfile(profile);
    Navigator.of(context).pushReplacementNamed('/main');
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == _currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == _currentPage ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── Page 1: Basic Info ────────────────────────────────────────
  Widget _buildPage1() {
    return _SetupPage(
      emoji: '👤',
      title: 'Tell us about yourself',
      subtitle: 'This helps us personalize your health experience',
      child: Column(
        children: [
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Age: $_age years'),
          Slider(
            value: _age.toDouble(),
            min: 18,
            max: 90,
            divisions: 72,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.divider,
            label: '$_age',
            onChanged: (v) => setState(() => _age = v.round()),
          ),
          const SizedBox(height: 16),
          _SectionLabel(label: 'Gender'),
          const SizedBox(height: 8),
          Row(
            children: Gender.values.map((g) {
              final labels = ['Male', 'Female', 'Other'];
              final emojis = ['👨', '👩', '🧑'];
              final isSelected = _gender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Text(emojis[g.index], style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          labels[g.index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Page 2: Physical Stats ─────────────────────────────────────
  Widget _buildPage2() {
    return _SetupPage(
      emoji: '⚖️',
      title: 'Physical measurements',
      subtitle: 'Used to calculate BMI and personalize advice',
      child: Column(
        children: [
          GBCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: 'Weight: ${_weight.toStringAsFixed(1)} kg'),
                Slider(
                  value: _weight,
                  min: 30,
                  max: 150,
                  divisions: 120,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.divider,
                  label: '${_weight.toStringAsFixed(1)} kg',
                  onChanged: (v) => setState(() => _weight = double.parse(v.toStringAsFixed(1))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GBCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: 'Height: ${_height.toStringAsFixed(0)} cm'),
                Slider(
                  value: _height,
                  min: 100,
                  max: 220,
                  divisions: 120,
                  activeColor: AppColors.accent,
                  inactiveColor: AppColors.divider,
                  label: '${_height.toStringAsFixed(0)} cm',
                  onChanged: (v) => setState(() => _height = double.parse(v.toStringAsFixed(0))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // BMI preview
          GBCard(
            color: AppColors.primarySurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your BMI', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      (_weight / ((_height / 100) * (_height / 100))).toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                StatusChip(
                  label: _getBMICategory(),
                  color: _getBMIColor(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getBMICategory() {
    final bmi = _weight / ((_height / 100) * (_height / 100));
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor() {
    final bmi = _weight / ((_height / 100) * (_height / 100));
    if (bmi < 18.5) return AppColors.info;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  // ── Page 3: Health Conditions ──────────────────────────────────
  Widget _buildPage3() {
    return _SetupPage(
      emoji: '🏥',
      title: 'Health conditions',
      subtitle: 'Select any conditions you have. This helps us give personalized advice.',
      child: Column(
        children: [
          ...HealthCondition.values.map((condition) {
            final isNone = condition == HealthCondition.none;
            final isSelected = isNone
                ? _selectedConditions.isEmpty
                : _selectedConditions.contains(condition);
            final labels = ['Diabetes 🩸', 'High Blood Pressure 💓', 'Thyroid 🦋', 'None / I\'m Healthy ✅'];
            final descriptions = [
              'Type 1 or Type 2 Diabetes',
              'Hypertension or low BP',
              'Hypothyroid or Hyperthyroid',
              'No specific health conditions',
            ];

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isNone) {
                    _selectedConditions.clear();
                  } else {
                    _selectedConditions.remove(HealthCondition.none);
                    if (_selectedConditions.contains(condition)) {
                      _selectedConditions.remove(condition);
                    } else {
                      _selectedConditions.add(condition);
                    }
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primarySurface : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(labels[condition.index],
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                  )),
                          Text(descriptions[condition.index],
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Page 4: Preferences ────────────────────────────────────────
  Widget _buildPage4() {
    return _SetupPage(
      emoji: '🌿',
      title: 'Lifestyle preferences',
      subtitle: 'Helps us suggest personalized meal and activity plans',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'Food Preference'),
          const SizedBox(height: 10),
          Row(
            children: [
              _PreferenceChip(
                label: '🥦 Vegetarian',
                selected: _foodPref == FoodPreference.veg,
                onTap: () => setState(() => _foodPref = FoodPreference.veg),
              ),
              const SizedBox(width: 12),
              _PreferenceChip(
                label: '🍗 Non-Vegetarian',
                selected: _foodPref == FoodPreference.nonVeg,
                onTap: () => setState(() => _foodPref = FoodPreference.nonVeg),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Activity Level'),
          const SizedBox(height: 10),
          Column(
            children: ActivityLevel.values.map((level) {
              final isSelected = _activityLevel == level;
              final emojis = ['🪑', '🚶', '🏃'];
              final descriptions = [
                'Little or no physical activity',
                'Light exercise a few times a week',
                'Intense exercise most days',
              ];
              return GestureDetector(
                onTap: () => setState(() => _activityLevel = level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySurface : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(emojis[level.index], style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level.label.split('(').first.trim(),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: isSelected ? AppColors.primary : null,
                                  ),
                            ),
                            Text(descriptions[level.index], style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildPage1(), _buildPage2(), _buildPage3(), _buildPage4()];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: _prevPage,
                color: AppColors.textPrimary,
              )
            : null,
        title: Text('Profile Setup (${_currentPage + 1}/$_totalPages)'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: _buildPageIndicator(),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              children: pages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: _nextPage,
              child: Text(_currentPage < _totalPages - 1 ? 'Continue →' : 'Get Started 🎉'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────
class _SetupPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget child;

  const _SetupPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 28),
          child,
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary));
  }
}

class _PreferenceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PreferenceChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySurface : AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: selected ? AppColors.primary : null)),
        ),
      ),
    );
  }
}