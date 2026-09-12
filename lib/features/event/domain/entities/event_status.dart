/// Statut d'un événement — spec `docs/classe.md` (enum `EventStatus`).
enum EventStatus {
  upcoming,
  ongoing,
  passed;

  /// Libellé affichable.
  String get label {
    switch (this) {
      case EventStatus.upcoming:
        return 'À venir';
      case EventStatus.ongoing:
        return 'En cours';
      case EventStatus.passed:
        return 'Terminé';
    }
  }
}