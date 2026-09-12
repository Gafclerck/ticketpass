/// Types d'événement — spec `docs/classe.md` (enum `EventType`).
enum EventType {
  concert,
  festival,
  conference,
  exposition,
  theatre,
  sport,
  education,
  formation,
  other;

  /// Libellé affichable.
  String get label {
    switch (this) {
      case EventType.concert:
        return 'Concert';
      case EventType.festival:
        return 'Festival';
      case EventType.conference:
        return 'Conférence';
      case EventType.exposition:
        return 'Exposition';
      case EventType.theatre:
        return 'Théâtre';
      case EventType.sport:
        return 'Sport';
      case EventType.education:
        return 'Éducation';
      case EventType.formation:
        return 'Formation';
      case EventType.other:
        return 'Autre';
    }
  }
}