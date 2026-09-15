import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ticketpass/features/auth/domain/entities/user.dart';
import 'package:ticketpass/features/auth/domain/repositories/auth_user_repository.dart';
import 'package:ticketpass/features/auth/domain/usecases/sign_in.dart';
import 'package:ticketpass/features/auth/domain/usecases/sign_out.dart';
import 'package:ticketpass/features/auth/domain/usecases/sign_up.dart';
import 'package:ticketpass/features/auth/domain/usecases/update_profile.dart';
import 'package:ticketpass/features/auth/domain/usecases/watch_auth_state.dart';

class _AuthUserRepositoryStub extends Mock implements AuthUserRepository {}

const _user = User(
  id: 'uid-1',
  email: 'alice@exemple.fr',
  fullName: 'Alice Martin',
);

void main() {
  group('SignIn — délègue au repository', () {
    test('appelle signInWithEmail avec email + mot de passe', () async {
      final repository = _AuthUserRepositoryStub();
      when(
        () => repository.signInWithEmail(
          email: 'alice@exemple.fr',
          password: 'secret',
        ),
      ).thenAnswer((_) async => _user);

      final user = await SignIn(repository).call(
        email: 'alice@exemple.fr',
        password: 'secret',
      );

      expect(user, _user);
      verify(
        () => repository.signInWithEmail(
          email: 'alice@exemple.fr',
          password: 'secret',
        ),
      ).called(1);
    });
  });

  group('SignUp — délègue au repository', () {
    test('appelle signUpWithEmail avec email, mdp et nom complet', () async {
      final repository = _AuthUserRepositoryStub();
      when(
        () => repository.signUpWithEmail(
          email: 'alice@exemple.fr',
          password: 'secret',
          fullName: 'Alice Martin',
        ),
      ).thenAnswer((_) async => _user);

      final user = await SignUp(repository).call(
        email: 'alice@exemple.fr',
        password: 'secret',
        fullName: 'Alice Martin',
      );

      expect(user, _user);
      verify(
        () => repository.signUpWithEmail(
          email: 'alice@exemple.fr',
          password: 'secret',
          fullName: 'Alice Martin',
        ),
      ).called(1);
    });
  });

  group('SignOut — délègue au repository', () {
    test('appelle signOut', () async {
      final repository = _AuthUserRepositoryStub();
      when(() => repository.signOut()).thenAnswer((_) async {});

      await SignOut(repository).call();

      verify(() => repository.signOut()).called(1);
    });
  });

  group('WatchAuthState — délègue au repository', () {
    test('retourne le flux d’authentification (null = déconnecté)', () async {
      final repository = _AuthUserRepositoryStub();
      final controller = StreamController<User?>();
      when(() => repository.authStateChanges()).thenAnswer((_) => controller.stream);

      final stream = WatchAuthState(repository).call();

      final matcher = expectLater(stream, emitsInOrder([null, _user]));
      controller.add(null);
      controller.add(_user);
      await controller.close();
      await matcher;
    });
  });

  group('UpdateProfile — délègue au repository', () {
    test('appelle updateProfile avec fullName et profileUrl', () async {
      final repository = _AuthUserRepositoryStub();
      when(
        () => repository.updateProfile(
          fullName: 'Alice M.',
          profileUrl: 'https://img/avatar.jpg',
        ),
      ).thenAnswer((_) async {});

      await UpdateProfile(repository).call(
        fullName: 'Alice M.',
        profileUrl: 'https://img/avatar.jpg',
      );

      verify(
        () => repository.updateProfile(
          fullName: 'Alice M.',
          profileUrl: 'https://img/avatar.jpg',
        ),
      ).called(1);
    });
  });
}