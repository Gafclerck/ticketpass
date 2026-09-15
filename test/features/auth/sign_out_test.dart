import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:ticketpass/features/auth/domain/usecases/sign_in.dart';
import 'package:ticketpass/features/auth/domain/usecases/sign_out.dart';

void main() {
  group('SignOut (UC14)', () {
    test('authStateChanges émet null après déconnexion', () async {
      final repository = FakeAuthRepository.demo(latency: Duration.zero);
      final signIn = SignIn(repository);
      final signOut = SignOut(repository);

      await signIn.call('alice@demo.com', 'demo');
      await signOut.call();

      final currentState = await repository.authStateChanges.first;
      expect(currentState, isNull);
    });
  });
}
