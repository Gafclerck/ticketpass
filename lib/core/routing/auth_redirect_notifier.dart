import 'package:flutter/foundation.dart';
import '../../features/auth/domain/entities/user.dart';

/// Pont entre `authStateChangesProvider` et `GoRouter.refreshListenable`.
///
/// Ne s'abonne PAS elle-même à Firebase : `update()` est appelée par
/// `ref.listen(authStateChangesProvider, ...)` dans `app_router.dart`, pour
/// que la garde de route et `currentUserProvider` observent exactement le
/// même flux (une seule souscription) au lieu de deux souscriptions
/// indépendantes qui pouvaient se désynchroniser (bug déjà rencontré).
class AuthRedirectNotifier extends ChangeNotifier {
  User? _currentUser;
  bool _isReady = false;

  User? get currentUser => _currentUser;
  bool get isReady => _isReady;

  void update(User? user) {
    _currentUser = user;
    _isReady = true;
    notifyListeners();
  }
}
