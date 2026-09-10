/// Statut d'un billet — spec `docs/classe.md`.
///
/// L'enum Mermaid liste `VALID / USED / INVALID / UNUSED`. La section
/// "Règles métier des tickets" du même fichier définit en plus `REVOKED`
/// (billet invalidé par l'organisateur) : il est donc conservé ici.
enum TicketStatus {
  unused,
  valid,
  used,
  invalid,
  revoked;

  /// Libellé affichable.
  String get label {
    switch (this) {
      case TicketStatus.unused:
        return 'Non attribué';
      case TicketStatus.valid:
        return 'Valide';
      case TicketStatus.used:
        return 'Utilisé';
      case TicketStatus.invalid:
        return 'Invalide';
      case TicketStatus.revoked:
        return 'Révoqué';
    }
  }
}