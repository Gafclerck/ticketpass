import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/auth/data/repositories/auth_error_mapper.dart';
import 'package:ticketpass/features/auth/domain/errors/auth_exception.dart';

void main() {
  AuthException map(String code, [String? message]) =>
      mapAuthError(FirebaseAuthException(code: code, message: message));

  group('mapAuthError', () {
    test('wrong-password / invalid-credential => identifiants incorrects', () {
      expect(map('wrong-password').message, 'Identifiants incorrects.');
      expect(map('invalid-credential').message, 'Identifiants incorrects.');
    });

    test('user-not-found => aucun compte associé', () {
      expect(map('user-not-found').message, 'Aucun compte associé à cet email.');
    });

    test('invalid-email => adresse invalide', () {
      expect(map('invalid-email').message, 'Adresse email invalide.');
    });

    test('email-already-in-use => compte existant', () {
      expect(map('email-already-in-use').message, 'Un compte existe déjà avec cet email.');
    });

    test('weak-password => 6 caractères minimum', () {
      expect(map('weak-password').message, 'Mot de passe trop faible (6 caractères minimum).');
    });

    test('too-many-requests => réessayer plus tard', () {
      expect(map('too-many-requests').message, 'Trop de tentatives. Réessayez plus tard.');
    });

    test('network-request-failed => vérifier le réseau', () {
      expect(map('network-request-failed').message, 'Problème de connexion. Vérifiez votre réseau.');
    });

    test('operation-not-allowed => connexion désactivée', () {
      expect(map('operation-not-allowed').message, 'La connexion par email/mot de passe est désactivée.');
    });

    test('code inconnu => message fourni par Firebase', () {
      expect(map('unknown-code', 'Erreur XYZ').message, 'Erreur XYZ');
    });

    test('code inconnu sans message => générique', () {
      expect(map('unknown-code').message, 'Connexion impossible.');
    });

    test('erreur non-Firebase => message générique', () {
      expect(mapAuthError(Exception('boom')).message, 'Une erreur est survenue. Réessayez.');
    });
  });
}