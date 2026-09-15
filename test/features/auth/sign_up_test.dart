import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:ticketpass/features/auth/domain/usecases/sign_up.dart';

void main() {
  group('SignUp (UC14)', () {
    test('crée un nouveau compte avec un mot de passe valide', () async {
      final repository = FakeAuthRepository.demo(latency: Duration.zero);
      final usecase = SignUp(repository);

      final user = await usecase.call(
        'bob@exemple.fr',
        'motdepasse',
        'Bob Dupont',
      );

      expect(user.email, 'bob@exemple.fr');
      expect(user.fullName, 'Bob Dupont');
    });

    test('rejette un mot de passe de moins de 6 caractères', () {
      final repository = FakeAuthRepository.demo(latency: Duration.zero);
      final usecase = SignUp(repository);

      expect(
        () => usecase.call('bob@exemple.fr', '123', 'Bob Dupont'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejette un email déjà utilisé', () {
      final repository = FakeAuthRepository.demo(latency: Duration.zero);
      final usecase = SignUp(repository);

      expect(
        () => usecase.call('alice@demo.com', 'motdepasse', 'Alice Bis'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
