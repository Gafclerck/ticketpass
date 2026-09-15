import 'dart:async';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implémentation fake (en mémoire) du dépôt d'auth — même esprit que
/// `FakeTicketRepository` : sert à la fois de dev-implémentation et de
/// double de test, pas un stub qui court-circuite les règles métier.
class FakeAuthRepository implements AuthRepository {
  final Map<String, _Account> _accounts;
  final Duration latency;
  final StreamController<User?> _authStateController;
  User? _currentUser;

  FakeAuthRepository({this.latency = const Duration(milliseconds: 200)})
      : _accounts = {},
        _authStateController = StreamController<User?>.broadcast();

  /// Un compte de démo déjà enregistré (alice@demo.com / demo), cohérent
  /// avec le bandeau affiché sur `LoginPage`.
  factory FakeAuthRepository.demo({
    Duration latency = const Duration(milliseconds: 200),
  }) {
    final repository = FakeAuthRepository(latency: latency);
    const demoUser = User(
      id: 'demo-user-id',
      email: 'alice@demo.com',
      password: 'demo',
      fullName: 'Alice Martin',
      profileUrl: '',
      authId: 'demo-auth-id',
    );
    repository._accounts['alice@demo.com'] = const _Account(
      password: 'demo',
      user: demoUser,
    );
    return repository;
  }

  Future<void> _simulateLatency() async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
  }

  @override
  Future<User> signIn(String email, String password) async {
    await _simulateLatency();

    final account = _accounts[email];
    if (account == null || account.password != password) {
      throw Exception('Email ou mot de passe incorrect.');
    }

    _currentUser = account.user;
    _authStateController.add(_currentUser);
    return account.user;
  }

  @override
  Future<User> signUp(String email, String password, String fullName) async {
    await _simulateLatency();

    if (_accounts.containsKey(email)) {
      throw Exception('Un compte existe déjà avec cet email.');
    }

    final user = User(
      id: 'user-${_accounts.length + 1}',
      email: email,
      password: password,
      fullName: fullName,
      profileUrl: '',
      authId: 'auth-${_accounts.length + 1}',
    );
    _accounts[email] = _Account(password: password, user: user);
    _currentUser = user;
    _authStateController.add(_currentUser);
    return user;
  }

  @override
  Future<void> signOut() async {
    await _simulateLatency();
    _currentUser = null;
    _authStateController.add(null);
  }

  /// Émet l'état courant à chaque nouvel abonné, puis les changements
  /// suivants — comme `FirebaseAuth.authStateChanges()`. Un simple
  /// `StreamController.broadcast` ne le ferait pas : un abonné arrivant
  /// après un `add()` raterait cette valeur.
  @override
  Stream<User?> get authStateChanges async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }
}

class _Account {
  final String password;
  final User user;

  const _Account({required this.password, required this.user});
}
