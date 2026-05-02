// lib/screens/habits/habits_screen.dart
// Daily habit checklist with health condition personalization

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitsProvider>();
    final profile = context.watch<UserProfileProvider>().profile;

    // Group habits by category
    final Map<String, List<_HabitItem>> grouped = {};
    for (final h in habits.habits) {
      grouped.putIfAbsent(h.category, () => []);
      grouped[h.category]!.add(_HabitItem(habit: h));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daily Habits'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            onPressed: () {
              context.read<HabitsProvider>().resetDaily();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Habits reset for today'), backgroundColor: AppColors.primary),
              );
            },
          ),
        ],
      ),
      body: habits.habits.isEmpty
          ? EmptyStateWidget(
              emoji: '🌱',
              title: 'No habits yet',
              subtitle: 'Complete your profile setup to see personalized habits',
              actionLabel: 'Setup Profile',
              onAction: () => Navigator.of(context).pushNamed('/profile-setup'),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Progress summary ──────────────────────────────
                      GBCard(
                        color: AppColors.primarySurface,
                        child: Row(
                          children: [
                            HealthScoreRing(score: habits.healthScore, size: 80),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Today\'s Progress',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
                                  const SizedBox(height: 4),
                                  Text('${habits.completedCount} of ${habits.habits.length} habits completed',
                                      style: Theme.of(context).textTheme.bodyMedium),
                                  const SizedBox(height: 10),
                                  GBProgressBar(
                                    value: habits.completionPercentage,
                                    height: 8,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(habits.completionPercentage * 100).toStringAsFixed(0)}% complete',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (profile?.hasDiabetes == true || profile?.hasBP == true || profile?.hasThyroid == true) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Personalized habits added based on your health conditions',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // ── Habit groups ──────────────────────────────────
                      ...grouped.entries.map((entry) {
                        final isPersonalized = entry.value.any((i) => i.habit.isPersonalized);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(entry.key,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textSecondary)),
                                if (isPersonalized) ...[
                                  const SizedBox(width: 6),
                                  StatusChip(label: 'Personalized', color: AppColors.accent),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...entry.value.map((item) => _HabitTile(habit: item.habit)),
                            const SizedBox(height: 16),
                          ],
                        );
                      }),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}

// Helper to hold habit reference
class _HabitItem {
  final habit;
  _HabitItem({required this.habit});
}

class _HabitTile extends StatelessWidget {
  final dynamic habit;
  const _HabitTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<HabitsProvider>().toggleHabit(habit.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: habit.isCompleted ? AppColors.primarySurface : AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: habit.isCompleted ? AppColors.primaryLight : AppColors.divider,
            width: habit.isCompleted ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: habit.isCompleted ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: habit.isCompleted ? AppColors.primary : AppColors.textLight,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: habit.isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(habit.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
                          color: habit.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                  ),
                  Text(
                    habit.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
