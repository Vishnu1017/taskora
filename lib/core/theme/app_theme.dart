import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'theme_provider.dart';

/// Semantic ThemeExtension exposing custom Taskora tokens across the widget tree.
@immutable
class TaskoraColorsExtension extends ThemeExtension<TaskoraColorsExtension> {
  final Color urgentPriority;
  final Color urgentPriorityContainer;
  final Color highPriority;
  final Color highPriorityContainer;
  final Color mediumPriority;
  final Color mediumPriorityContainer;
  final Color lowPriority;
  final Color lowPriorityContainer;

  final Color categoryWork;
  final Color categoryPersonal;
  final Color categoryHealth;
  final Color categoryStudy;
  final Color categoryFinance;

  final Color cardBorder;
  final Color surfaceSubtle;
  final Color textTertiary;

  const TaskoraColorsExtension({
    required this.urgentPriority,
    required this.urgentPriorityContainer,
    required this.highPriority,
    required this.highPriorityContainer,
    required this.mediumPriority,
    required this.mediumPriorityContainer,
    required this.lowPriority,
    required this.lowPriorityContainer,
    required this.categoryWork,
    required this.categoryPersonal,
    required this.categoryHealth,
    required this.categoryStudy,
    required this.categoryFinance,
    required this.cardBorder,
    required this.surfaceSubtle,
    required this.textTertiary,
  });

  static const TaskoraColorsExtension light = TaskoraColorsExtension(
    urgentPriority: AppColors.priorityUrgent,
    urgentPriorityContainer: AppColors.priorityUrgentContainer,
    highPriority: AppColors.priorityHigh,
    highPriorityContainer: AppColors.priorityHighContainer,
    mediumPriority: AppColors.priorityMedium,
    mediumPriorityContainer: AppColors.priorityMediumContainer,
    lowPriority: AppColors.priorityLow,
    lowPriorityContainer: AppColors.priorityLowContainer,
    categoryWork: AppColors.categoryWork,
    categoryPersonal: AppColors.categoryPersonal,
    categoryHealth: AppColors.categoryHealth,
    categoryStudy: AppColors.categoryStudy,
    categoryFinance: AppColors.categoryFinance,
    cardBorder: AppColors.lightCardBorder,
    surfaceSubtle: AppColors.lightSurfaceVariant,
    textTertiary: AppColors.lightTextTertiary,
  );

  static const TaskoraColorsExtension dark = TaskoraColorsExtension(
    urgentPriority: AppColors.priorityUrgent,
    urgentPriorityContainer: Color(0xFF4C0519), // Deep Rose
    highPriority: AppColors.priorityHigh,
    highPriorityContainer: Color(0xFF451A03), // Deep Amber
    mediumPriority: AppColors.priorityMedium,
    mediumPriorityContainer: Color(0xFF172554), // Deep Azure
    lowPriority: AppColors.priorityLow,
    lowPriorityContainer: Color(0xFF052E16), // Deep Mint
    categoryWork: AppColors.categoryWork,
    categoryPersonal: AppColors.categoryPersonal,
    categoryHealth: AppColors.categoryHealth,
    categoryStudy: AppColors.categoryStudy,
    categoryFinance: AppColors.categoryFinance,
    cardBorder: AppColors.darkCardBorder,
    surfaceSubtle: AppColors.darkSurfaceVariant,
    textTertiary: AppColors.darkTextTertiary,
  );

  @override
  TaskoraColorsExtension copyWith({
    Color? urgentPriority,
    Color? urgentPriorityContainer,
    Color? highPriority,
    Color? highPriorityContainer,
    Color? mediumPriority,
    Color? mediumPriorityContainer,
    Color? lowPriority,
    Color? lowPriorityContainer,
    Color? categoryWork,
    Color? categoryPersonal,
    Color? categoryHealth,
    Color? categoryStudy,
    Color? categoryFinance,
    Color? cardBorder,
    Color? surfaceSubtle,
    Color? textTertiary,
  }) {
    return TaskoraColorsExtension(
      urgentPriority: urgentPriority ?? this.urgentPriority,
      urgentPriorityContainer:
          urgentPriorityContainer ?? this.urgentPriorityContainer,
      highPriority: highPriority ?? this.highPriority,
      highPriorityContainer:
          highPriorityContainer ?? this.highPriorityContainer,
      mediumPriority: mediumPriority ?? this.mediumPriority,
      mediumPriorityContainer:
          mediumPriorityContainer ?? this.mediumPriorityContainer,
      lowPriority: lowPriority ?? this.lowPriority,
      lowPriorityContainer: lowPriorityContainer ?? this.lowPriorityContainer,
      categoryWork: categoryWork ?? this.categoryWork,
      categoryPersonal: categoryPersonal ?? this.categoryPersonal,
      categoryHealth: categoryHealth ?? this.categoryHealth,
      categoryStudy: categoryStudy ?? this.categoryStudy,
      categoryFinance: categoryFinance ?? this.categoryFinance,
      cardBorder: cardBorder ?? this.cardBorder,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      textTertiary: textTertiary ?? this.textTertiary,
    );
  }

  @override
  TaskoraColorsExtension lerp(
    ThemeExtension<TaskoraColorsExtension>? other,
    double t,
  ) {
    if (other is! TaskoraColorsExtension) return this;
    return TaskoraColorsExtension(
      urgentPriority: Color.lerp(urgentPriority, other.urgentPriority, t)!,
      urgentPriorityContainer:
          Color.lerp(
            urgentPriorityContainer,
            other.urgentPriorityContainer,
            t,
          )!,
      highPriority: Color.lerp(highPriority, other.highPriority, t)!,
      highPriorityContainer:
          Color.lerp(highPriorityContainer, other.highPriorityContainer, t)!,
      mediumPriority: Color.lerp(mediumPriority, other.mediumPriority, t)!,
      mediumPriorityContainer:
          Color.lerp(
            mediumPriorityContainer,
            other.mediumPriorityContainer,
            t,
          )!,
      lowPriority: Color.lerp(lowPriority, other.lowPriority, t)!,
      lowPriorityContainer:
          Color.lerp(lowPriorityContainer, other.lowPriorityContainer, t)!,
      categoryWork: Color.lerp(categoryWork, other.categoryWork, t)!,
      categoryPersonal:
          Color.lerp(categoryPersonal, other.categoryPersonal, t)!,
      categoryHealth: Color.lerp(categoryHealth, other.categoryHealth, t)!,
      categoryStudy: Color.lerp(categoryStudy, other.categoryStudy, t)!,
      categoryFinance: Color.lerp(categoryFinance, other.categoryFinance, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
    );
  }
}

/// Helper extension to easily access [TaskoraColorsExtension] from BuildContext.
extension TaskoraThemeX on BuildContext {
  TaskoraColorsExtension get taskoraColors =>
      Theme.of(this).extension<TaskoraColorsExtension>() ??
      TaskoraColorsExtension.light;
}

/// Complete Material 3 Theme Configuration for Taskora.
class AppTheme {
  AppTheme._();

  /// Default Light Theme
  static ThemeData get lightTheme =>
      getTheme(Brightness.light, AppThemePalette.neonLime);

  /// Default Dark Theme
  static ThemeData get darkTheme =>
      getTheme(Brightness.dark, AppThemePalette.neonLime);

  /// Generates dynamic Material 3 ThemeData customized to the user's chosen [palette].
  static ThemeData getTheme(
    Brightness brightness, [
    AppThemePalette palette = AppThemePalette.neonLime,
  ]) {
    final isDark = brightness == Brightness.dark;

    final primary = isDark ? palette.primaryLightColor : palette.primaryColor;
    final secondary = isDark ? palette.secondaryLightColor : palette.secondaryColor;
    final primaryContainer = isDark
        ? palette.primaryContainerDarkColor
        : palette.primaryContainerLightColor;
    final secondaryContainer = isDark
        ? palette.secondaryContainerDarkColor
        : palette.secondaryContainerLightColor;

    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceVariant =
        isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBorder =
        isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;
    final divider =
        isDark ? AppColors.darkDivider : AppColors.lightDivider;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: isDark ? palette.primaryLightColor : palette.primaryDarkColor,
      secondary: secondary,
      onSecondary: isDark ? const Color(0xFF090A10) : Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: isDark ? palette.secondaryLightColor : palette.secondaryColor,
      tertiary: AppColors.accentAmber,
      onTertiary: Colors.white,
      error: AppColors.priorityUrgent,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: textSecondary,
      outline: cardBorder,
      outlineVariant: divider,
    );

    final taskoraExtension = TaskoraColorsExtension(
      urgentPriority: AppColors.priorityUrgent,
      urgentPriorityContainer: isDark
          ? const Color(0xFF4C0519)
          : AppColors.priorityUrgentContainer,
      highPriority: AppColors.priorityHigh,
      highPriorityContainer: isDark
          ? const Color(0xFF451A03)
          : AppColors.priorityHighContainer,
      mediumPriority: AppColors.priorityMedium,
      mediumPriorityContainer: isDark
          ? const Color(0xFF172554)
          : AppColors.priorityMediumContainer,
      lowPriority: AppColors.priorityLow,
      lowPriorityContainer: isDark
          ? const Color(0xFF052E16)
          : AppColors.priorityLowContainer,
      categoryWork: palette.primaryColor,
      categoryPersonal: AppColors.categoryPersonal,
      categoryHealth: AppColors.categoryHealth,
      categoryStudy: AppColors.categoryStudy,
      categoryFinance: palette.secondaryColor,
      cardBorder: cardBorder,
      surfaceSubtle: surfaceVariant,
      textTertiary: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: AppTypography.textTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: cardBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        side: isDark
            ? BorderSide(color: cardBorder, width: 1.0)
            : BorderSide.none,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
          side: BorderSide(color: cardBorder, width: 1.0),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return IconThemeData(color: textSecondary, size: 24);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        selectedIconTheme: IconThemeData(color: primary, size: 24),
        unselectedIconTheme: IconThemeData(color: textSecondary, size: 24),
        selectedLabelTextStyle: TextStyle(
          color: primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 3,
        hoverElevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.priorityUrgent,
            width: 1,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        backgroundColor: isDark ? surfaceVariant : textPrimary,
        contentTextStyle: TextStyle(
          color: isDark ? textPrimary : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      extensions: [taskoraExtension],
    );
  }
}
