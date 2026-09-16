import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketpass/features/auth/domain/entities/user.dart';
import 'package:ticketpass/features/auth/presentation/providers/auth_providers.dart';

/// Identité courante — source unique pour la présentation.
///
/// Dérivée de [authControllerProvider] (Firebase Auth). Le guard du routeur
/// garantit qu'aucun écran protégé n'est affiché sans utilisateur connecté ;
/// les pages posent une garde `null` (build) ou un early return (callback)
/// avant d'utiliser `user.id` (règle B2, fix final v1).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authControllerProvider);
});