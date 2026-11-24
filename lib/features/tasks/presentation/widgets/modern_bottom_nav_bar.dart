import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/haptic_feedback_util.dart';

/// Specification item for [ModernBottomNavBar].
class ModernNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const ModernNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// A modern, edge-to-edge glassmorphic bottom navigation bar with:
/// - Smooth expanding pill indicator for the active tab.
/// - Spring-scale micro-interaction bounce on icon change.
/// - Full-width flush layout (no awkward side gaps).
/// - Natural bottom docking with safe area inset handling.
/// - Palette-reactive ambient glow and active state accents.
class ModernBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final List<ModernNavItem> items;
  final AppThemePalette palette;

  const ModernBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = palette.primaryColor;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF101322).withValues(alpha: 0.90)
            : Colors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF272C48).withValues(alpha: 0.85)
                : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.10 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              8,
              6,
              8,
              math.max(bottomInset, 8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == selectedIndex;

                return _ModernNavBarItemWidget(
                  item: item,
                  isSelected: isSelected,
                  primaryColor: primary,
                  palette: palette,
                  isDark: isDark,
                  onTap: () {
                    if (index != selectedIndex) {
                      HapticFeedbackUtil.selection();
                      onItemSelected(index);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernNavBarItemWidget extends StatelessWidget {
  final ModernNavItem item;
  final bool isSelected;
  final Color primaryColor;
  final AppThemePalette palette;
  final bool isDark;
  final VoidCallback onTap;

  const _ModernNavBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.primaryColor,
    required this.palette,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? primaryColor.withValues(alpha: isDark ? 0.50 : 0.38)
                : Colors.transparent,
            width: 1.0,
          ),
        ),
        child: ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spring-scale animated icon
                TweenAnimationBuilder<double>(
                  key: ValueKey(isSelected),
                  tween: Tween(begin: isSelected ? 0.65 : 1.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: isSelected ? 21 : 22,
                    color: isSelected
                        ? primaryColor
                        : (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B)),
                  ),
                ),
                // Smoothly expanding and fading label
                if (isSelected) ...[
                  const SizedBox(width: 7),
                  AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
