// lib/models/medication.dart
// Data model for medication reminders

import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String time;         // "HH:mm" format
  final List<bool> weekDays; // Mon=0 ... Sun=6
  final MedicationStatus status;
  final String? notes;

  Medication({
    String? id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.weekDays,
    this.status = MedicationStatus.pending,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Medication copyWith({
    String? name,
    String? dosage,
    String? time,
    List<bool>? weekDays,
    MedicationStatus? status,
    String? notes,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      weekDays: weekDays ?? this.weekDays,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'time': time,
        'weekDays': weekDays,
        'status': status.index,
        'notes': notes,
      };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'],
        name: json['name'],
        dosage: json['dosage'],
        time: json['time'],
        weekDays: List<bool>.from(json['weekDays']),
        status: MedicationStatus.values[json['status']],
        notes: json['notes'],
      );

  // Mock data
  static List<Medication> get mockList => [
        Medication(
          id: 'med_001',
          name: 'Metformin',
          dosage: '500mg',
          time: '08:00',
          weekDays: List.filled(7, true),
          status: MedicationStatus.taken,
          notes: 'Take with breakfast',
        ),
        Medication(
          id: 'med_002',
          name: 'Amlodipine',
          dosage: '5mg',
          time: '09:00',
          weekDays: List.filled(7, true),
          status: MedicationStatus.pending,
          notes: 'For blood pressure',
        ),
        Medication(
          id: 'med_003',
          name: 'Vitamin D3',
          dosage: '60000 IU',
          time: '10:00',
          weekDays: [true, false, false, false, false, false, false], // Weekly
          status: MedicationStatus.pending,
          notes: 'Once a week, Sunday',
        ),
      ];
}

// Tracks a day's adherence record
class AdherenceRecord {
  final DateTime date;
  final int totalMeds;
  final int takenMeds;

  const AdherenceRecord({
    required this.date,
    required this.totalMeds,
    required this.takenMeds,
  });

  double get percentage => totalMeds == 0 ? 0 : (takenMeds / totalMeds) * 100;
}
