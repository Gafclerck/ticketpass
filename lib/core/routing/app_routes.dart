abstract class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String tickets = '/tickets';
  static const String wallet = '/wallet';
  static const String profile = '/profile';

  static const String ticketDetail = '/ticket/';

  // Pages plein-écran (hors nav) — routes racine + AppShell obligatoires
  static const String eventCreate = '/event/create';
  static const String eventEdit = '/event/edit';
}
