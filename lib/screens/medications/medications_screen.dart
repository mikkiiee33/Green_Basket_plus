// lib/screens/medications/medications_screen.dart
// Full medication reminder management with add/edit/delete

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meds = context.watch<MedicationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showAddMedDialog(context),
          ),
        ],
      ),
      body: meds.medications.isEmpty
          ? EmptyStateWidget(
              emoji: '💊',
              title: 'No medicines added',
              subtitle: 'Add your medicines to get daily reminders and track adherence',
              actionLabel: 'Add Medicine',
              onAction: () => _showAddMedDialog(context),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // Adherence Summary 
                GBCard(
                  color: AppColors.primarySurface,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: meds.adherencePercentage / 100,
                              backgroundColor: AppColors.divider,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                meds.adherencePercentage >= 80 ? AppColors.success : AppColors.warning,
                              ),
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                            ),
                            Text(
                              '${meds.adherencePercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: meds.adherencePercentage >= 80 ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Adherence Today',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
                            const SizedBox(height: 4),
                            Text('${meds.takenToday} of ${meds.totalCount} medicines taken',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            StatusChip(
                              label: meds.adherencePercentage >= 80 ? '🎉 Great Job!' : '⚠️ Stay on Track',
                              color: meds.adherencePercentage >= 80 ? AppColors.success : AppColors.warning,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SectionTitle(
                  title: 'Today\'s Medicines',
                  actionLabel: '+ Add',
                  onAction: () => _showAddMedDialog(context),
                ),
                const SizedBox(height: 8),

                //  Med List 
                ...meds.medications.map((med) => _MedicationCard(med: med)),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  void _showAddMedDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMedicationSheet(),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication med;
  const _MedicationCard({required this.med});

  Color get _statusColor {
    switch (med.status) {
      case MedicationStatus.taken: return AppColors.success;
      case MedicationStatus.missed: return AppColors.error;
      case MedicationStatus.pending: return AppColors.warning;
    }
  }

  String get _statusLabel {
    switch (med.status) {
      case MedicationStatus.taken: return '✅ Taken';
      case MedicationStatus.missed: return '❌ Missed';
      case MedicationStatus.pending: return '⏳ Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GBCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('💊', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name, style: Theme.of(context).textTheme.titleSmall),
                    Row(
                      children: [
                        const Icon(Icons.schedule_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${med.time}  •  ${med.dosage}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              StatusChip(label: _statusLabel, color: _statusColor),
            ],
          ),
          if (med.notes != null && med.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(med.notes!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              if (med.status != MedicationStatus.taken)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<MedicationsProvider>().markTaken(med.id),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Mark Taken'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              if (med.status != MedicationStatus.missed) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.read<MedicationsProvider>().markMissed(med.id),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Missed'),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                onPressed: () => _showEditDialog(context, med),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _confirmDelete(context, med),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Medication med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMedicationSheet(existingMed: med),
    );
  }

  void _confirmDelete(BuildContext context, Medication med) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Remove ${med.name} from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MedicationsProvider>().deleteMedication(med.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Add/Edit Medication Bottom Sheet ─────────────────────────
class _AddMedicationSheet extends StatefulWidget {
  final Medication? existingMed;
  const _AddMedicationSheet({this.existingMed});

  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _dosageCtrl;
  late TextEditingController _notesCtrl;
  String _time = '08:00';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existingMed?.name ?? '');
    _dosageCtrl = TextEditingController(text: widget.existingMed?.dosage ?? '');
    _notesCtrl = TextEditingController(text: widget.existingMed?.notes ?? '');
    _time = widget.existingMed?.time ?? '08:00';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final parts = _time.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
    );
    if (picked != null) {
      setState(() => _time = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final med = Medication(
      id: widget.existingMed?.id,
      name: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim().isEmpty ? 'As prescribed' : _dosageCtrl.text.trim(),
      time: _time,
      weekDays: List.filled(7, true),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    if (widget.existingMed != null) {
      context.read<MedicationsProvider>().updateMedication(med);
    } else {
      context.read<MedicationsProvider>().addMedication(med);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Text(widget.existingMed != null ? 'Edit Medicine' : 'Add Medicine',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Medicine Name *',
              prefixIcon: Icon(Icons.medication_outlined, color: AppColors.primary),
              hintText: 'e.g. Metformin',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _dosageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    prefixIcon: Icon(Icons.scale_outlined, color: AppColors.primary),
                    hintText: 'e.g. 500mg',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryLighter.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(_time, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesCtrl,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              prefixIcon: Icon(Icons.notes_outlined, color: AppColors.primary),
              hintText: 'e.g. Take with meals',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            child: Text(widget.existingMed != null ? 'Update Medicine' : 'Add Medicine'),
          ),
        ],
      ),
    );
  }
}
