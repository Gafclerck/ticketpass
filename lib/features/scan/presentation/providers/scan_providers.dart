import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active la caméra du scanner de billets (UC10) — `true` en application.
///
/// Les tests widget surchargent ce provider à `false` pour rester en saisie
/// manuelle (un `MobileScanner` créerait une platform view non disponible en
/// environnement de test).
final scanUseCameraProvider = Provider<bool>((ref) => true);