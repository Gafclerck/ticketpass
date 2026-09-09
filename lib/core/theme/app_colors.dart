import 'package:flutter/material.dart';

abstract class AppColors {
  // notre classe ne contenant que les constantes et ne voulant pas avoir la possibilite de faire un AppColors(), on rends le constructeur privé

  AppColors._();

  // Fond global de l'app (thème sombre)
  static const Color background = Color(0xFF080808);

  // Bleu d'accent : sélection (navbar, stats), liens, boutons primaires
  static const Color primary = Color(0xFF148CFA);

  // Texte principal : titres, contenu important (ex: "Profil", "Alice Martin")
  static const Color textPrimary = Color(0xFFF5F7FA);

  // Texte secondaire : sous-titres, infos moins importantes (ex: email)
  static const Color textSecondary = Color(0xFFA7ABB3);

  // Texte discret : petits labels sous les stats (ex: "Événements", "Billets")
  static const Color textMuted = Color(0xFF6F737C);

  // Fond "glass" des cartes/boutons (blanc à 6-10% d'opacité)
  static const Color glassSurface = Color(0x0FFFFFFF);
  static const Color glassSubtle = Color(0x0FFFFFFF);

  // Bordure des cartes/boutons "glass" (blanc à 10% d'opacité)
  static const Color glassBorder = Color(0x1AFFFFFF);

  // Niveaux glass standard / elevated (spec §9 "Glass layer reference")
  static const Color glassStandard = Color(0x1FFFFFFF); // white 12%
  static const Color glassElevated = Color(0x24FFFFFF); // white 14%

  // Bordures glass standard / elevated
  static const Color borderStandard = Color(0x24FFFFFF); // white 14%
  static const Color borderElevated = Color(0x29FFFFFF); // white 16%

  // Fond de la navbar flottante (white 12%) — conservé pour compatibilité
  static const Color navBarBackground = glassStandard;

  // Bordure de la navbar (white 14%)
  static const Color navBarBorder = borderStandard;

  // Cercle plein derrière l'icône active dans la navbar = même bleu que primary
  static const Color navBarSelectedBg = primary;

  // Fond du cercle avatar sur la page profil (bleu primary à 30% d'opacité)
  static const Color avatarBackground = Color(0x4D148CFA);

  // États du bleu accent (spec §14)
  static const Color primaryHovered = Color(0xFF2A98FB);
  static const Color primaryPressed = Color(0xFF0E79DC);
  static const Color primaryBorder = Color(0x80148CFA); // primary à 50% (focus)

  // Couleurs de statut (spec §5.9 Badge)
  static const Color success = Color(0xFF22C55E);
  static const Color successText = Color(0xFF4ADE80);
  static const Color successBorder = Color(0x4D22C55E); // success à 30%
  static const Color error = Color(0xFFEF4444);
  static const Color errorText = Color(0xFFF87171);
  static const Color errorBorder = Color(0x4DEF4444);

  // Overlays sombres (barres, modales, sheets)
  static const Color overlayDark = Color(0xD1080808); // ~82%
  static const Color overlayStrong = Color(0xEB080808); // ~92%
}
