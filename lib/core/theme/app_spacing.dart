/// Tokens d'espacement du Design System — spec `FLUTTER_PROTOTYPE_SPEC.md` §9.
abstract class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  // Constraints globaux (spec §9)
  static const double pageHorizontal = lg; // px-5 = 20
  static const double pageTop = xxxl + xs; // pt-12 = 48
  static const double bottomClearanceWithNav = navBarClearance + lg; // pb-28
  static const double bottomClearanceNoNav = xxxl; // pb-10 = 40

  // Barre de navigation flottante (router + clearance des pages onglets)
  static const double navBarHeight = 76;
  static const double navBarBottomOffset = 16;
  static const double navBarClearance = navBarHeight + navBarBottomOffset; // 92

  // Gaps entre colonnes d'une même carte (gap-4)
  static const double cardGap = md;
  // Gaps entre petits items (gap-3)
  static const double itemGap = sm;
  // Gaps entre sections (gap-5)
  static const double sectionGap = lg;
}