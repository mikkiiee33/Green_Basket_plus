// lib/models/habit.dart

import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isCompleted;
  final bool isPersonalized;
  final String category;

  Habit({
    String? id,
    required this.title,
    required this.description,
    required this.icon,
    this.isCompleted = false,
    this.isPersonalized = false,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  Habit copyWith({bool? isCompleted}) => Habit(
        id: id,
        title: title,
        description: description,
        icon: icon,
        isCompleted: isCompleted ?? this.isCompleted,
        isPersonalized: isPersonalized,
        category: category,
      );

  static List<Habit> buildFor({
    bool hasDiabetes = false,
    bool hasBP = false,
    bool hasThyroid = false,
    bool isVeg = true,
  }) {
    final List<Habit> habits = [
      Habit(id: 'h1', title: 'Eat 1 Fruit',          description: 'Have a fresh seasonal fruit today',               icon: '🍎', category: 'Nutrition'),
      Habit(id: 'h2', title: 'Eat Vegetables',        description: 'At least 1 serving of vegetables',               icon: '🥦', category: 'Nutrition'),
      Habit(id: 'h3', title: 'Add Protein',           description: isVeg ? 'Dal, beans, paneer or nuts' : 'Egg, dal, beans or chicken', icon: '🥚', category: 'Nutrition'),
      Habit(id: 'h4', title: 'Drink Water',           description: '2–3 liters throughout the day',                  icon: '💧', category: 'Hydration'),
      Habit(id: 'h5', title: 'Avoid Processed Food',  description: 'Skip chips, biscuits, packaged snacks',          icon: '🚫', category: 'Nutrition'),
      Habit(id: 'h6', title: '20 Min Walk',           description: 'Brisk walk or light exercise',                   icon: '🚶', category: 'Fitness'),
      Habit(id: 'h7', title: 'Sleep 7–8 Hours',       description: 'Good sleep supports immunity & metabolism',      icon: '😴', category: 'Wellness'),
    ];

    if (hasDiabetes) {
      habits.addAll([
        Habit(id: 'hd1', title: 'Reduce Sugar',      description: 'Avoid sweets, sugary drinks & white rice', icon: '🍬', category: 'Diabetes Care', isPersonalized: true),
        Habit(id: 'hd2', title: 'Increase Fiber',    description: 'Whole grains, oats, vegetables',           icon: '🌾', category: 'Diabetes Care', isPersonalized: true),
        Habit(id: 'hd3', title: 'Eat Small Meals',   description: '4–5 small meals instead of 3 large',       icon: '🍽️', category: 'Diabetes Care', isPersonalized: true),
      ]);
    }

    if (hasBP) {
      habits.addAll([
        Habit(id: 'hb1', title: 'Reduce Salt',          description: 'Less than 5g salt per day',                    icon: '🧂', category: 'BP Care', isPersonalized: true),
        Habit(id: 'hb2', title: 'Avoid Packaged Food',  description: 'High sodium in packaged items',                icon: '📦', category: 'BP Care', isPersonalized: true),
        Habit(id: 'hb3', title: 'Deep Breathing',       description: '10-minute breathing exercise',                 icon: '🧘', category: 'BP Care', isPersonalized: true),
      ]);
    }

    if (hasThyroid) {
      habits.addAll([
        Habit(id: 'ht1', title: 'Cruciferous Moderation', description: 'Limit raw cabbage, broccoli when hypothyroid', icon: '🥬', category: 'Thyroid Care', isPersonalized: true),
        Habit(id: 'ht2', title: 'Medicine on Time',       description: 'Thyroid medicine timing is critical',          icon: '💊', category: 'Thyroid Care', isPersonalized: true),
      ]);
    }

    return habits;
  }
}
