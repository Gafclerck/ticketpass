import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Identité de l'utilisateur courant.
///
/// Point de bascule (seam) : tant que l'authentification (UC14) n'est pas
/// implémentée, cette valeur est un faux utilisateur fixe. Dès que Firebase
/// Auth sera branché, seul CE provider sera modifié — aucune couche
/// (présentation, use cases, domain) ne devra changer.
final currentUserIdProvider = Provider<String>((ref) {
  return 'demo-user-id';
});