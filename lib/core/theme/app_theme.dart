import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Thème global de l'application — unique source de vérité visuelle.
///
/// C'est le SEUL endroit qui assemble les tokens du design system
/// (`app_colors`, `app_radius`, `app_spacing`, `app_typography`) en un
/// `ThemeData` conforme à la spec `FLUTTER_PROTOTYPE_SPEC.md`.
abstract class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.ui,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: _inputDecorationTheme,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.glassElevated,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: AppColors.glassSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
    );
  }

  /// Palette custom non générée par `ColorScheme.fromSeed` : la spec impose
  /// un bleu électrique unique + verre blanc translucide, PAS la dérive
  /// tonale M3. Les `surface` sont des dégradés de `#080808` (jinx full
  /// glass les backgrounds natifs Material).
  static const ColorScheme _colorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.textSecondary,
    onSecondary: AppColors.background,
    error: AppColors.error,
    onError: Colors.white,
    surface: Color(0xFF0F1218),
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: Color(0xFF1A1E26),
    outline: AppColors.glassBorder,
    outlineVariant: AppColors.glassSubtle,
  );

  /// Typo : Inter pour l'UI, Playfair Display pour les titres éditoriaux
  /// (headlines des événements).
  static TextTheme _buildTextTheme() {
    final base = GoogleFonts.interTextTheme();

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontFamily: AppTypography.display,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontFamily: AppTypography.display,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontFamily: AppTypography.display,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: AppColors.textPrimary),
      bodyMedium: base.bodyMedium?.copyWith(color: AppColors.textSecondary),
      bodySmall: base.bodySmall?.copyWith(color: AppColors.textMuted),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Champs de formulaire conformes spec §11 : hauteur 56, radius 20,
  /// fond white/10, bordure white/12, focus primary/50.
  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: _inputBorder,
        enabledBorder: _inputBorder,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.box)),
          borderSide: BorderSide(color: AppColors.primaryBorder, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      );

  static const OutlineInputBorder _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadius.box)),
    borderSide: BorderSide(color: AppColors.glassBorder),
  );

  /// Padding standard des pages : h:20 + clearance bas (spec §9).
  static EdgeInsets pagePadding({double bottom = AppSpacing.lg}) {
    return EdgeInsets.fromLTRB(
      AppSpacing.pageHorizontal,
      AppSpacing.pageTop,
      AppSpacing.pageHorizontal,
      bottom,
    );
  }
}