// lib/models/lifestyle_reminder.dart

class LifestyleReminder {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String time;
  final bool isDone;
  final bool isWeekly;
  final List<int> doneHistory; // 7 values: 1 = done, 0 = missed

  const LifestyleReminder({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.time,
    this.isDone = false,
    this.isWeekly = false,
    this.doneHistory = const [1, 1, 0, 1, 1, 0, 1],
  });

  LifestyleReminder copyWith({bool? isDone}) => LifestyleReminder(
        id: id,
        title: title,
        subtitle: subtitle,
        icon: icon,
        time: time,
        isDone: isDone ?? this.isDone,
        isWeekly: isWeekly,
        doneHistory: doneHistory,
      );

  double get consistencyPercentage {
    if (doneHistory.isEmpty) return 0;
    return (doneHistory.where((d) => d == 1).length / doneHistory.length) * 100;
  }
}
