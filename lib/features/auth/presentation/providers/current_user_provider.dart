import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketpass/features/auth/domain/entities/user.dart';

/// Utilisateur courant (démo) — remplacé par l'authentification (Firebase
/// Auth) au sprint d'infrastructure. Seul point de bascule de la présentation.
final currentUserProvider = Provider<User>((ref) {
  return const User(
    id: 'demo-user-id',
    email: 'alice@exemple.fr',
    password: '',
    fullName: 'Alice Martin',
    profileUrl: '',
    authId: 'demo-auth-id',
  );
});