import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Signe et vérifie l'authenticité des billets (UC5), sans dépendre du
/// réseau — utilisé par `ticket/` pour signer (UC5) et par `scan/` pour
/// vérifier hors-ligne (UC10-UC12).
abstract final class TicketSignatureService {
  // TODO prod : sortir cette clé du code source (config sécurisée côté serveur/CI).
  static const _secretKey = 'ticketpass-dev-secret-key-change-me';

  static String sign(String ticketId, String eventId) {
    final key = utf8.encode(_secretKey);
    final message = utf8.encode('$ticketId:$eventId');
    final digest = Hmac(sha256, key).convert(message);
    return digest.toString();
  }

  static bool verify(String ticketId, String eventId, String signature) {
    return sign(ticketId, eventId) == signature;
  }

  static String buildQrPayload(String ticketId, String eventId) {
    return '$ticketId|${eventId}|${sign(ticketId, eventId)}';
  }

  static bool verifyQrPayload(String payload) {
    final parts = payload.split('|');
    if (parts.length != 3) return false;

    final ticketId = parts[0];
    final eventId = parts[1];
    final signature = parts[2];
    return verify(ticketId, eventId, signature);
  }
}
