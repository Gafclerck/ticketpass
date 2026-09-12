/// Rôles utilisateur sur un événement — spec `docs/classe.md` (enum `Role`).
enum Role {
  organiser,
  participant,
  controller;

  /// Libellé affichable.
  String get label {
    switch (this) {
      case Role.organiser:
        return 'Organisateur';
      case Role.participant:
        return 'Participant';
      case Role.controller:
        return 'Contrôleur';
    }
  }
}