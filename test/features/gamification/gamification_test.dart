import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskora/features/gamification/domain/gamification_models.dart';
import 'package:taskora/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:taskora/features/tasks/domain/priority_enum.dart';
import 'package:taskora/features/tasks/domain/recurrence_enum.dart';
import 'package:taskora/features/tasks/domain/task_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GamificationStats Model Tests', () {
    test('computes level curves and titles correctly', () {
      const stats0 = GamificationStats(totalXp: 0);
      expect(stats0.level, equals(1));
      expect(stats0.levelTitle, equals('Apprentice Initiate'));
      expect(stats0.levelProgress, equals(0.0));

      const statsLvl2 = GamificationStats(totalXp: 150);
      expect(statsLvl2.level, equals(2));
      expect(statsLvl2.levelTitle, equals('Focus Explorer'));
      expect(statsLvl2.currentLevelBaseXp, equals(100));
      expect(statsLvl2.nextLevelTargetXp, equals(250));
      expect(statsLvl2.levelProgress, closeTo(0.333, 0.01));

      const statsLvl5 = GamificationStats(totalXp: 750);
      expect(statsLvl5.level, equals(5));
      expect(statsLvl5.levelTitle, equals('Productivity Architect'));
    });

    test('evaluates streak status accurately', () {
      final now = DateTime.now();

      // No completions yet
      const statsEmpty = GamificationStats();
      expect(statsEmpty.isStreakActiveToday, isFalse);
      expect(statsEmpty.isStreakAtRisk, isFalse);

      // Completed today
      final statsToday = GamificationStats(
        currentStreak: 4,
        lastCompletionDate: now,
      );
      expect(statsToday.isStreakActiveToday, isTrue);
      expect(statsToday.isStreakAtRisk, isFalse);

      // Completed yesterday (at risk today!)
      final yesterday = now.subtract(const Duration(days: 1));
      final statsYesterday = GamificationStats(
        currentStreak: 4,
        lastCompletionDate: yesterday,
      );
      expect(statsYesterday.isStreakActiveToday, isFalse);
      expect(statsYesterday.isStreakAtRisk, isTrue);
    });

    test('serializes and deserializes cleanly', () {
      final now = DateTime.now();
      final stats = GamificationStats(
        totalXp: 450,
        currentStreak: 5,
        bestStreak: 12,
        lastCompletionDate: now,
        unlockedBadgeIds: const ['first_spark', 'streak_3'],
        totalTasksCompleted: 15,
        totalUrgentCompleted: 4,
        totalSubtasksCompleted: 8,
        totalFocusMinutes: 50,
      );

      final json = stats.toJson();
      final revived = GamificationStats.fromJson(json);

      expect(revived.totalXp, equals(450));
      expect(revived.currentStreak, equals(5));
      expect(revived.bestStreak, equals(12));
      expect(revived.unlockedBadgeIds, contains('first_spark'));
      expect(revived.totalTasksCompleted, equals(15));
      expect(revived.totalUrgentCompleted, equals(4));
      expect(revived.totalSubtasksCompleted, equals(8));
      expect(revived.totalFocusMinutes, equals(50));
    });
  });

  group('GamificationNotifier Logic Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('records first task completion and unlocks First Spark badge', () async {
      final notifier = GamificationNotifier(prefs);

      final task = Task(
        id: 'test-1',
        title: 'Complete important documentation',
        isCompleted: true,
        priority: TaskPriority.high,
        recurrence: TaskRecurrence.none,
        createdAt: DateTime.now(),
      );

      final reward = await notifier.recordTaskCompletion(task);

      // 25 base + 25 high priority + 50 badge reward = 100 XP
      expect(reward.xpEarned, equals(100));
      expect(reward.newTotalXp, equals(100));
      expect(reward.currentStreak, equals(1));
      expect(reward.unlockedBadge?.id, equals('first_spark'));
      expect(notifier.state.totalTasksCompleted, equals(1));
      expect(notifier.state.unlockedBadgeIds, contains('first_spark'));
    });

    test('awards focus session XP and unlocks Deep Focus badge after 60 mins', () async {
      final notifier = GamificationNotifier(prefs);

      // 25-minute Pomodoro (25 + 25 bonus = 50 XP)
      final r1 = await notifier.recordFocusSession(25);
      expect(r1.xpEarned, equals(50));
      expect(notifier.state.totalFocusMinutes, equals(25));

      // Another 40 minutes (40 XP + 200 Deep Focus badge = 240 XP)
      final r2 = await notifier.recordFocusSession(40);
      expect(notifier.state.totalFocusMinutes, equals(65));
      expect(notifier.state.unlockedBadgeIds, contains('deep_focus'));
      expect(r2.unlockedBadge?.id, equals('deep_focus'));
    });
  });
}
