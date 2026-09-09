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

  // Fond "glass" des cartes/boutons (blanc à 6% d'opacité)
  static const Color glassSurface = Color(0x0FFFFFFF);

  // Bordure des cartes/boutons "glass" (blanc à 10% d'opacité)
  static const Color glassBorder = Color(0x1AFFFFFF);

  // Fond de la navbar flottante, plus opaque que les cartes (blanc à 12%)
  static const Color navBarBackground = Color(0x1FFFFFFF);

  // Bordure de la navbar (blanc à 14%)
  static const Color navBarBorder = Color(0x24FFFFFF);

  // Cercle plein derrière l'icône active dans la navbar = même bleu que primary
  static const Color navBarSelectedBg = primary;

  // Fond du cercle avatar sur la page profil (bleu primary à 30% d'opacité)
  static const Color avatarBackground = Color(0x4D148CFA);
}
