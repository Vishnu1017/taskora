import 'package:flutter/material.dart';
import 'app_breakpoints.dart';

/// Context-aware data packet provided to responsive child builders.
class ResponsiveInfo {
  final DeviceScreenType screenType;
  final double screenWidth;
  final double screenHeight;
  final Orientation orientation;
  final bool isKeyboardVisible;
  final double keyboardHeight;
  final TextScaler textScaler;
  final double horizontalPadding;
  final double gutterSpacing;

  const ResponsiveInfo({
    required this.screenType,
    required this.screenWidth,
    required this.screenHeight,
    required this.orientation,
    required this.isKeyboardVisible,
    required this.keyboardHeight,
    required this.textScaler,
    required this.horizontalPadding,
    required this.gutterSpacing,
  });

  bool get isCompact => screenType == DeviceScreenType.compact;
  bool get isMedium => screenType == DeviceScreenType.medium;
  bool get isExpanded => screenType == DeviceScreenType.expanded;
  bool get isLarge => screenType == DeviceScreenType.large;
  bool get isTabletOrDesktop => isExpanded || isLarge;
}

/// A robust responsive builder widget that adapts layouts across form factors.
class ResponsiveLayoutBuilder extends StatelessWidget {
  /// Generic builder providing full [ResponsiveInfo].
  final Widget Function(BuildContext context, ResponsiveInfo info)? builder;

  /// Optional specific layout builders with automatic fallbacks.
  final WidgetBuilder? compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;
  final WidgetBuilder? large;

  const ResponsiveLayoutBuilder({
    super.key,
    this.builder,
    this.compact,
    this.medium,
    this.expanded,
    this.large,
  }) : assert(
         builder != null ||
             compact != null ||
             medium != null ||
             expanded != null ||
             large != null,
         'At least one builder must be provided to ResponsiveLayoutBuilder',
       );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        final width = constraints.maxWidth;
        final screenType = AppBreakpoints.getScreenType(width);

        if (builder != null) {
          final info = ResponsiveInfo(
            screenType: screenType,
            screenWidth: width,
            screenHeight: constraints.maxHeight,
            orientation: mediaQuery.orientation,
            isKeyboardVisible: mediaQuery.viewInsets.bottom > 0,
            keyboardHeight: mediaQuery.viewInsets.bottom,
            textScaler: mediaQuery.textScaler,
            horizontalPadding: AppBreakpoints.horizontalPadding(screenType),
            gutterSpacing: AppBreakpoints.gutterSpacing(screenType),
          );
          return builder!(context, info);
        }

        switch (screenType) {
          case DeviceScreenType.compact:
            return (compact ?? medium ?? expanded ?? large)!(context);
          case DeviceScreenType.medium:
            return (medium ?? compact ?? expanded ?? large)!(context);
          case DeviceScreenType.expanded:
            return (expanded ?? large ?? medium ?? compact)!(context);
          case DeviceScreenType.large:
            return (large ?? expanded ?? medium ?? compact)!(context);
        }
      },
    );
  }
}
