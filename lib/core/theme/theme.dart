import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

export 'app_colors.dart';
export 'app_text_styles.dart';
export 'pixel_decorations.dart';

/// Tema global Loot Zero — estética 16-bit RPG/aventura (original).
abstract class LootZeroTheme {
  static ThemeData get main => _build();

  static ThemeData _build() {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.skyBlue,
      splashColor: Colors.transparent,
      highlightColor: AppColors.goldCoin.withOpacity(0.2),

      colorScheme: const ColorScheme.light(
        primary: AppColors.emerald,
        secondary: AppColors.goldCoin,
        error: AppColors.rubyRed,
        surface: AppColors.parchment,
        onPrimary: AppColors.cloudWhite,
        onSurface: AppColors.ink,
      ),

      textTheme: TextTheme(
        displayLarge: AppTextStyles.hudTitle,
        titleMedium: AppTextStyles.cardTitle,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.caption,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.emerald,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTextStyles.cardTitle.copyWith(color: AppColors.cloudWhite),
        iconTheme: const IconThemeData(color: AppColors.cloudWhite),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: AppColors.emerald,
          elevation: 0,
        ),
      ),
    );
  }
}
