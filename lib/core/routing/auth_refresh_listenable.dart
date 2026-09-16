import 'package:flutter/foundation.dart';

/// Notifie le `GoRouter` qu'une bascule d'authentification vient de se
/// produire, pour re-évaluer les redirects.
///
/// Source de vérité = `authControllerProvider` ; ce listenable ne porte qu'un
/// état de routage (connecté / déconnecté + destination initiale en attente).
class AuthRefreshListenable extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _pendingLocation;

  bool get isAuthenticated => _isAuthenticated;

  /// Dernier écran protégé demandé avant connexion (retour après login).
  String? get pendingLocation => _pendingLocation;

  void notify({required bool isAuthenticated}) {
    _isAuthenticated = isAuthenticated;
    notifyListeners();
  }

  /// Mémorise l'écran protégé visé pour y revenir après authentification.
  void rememberPending(String location) {
    _pendingLocation = location;
  }

  /// Consomme (et efface) la destination initiale en attente.
  String? consumePending() {
    final pending = _pendingLocation;
    _pendingLocation = null;
    return pending;
  }

  /// Réinitialise l'état de routage (utilisé par les tests).
  void reset() {
    _isAuthenticated = false;
    _pendingLocation = null;
    notifyListeners();
  }
}

/// Instance unique partagée entre le [AuthController] (Riverpod) et le
/// `GoRouter` pour re-évaluer les redirects d'authentification.
final authRefreshListenable = AuthRefreshListenable();