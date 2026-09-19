import 'package:flutter/material.dart';

/// Deltaic palette — see design-reference/ for approved screens.
abstract class AppColors {
  static const teal = Color(0xFF0F6E6E);
  static const terracotta = Color(0xFFC4623C);
  static const mustard = Color(0xFFE0A62C);
  static const offWhite = Color(0xFFFAF6F0);
  static const charcoal = Color(0xFF2B2B2B);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: Brightness.light,
      primary: AppColors.teal,
      secondary: AppColors.terracotta,
      tertiary: AppColors.mustard,
      surface: AppColors.offWhite,
    );

    const pillShape = StadiumBorder();
    const minSize = Size(64, 48);

    final textTheme = const TextTheme(
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      titleMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 16),
    ).apply(
      bodyColor: AppColors.charcoal,
      displayColor: AppColors.charcoal,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.offWhite,
      textTheme: textTheme,
      fontFamily: 'system-ui',
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: pillShape, minimumSize: minSize),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: pillShape, minimumSize: minSize),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: pillShape, minimumSize: minSize),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: pillShape, minimumSize: minSize),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.teal,
        linearMinHeight: 8,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.offWhite,
        indicatorShape: const StadiumBorder(),
        indicatorColor: AppColors.teal.withValues(alpha: 0.16),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
