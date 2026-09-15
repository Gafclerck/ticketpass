import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:ticketpass/features/auth/domain/usecases/sign_in.dart';

void main() {
  group('SignIn (UC14)', () {
    test('connecte avec les bons identifiants', () async {
      final repository = FakeAuthRepository.demo(latency: Duration.zero);
      final usecase = SignIn(repository);

      final user = await usecase.call('alice@demo.com', 'demo');

      expect(user.email, 'alice@demo.com');
      expect(user.fullName, 'Alice Martin');
    });

    test('rejette un mot de passe incorrect', () {
      final repository = FakeAuthRepository.demo(latency: Duration.zero);
      final usecase = SignIn(repository);

      expect(
        () => usecase.call('alice@demo.com', 'mauvais-mot-de-passe'),
        throwsA(isA<Exception>()),
      );
    });

    test('rejette un email inconnu', () {
      final repository = FakeAuthRepository.demo(latency: Duration.zero);
      final usecase = SignIn(repository);

      expect(
        () => usecase.call('inconnu@exemple.fr', 'demo'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
