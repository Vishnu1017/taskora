import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/haptic_feedback_util.dart';
import '../providers/gamification_provider.dart';
import 'achievements_modal.dart';

/// Interactive Daily Streak & Productivity Level card for the Dashboard.
class StreakLevelCard extends ConsumerStatefulWidget {
  const StreakLevelCard({super.key});

  @override
  ConsumerState<StreakLevelCard> createState() => _StreakLevelCardState();
}

class _StreakLevelCardState extends ConsumerState<StreakLevelCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = ref.watch(themePaletteProvider);
    final stats = ref.watch(gamificationProvider);

    final flameColor = stats.currentStreak > 0
        ? (stats.isStreakAtRisk
            ? const Color(0xFFF59E0B) // Amber warning
            : const Color(0xFFEF4444)) // Fiery Crimson
        : Colors.grey;

    return InkWell(
      onTap: () {
        HapticFeedbackUtil.selection();
        AchievementsModal.show(context);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B).withValues(alpha: 0.7)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: stats.currentStreak > 0
                ? palette.primaryColor.withValues(alpha: 0.35)
                : theme.colorScheme.outlineVariant,
            width: stats.currentStreak > 0 ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: stats.currentStreak > 0
                  ? palette.primaryColor.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Animated Flame Streak Section
                ScaleTransition(
                  scale: stats.currentStreak > 0
                      ? _pulseScale
                      : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: flameColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: flameColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        stats.currentStreak > 0
                            ? Icons.local_fire_department_rounded
                            : Icons.local_fire_department_outlined,
                        color: flameColor,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Streak & Rank Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                stats.currentStreak > 0
                                    ? '${stats.currentStreak} Day Streak'
                                    : 'Start Streak',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              if (stats.isStreakActiveToday) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF10B981),
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: palette.primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Lvl ${stats.level}',
                              style: TextStyle(
                                color: palette.primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${stats.levelTitle} • ${stats.totalXp} Total XP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Level Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: stats.levelProgress,
                          minHeight: 6,
                          backgroundColor: isDark
                              ? Colors.black26
                              : Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            palette.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Bottom interactive pill: Hall of Fame trigger & status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    stats.streakStatusMessage,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: stats.isStreakAtRisk
                          ? const Color(0xFFF59E0B)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hall of Fame (${stats.unlockedBadgeIds.length})',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: palette.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: palette.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
