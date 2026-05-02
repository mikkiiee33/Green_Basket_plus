// lib/models/checkup.dart

class Checkup {
  final String id;
  final String name;
  final String description;
  final DateTime? lastDone;
  final int frequencyDays;
  final String icon;

  const Checkup({
    required this.id,
    required this.name,
    required this.description,
    this.lastDone,
    required this.frequencyDays,
    required this.icon,
  });

  DateTime? get nextDue => lastDone?.add(Duration(days: frequencyDays));

  bool get isDue {
    if (lastDone == null) return true;
    return DateTime.now().isAfter(nextDue!);
  }

  int get daysUntilDue {
    if (isDue) return 0;
    return nextDue!.difference(DateTime.now()).inDays;
  }

  Checkup copyWith({DateTime? lastDone}) => Checkup(
        id: id,
        name: name,
        description: description,
        lastDone: lastDone ?? this.lastDone,
        frequencyDays: frequencyDays,
        icon: icon,
      );

  static List<Checkup> get mockList => [
        Checkup(id: 'c1', name: 'Blood Pressure',       description: 'Check systolic/diastolic BP',        lastDone: DateTime.now().subtract(const Duration(days: 25)), frequencyDays: 30,  icon: '🩺'),
        Checkup(id: 'c2', name: 'Blood Sugar (HbA1c)',  description: 'Fasting & post-meal glucose test',   lastDone: DateTime.now().subtract(const Duration(days: 80)), frequencyDays: 90,  icon: '🩸'),
        Checkup(id: 'c3', name: 'Doctor Consultation',  description: 'General physician check-up',         lastDone: DateTime.now().subtract(const Duration(days: 50)), frequencyDays: 60,  icon: '👨‍⚕️'),
        Checkup(id: 'c4', name: 'Eye Check',            description: 'Vision and eye health exam',         lastDone: DateTime.now().subtract(const Duration(days: 300)), frequencyDays: 365, icon: '👁️'),
        Checkup(id: 'c5', name: 'Dental Check',         description: 'Oral hygiene and teeth check',       lastDone: DateTime.now().subtract(const Duration(days: 200)), frequencyDays: 180, icon: '🦷'),
        Checkup(id: 'c6', name: 'Kidney Function Test', description: 'Creatinine and urea levels',         lastDone: null,                                              frequencyDays: 180, icon: '🫘'),
      ];
}
