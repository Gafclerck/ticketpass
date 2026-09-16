import '../repositories/auth_user_repository.dart';

/// UC — mise à jour du profil (nom complet et/ou URL d'avatar).
class UpdateProfile {
  final AuthUserRepository repository;

  UpdateProfile(this.repository);

  Future<void> call({String? fullName, String? profileUrl}) =>
      repository.updateProfile(fullName: fullName, profileUrl: profileUrl);
}