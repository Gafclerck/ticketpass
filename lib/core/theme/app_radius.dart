/// Tokens de rayon — spec `FLUTTER_PROTOTYPE_SPEC.md` §9 "Border-radius reference".
abstract class AppRadius {
  AppRadius._();

  /// EventCard, TicketCard, GlassCard, QR card.
  static const double card = 28;

  /// Hero image, grand QR card.
  static const double large = 32;

  /// Inputs, textarea, metadata chips, stat cards, info boxes.
  static const double box = 20;

  /// Conteneur de la BottomNav.
  static const double nav = 38;

  /// Pastilles, mini-thumbnails, logo.
  static const double small = 14;

  /// Boutons primaires/secondaires (28), formes pleines.
  static const double button = 28;

  /// Coin supérieur de la modal scanner (32).
  static const double modalTop = 32;

  /// Placidité totale (pills, cercles).
  static const double pill = 999;
}