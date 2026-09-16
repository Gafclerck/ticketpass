import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/ticket_status.dart';
import '../models/ticket_model.dart';

/// Exception levée quand la précondition (CAS) d'une opération billet échoue
/// : l'état distant ne permet pas la transition demandée. C'est la signature
/// d'un conflit multi-appareils — à traiter en `cancelled` + pull par le sync.
class TicketStateConflictException implements Exception {
  final String message;

  const TicketStateConflictException(this.message);

  @override
  String toString() => 'TicketStateConflictException: $message';
}

/// Contrat de la source distante (Firestore) des billets.
///
/// Écritures idempotentes : un rejeu applique le même état final (`set`) ou
/// est détecté comme déjà appliqué (rejeu d'un `claim` du même acheteur, d'une
/// validation déjà `used`) et renvoyé en succès.
abstract class TicketRemoteDataSource {
  /// Crée les N billets d'une génération (un `set` par billet, id scalaire).
  Future<void> saveGeneratedTickets(List<TicketModel> tickets);

  Future<TicketModel?> fetchTicket(String eventId, String ticketId);

  Future<List<TicketModel>> fetchEventTickets(String eventId);

  /// Billets possédés par un utilisateur (collectionGroup `tickets`).
  Future<List<TicketModel>> fetchMyTickets(String userId);

  /// Acquiert le billet `ticketId` pour `userId` — transaction + précondition
  /// (`status == unused` ET `userId` vide). Rejeu du même acheteur = succès.
  Future<TicketModel> claimTicket({
    required String eventId,
    required String ticketId,
    required String userId,
  });

  /// Validation d'entrée `VALID → USED` — transaction + précondition.
  /// Rejeu d'un billet déjà `used` = succès (idempotent).
  Future<TicketModel> validateTicketEntry({
    required String eventId,
    required String ticketId,
  });
}

/// Implémentation Firestore conformément à `deploy/firestore.rules`.
class FirestoreTicketRemoteDataSource implements TicketRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreTicketRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _ticketDoc(
    String eventId,
    String ticketId,
  ) =>
      _firestore
          .collection('events')
          .doc(eventId)
          .collection('tickets')
          .doc(ticketId);

  @override
  Future<void> saveGeneratedTickets(List<TicketModel> tickets) async {
    final batch = _firestore.batch();
    for (final ticket in tickets) {
      batch.set(_ticketDoc(ticket.eventId, ticket.id), ticket.toJson());
    }
    await batch.commit();
  }

  @override
  Future<TicketModel?> fetchTicket(String eventId, String ticketId) async {
    final doc = await _ticketDoc(eventId, ticketId).get();
    final data = doc.data();
    if (data == null) return null;
    return TicketModel.fromJson(data);
  }

  @override
  Future<List<TicketModel>> fetchEventTickets(String eventId) async {
    final snapshot = await _firestore
        .collection('events')
        .doc(eventId)
        .collection('tickets')
        .orderBy('updated_at_ms')
        .get();
    return snapshot.docs
        .map((doc) => TicketModel.fromJson(doc.data()))
        .toList(growable: false);
  }

  @override
  Future<List<TicketModel>> fetchMyTickets(String userId) async {
    final snapshot = await _firestore
        .collectionGroup('tickets')
        .where('user_id', isEqualTo: userId)
        .orderBy('updated_at_ms')
        .get();
    return snapshot.docs
        .map((doc) => TicketModel.fromJson(doc.data()))
        .toList(growable: false);
  }

  @override
  Future<TicketModel> claimTicket({
    required String eventId,
    required String ticketId,
    required String userId,
  }) {
    return _firestore.runTransaction((transaction) async {
      final ref = _ticketDoc(eventId, ticketId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        throw const TicketStateConflictException(
          'Billet absent du catalogue distant.',
        );
      }
      final data = snapshot.data()!;
      final status = data['status'] as String;
      final owner = data['user_id'] as String? ?? '';

      if (status == 'valid' && owner == userId) {
        // Rejeu idempotent : l'acquisition de ce billet par ce même acheteur
        // a déjà été poussée. On renvoie l'état courant en succès.
        return TicketModel.fromJson(data);
      }
      if (status != 'unused' || owner != '') {
        throw TicketStateConflictException(
          'Billet déjà attribué ou utilisé.',
        );
      }

      final claimed = TicketModel(
        id: ticketId,
        status: TicketStatus.valid,
        uniqueCode: data['unique_code'] as String,
        qrSignature: data['qr_signature'] as String,
        userId: userId,
        eventId: eventId,
        updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      transaction.set(ref, claimed.toJson());
      return claimed;
    });
  }

  @override
  Future<TicketModel> validateTicketEntry({
    required String eventId,
    required String ticketId,
  }) {
    return _firestore.runTransaction((transaction) async {
      final ref = _ticketDoc(eventId, ticketId);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) {
        throw const TicketStateConflictException('Billet introuvable.');
      }
      final data = snapshot.data()!;
      final status = data['status'] as String;

      if (status == 'used') {
        // Rejeu idempotent : déjà validé.
        return TicketModel.fromJson(data);
      }
      if (status != 'valid') {
        throw TicketStateConflictException('Billet non validable.');
      }

      final used = TicketModel(
        id: ticketId,
        status: TicketStatus.used,
        uniqueCode: data['unique_code'] as String,
        qrSignature: data['qr_signature'] as String,
        userId: data['user_id'] as String? ?? '',
        eventId: eventId,
        updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      transaction.set(ref, used.toJson());
      return used;
    });
  }
}