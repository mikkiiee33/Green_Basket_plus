// lib/screens/lifestyle/lifestyle_screen.dart
// Lifestyle reminders with consistency tracking

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../models/models.dart';

class LifestyleScreen extends StatelessWidget {
  const LifestyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lifestyle = context.watch<LifestyleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Lifestyle Reminders')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          //  Weekly Consistency 
          GBCard(
            color: AppColors.primarySurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Consistency',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: lifestyle.overallConsistency / 100,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                          ),
                          Text(
                            '${lifestyle.overallConsistency.toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${lifestyle.completedToday} / ${lifestyle.reminders.length} done today',
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          // 7-day bar chart
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((e) {
                              // Aggregate completion for the day
                              final dayDone = lifestyle.reminders
                                  .map((r) => r.doneHistory.length > e.key ? r.doneHistory[e.key] : 0)
                                  .reduce((a, b) => a + b);
                              final total = lifestyle.reminders.length;
                              final ratio = total == 0 ? 0.0 : dayDone / total;
                              return Column(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 40 * ratio.toDouble() + 4,
                                    decoration: BoxDecoration(
                                      color: ratio >= 0.7 ? AppColors.primary : (ratio >= 0.4 ? AppColors.primaryLighter : AppColors.divider),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(e.value, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SectionTitle(title: 'Today\'s Reminders'),
          const SizedBox(height: 8),

          ...lifestyle.reminders.map((r) => _ReminderTile(reminder: r)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final LifestyleReminder reminder;
  const _ReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<LifestyleProvider>().toggleDone(reminder.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: reminder.isDone ? AppColors.primarySurface : AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: reminder.isDone ? AppColors.primary : AppColors.divider,
            width: reminder.isDone ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(reminder.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            decoration: reminder.isDone ? TextDecoration.lineThrough : null,
                            color: reminder.isDone ? AppColors.textSecondary : null,
                          )),
                  Text(reminder.subtitle, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(reminder.time, style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GBProgressBar(
                          value: reminder.consistencyPercentage / 100,
                          height: 5,
                          color: reminder.consistencyPercentage >= 70 ? AppColors.success : AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('${reminder.consistencyPercentage.toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: reminder.consistencyPercentage >= 70 ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.w700,
                              )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: reminder.isDone ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: reminder.isDone ? AppColors.primary : AppColors.textLight,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: reminder.isDone ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }
}


// Preventive health checkup tracker


class CheckupsScreen extends StatelessWidget {
  const CheckupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final checkups = context.watch<CheckupsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Preventive Checkups')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
         
          GBCard(
            color: AppColors.primarySurface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _CheckupStat(
                  label: 'Total',
                  value: '${checkups.checkups.length}',
                  color: AppColors.primary,
                ),
                Container(width: 1, height: 40, color: AppColors.divider),
                _CheckupStat(
                  label: 'Due Now',
                  value: '${checkups.dueCheckups.length}',
                  color: AppColors.error,
                ),
                Container(width: 1, height: 40, color: AppColors.divider),
                _CheckupStat(
                  label: 'Upcoming',
                  value: '${checkups.upcomingCheckups.length}',
                  color: AppColors.warning,
                ),
              ],
            ),
          ),

          if (checkups.dueCheckups.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionTitle(title: '🔴 Due Now'),
            const SizedBox(height: 8),
            ...checkups.dueCheckups.map((c) => _CheckupCard(checkup: c)),
          ],

          if (checkups.upcomingCheckups.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionTitle(title: '🟡 Coming Up'),
            const SizedBox(height: 8),
            ...checkups.upcomingCheckups.map((c) => _CheckupCard(checkup: c)),
          ],

          const SizedBox(height: 16),
          SectionTitle(title: 'All Checkups'),
          const SizedBox(height: 8),
          ...checkups.checkups.where((c) => !c.isDue && c.daysUntilDue > 14).map((c) => _CheckupCard(checkup: c)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CheckupStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _CheckupStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CheckupCard extends StatelessWidget {
  final Checkup checkup;
  const _CheckupCard({required this.checkup});

  @override
  Widget build(BuildContext context) {
    return GBCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (checkup.isDue ? AppColors.error : AppColors.warning).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(checkup.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(checkup.name, style: Theme.of(context).textTheme.titleSmall),
                    Text(checkup.description, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    if (checkup.lastDone != null)
                      Text(
                        'Last done: ${_formatDate(checkup.lastDone!)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      )
                    else
                      Text('Never done', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.error)),
                  ],
                ),
              ),
              StatusChip(
                label: checkup.isDue ? 'Due Now' : 'In ${checkup.daysUntilDue}d',
                color: checkup.isDue ? AppColors.error : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CheckupsProvider>().markDone(checkup.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${checkup.name} marked as done ✅'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Mark as Done'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              backgroundColor: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
