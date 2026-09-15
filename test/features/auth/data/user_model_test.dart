import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/auth/data/models/user_model.dart';
import 'package:ticketpass/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    test('fromJson - lit les clés snake_case du doc Firestore', () {
      final model = UserModel.fromJson(const {
        'uid': 'uid-1',
        'email': 'alice@exemple.fr',
        'full_name': 'Alice Martin',
        'profile_url': 'https://cdn/p.jpg',
      });

      expect(model.id, 'uid-1');
      expect(model.email, 'alice@exemple.fr');
      expect(model.fullName, 'Alice Martin');
      expect(model.profileUrl, 'https://cdn/p.jpg');
    });

    test('toJson - écrit full_name et profile_url en snake_case', () {
      final json = const UserModel(
        id: 'uid-1',
        email: 'alice@exemple.fr',
        fullName: 'Alice Martin',
        profileUrl: null,
      ).toJson();

      expect(json['uid'], 'uid-1');
      expect(json['full_name'], 'Alice Martin');
      expect(json['profile_url'], isNull);
      expect(json.containsKey('password'), isFalse);
    });

    test('round-trip toEntity/fromEntity', () {
      const user = User(
        id: 'uid-1',
        email: 'alice@exemple.fr',
        fullName: 'Alice Martin',
        profileUrl: 'https://cdn/p.jpg',
      );

      final model = UserModel.fromEntity(user);
      expect(model.id, user.id);
      expect(model.email, user.email);
      expect(model.fullName, user.fullName);
      expect(model.profileUrl, user.profileUrl);

      final restored = model.toEntity();
      expect(restored.id, user.id);
      expect(restored.email, user.email);
      expect(restored.fullName, user.fullName);
      expect(restored.profileUrl, user.profileUrl);
    });

    test('fromJson - profile_url absent => null', () {
      final model = UserModel.fromJson(const {
        'uid': 'uid-2',
        'email': 'bob@exemple.fr',
        'full_name': 'Bob',
      });

      expect(model.profileUrl, isNull);
    });
  });
}