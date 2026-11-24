import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskora/core/theme/app_theme.dart';
import 'package:taskora/core/theme/theme_provider.dart';

void main() {
  group('AppThemePalette Tests', () {
    test('contains exactly 14 modern palettes', () {
      expect(AppThemePalette.values.length, equals(14));
    });

    test('all 14 palettes have distinct display names and subtitles', () {
      final names = <String>{};
      final subtitles = <String>{};

      for (final palette in AppThemePalette.values) {
        expect(palette.displayName.isNotEmpty, isTrue);
        expect(palette.subtitle.isNotEmpty, isTrue);
        expect(names.add(palette.displayName), isTrue,
            reason: 'Duplicate displayName: ${palette.displayName}');
        expect(subtitles.add(palette.subtitle), isTrue,
            reason: 'Duplicate subtitle: ${palette.subtitle}');
      }
    });

    test('all palettes define valid colors and gradients', () {
      for (final palette in AppThemePalette.values) {
        expect(palette.primaryColor, isA<Color>());
        expect(palette.primaryLightColor, isA<Color>());
        expect(palette.primaryDarkColor, isA<Color>());
        expect(palette.secondaryColor, isA<Color>());
        expect(palette.gradient.colors.length, greaterThanOrEqualTo(2));
      }
    });

    test('fromString parses all 14 palettes and defaults cleanly', () {
      for (final palette in AppThemePalette.values) {
        expect(AppThemePalette.fromString(palette.name), equals(palette));
      }
      expect(AppThemePalette.fromString(null), equals(AppThemePalette.neonLime));
      expect(AppThemePalette.fromString('unknown_palette'),
          equals(AppThemePalette.neonLime));
    });

    test('AppTheme.getTheme builds both light and dark themes for all 14 palettes', () {
      for (final palette in AppThemePalette.values) {
        final light = AppTheme.getTheme(Brightness.light, palette);
        final dark = AppTheme.getTheme(Brightness.dark, palette);

        expect(light.brightness, equals(Brightness.light));
        expect(dark.brightness, equals(Brightness.dark));
        expect(light.colorScheme.primary, isNotNull);
        expect(dark.colorScheme.primary, isNotNull);
      }
    });
  });
}
