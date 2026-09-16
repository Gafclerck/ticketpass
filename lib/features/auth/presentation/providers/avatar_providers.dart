import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_providers.dart';

/// Sélecteur d'image (galerie) — provider pour pouvoir être mocké en test.
final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

/// Sélectionne une image (galerie) puis l'uploade sur Storage.
///
/// Retourne l'URL de téléchargement à persister dans Firestore, ou `null` si
/// l'utilisateur annule la sélection.
Future<String?> pickAndUploadAvatar(WidgetRef ref, {required String userId}) async {
  final file = await ref.read(imagePickerProvider).pickImage(
    source: ImageSource.gallery,
    maxWidth: 1024,
    maxHeight: 1024,
    imageQuality: 85,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  return ref
      .read(profileImageDatasourceProvider)
      .uploadProfileImage(userId: userId, bytes: bytes);
}