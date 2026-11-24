import 'package:flutter/material.dart';

/// Device screen categories following modern adaptive guidelines.
enum DeviceScreenType {
  /// < 360dp width (compact phones, SE-sized devices, foldable cover screens)
  compact,

  /// 360dp - 599dp width (standard modern smartphones)
  medium,

  /// 600dp - 839dp width (tablets, foldables unfolded, small landscape)
  expanded,

  /// >= 840dp width (large tablets, desktop, wide monitors)
  large,
}

/// Adaptive breakpoints and spacing system for Taskora.
class AppBreakpoints {
  AppBreakpoints._();

  static const double compactMaxWidth = 359.0;
  static const double mediumMaxWidth = 599.0;
  static const double expandedMaxWidth = 839.0;

  /// Returns the current [DeviceScreenType] given the screen width in dp.
  static DeviceScreenType getScreenType(double width) {
    if (width < 360) {
      return DeviceScreenType.compact;
    } else if (width < 600) {
      return DeviceScreenType.medium;
    } else if (width < 840) {
      return DeviceScreenType.expanded;
    } else {
      return DeviceScreenType.large;
    }
  }

  /// Adaptive horizontal content padding based on screen size.
  static double horizontalPadding(DeviceScreenType type) {
    switch (type) {
      case DeviceScreenType.compact:
        return 12.0;
      case DeviceScreenType.medium:
        return 16.0;
      case DeviceScreenType.expanded:
        return 24.0;
      case DeviceScreenType.large:
        return 32.0;
    }
  }

  /// Adaptive gutter spacing between cards/grid items.
  static double gutterSpacing(DeviceScreenType type) {
    switch (type) {
      case DeviceScreenType.compact:
        return 8.0;
      case DeviceScreenType.medium:
        return 12.0;
      case DeviceScreenType.expanded:
        return 16.0;
      case DeviceScreenType.large:
        return 20.0;
    }
  }

  /// Adaptive card border radius.
  static double cardRadius(DeviceScreenType type) {
    switch (type) {
      case DeviceScreenType.compact:
        return 12.0;
      case DeviceScreenType.medium:
      case DeviceScreenType.expanded:
      case DeviceScreenType.large:
        return 16.0;
    }
  }
}

/// Context extensions for clean and expressive responsive querying.
extension ResponsiveContextX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  Orientation get orientation => MediaQuery.orientationOf(this);
  bool get isLandscape => orientation == Orientation.landscape;

  DeviceScreenType get screenType => AppBreakpoints.getScreenType(screenWidth);

  bool get isCompact => screenType == DeviceScreenType.compact;
  bool get isMedium => screenType == DeviceScreenType.medium;
  bool get isExpanded => screenType == DeviceScreenType.expanded;
  bool get isLarge => screenType == DeviceScreenType.large;

  /// True if device has tablet, foldable unfolded, or desktop viewport dimensions.
  bool get isTabletOrDesktop =>
      screenType == DeviceScreenType.expanded ||
      screenType == DeviceScreenType.large;

  /// Adaptive horizontal padding for current screen.
  double get responsiveHorizontalPadding =>
      AppBreakpoints.horizontalPadding(screenType);

  /// Adaptive gutter spacing for current screen.
  double get responsiveGutter => AppBreakpoints.gutterSpacing(screenType);

  /// Safe keyboard insets detection.
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0.0;
  double get keyboardHeight => MediaQuery.viewInsetsOf(this).bottom;

  /// Calculates responsive grid column count based on available width.
  int responsiveGridColumns({
    int compact = 1,
    int medium = 1,
    int expanded = 2,
    int large = 3,
  }) {
    switch (screenType) {
      case DeviceScreenType.compact:
        return compact;
      case DeviceScreenType.medium:
        return medium;
      case DeviceScreenType.expanded:
        return expanded;
      case DeviceScreenType.large:
        return large;
    }
  }
}
