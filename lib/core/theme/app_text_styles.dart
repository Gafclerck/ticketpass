import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  AppTextStyles._();

  // Titres de page (ex: "Profil", "Événements")
  static final TextStyle heading1 = GoogleFonts.inter(
    fontWeight: FontWeight.bold,
    fontSize: 28,
    height: 42 / 28,
    letterSpacing: -0.56,
    color: AppColors.textPrimary,
  );

  // Sous-titres importants (ex: "Alice Martin")
  static final TextStyle heading2 = GoogleFonts.inter(
    fontWeight: FontWeight.bold,
    fontSize: 22,
    height: 33 / 22,
    color: AppColors.textPrimary,
  );

  // Texte de boutons/labels (ex: "Mes billets")
  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    height: 22.5 / 15,
    color: AppColors.textPrimary,
  );

  // Boutons proéminents (ex: "Se déconnecter")
  static final TextStyle bodySemiBold = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 22.5 / 15,
    color: AppColors.textPrimary,
  );

  // Texte secondaire (ex: email)
  static final TextStyle caption = GoogleFonts.inter(
    fontWeight: FontWeight.normal,
    fontSize: 14,
    height: 21 / 14,
    color: AppColors.textSecondary,
  );

  // Petits labels (ex: "Événements" sous les stats)
  static final TextStyle labelSmall = GoogleFonts.inter(
    fontWeight: FontWeight.normal,
    fontSize: 12,
    height: 18 / 12,
    color: AppColors.textMuted,
  );
}
