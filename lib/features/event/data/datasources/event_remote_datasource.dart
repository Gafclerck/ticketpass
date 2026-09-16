import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/entities/role.dart';
import '../models/event_model.dart';
import '../models/event_role_model.dart';

/// Contrat de la source distante (Firestore) des événements et rôles.
///
/// Seule couche touchant Firestore pour ce domaine. Toutes les écritures sont
/// idempotentes (documents adressés par un `id` client, `set`/`delete`) : le
/// rejeu d'une opération échouée n'est jamais destructeur.
abstract class EventRemoteDataSource {
  Future<void> createEvent(EventModel event);

  /// Écrit (fusion) les champs de l'événement. Sans toucher au reste :
  /// `ticketsNumber` n'existe pas côté distant (compteur dérivé).
  Future<void> updateEvent(EventModel event);

  /// Supprime l'événement et ses sous-collections (billets puis rôles),
  /// puis le document. Idempotent : supprimer un doc absent = succès.
  Future<void> deleteEvent(String eventId);

  Future<EventModel?> fetchEventById(String eventId);

  Future<List<EventModel>> fetchAllEvents();

  Future<List<EventRoleModel>> fetchRoles(String eventId);

  /// Ajoute un rôle à `roles/{userId}` (`arrayUnion` : idempotent, sans
  /// écraser les rôles posés par un autre appareil).
  Future<void> assignRole(String eventId, String userId, Role role);
}

/// Implémentation Firestore conformément à `deploy/firestore.rules`.
///
/// `eventId`/`userId` sont des ids clients (UUID / uid Firebase) : aucun
/// document auto-généré, donc des rejeux `set`/`delete` sans effet de bord.
class FirestoreEventRemoteDataSource implements EventRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreEventRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _events =>
      _firestore.collection('events');

  DocumentReference<Map<String, dynamic>> _eventDoc(String eventId) =>
      _events.doc(eventId);

  @override
  Future<void> createEvent(EventModel event) async {
    await _eventDoc(event.id).set(event.toJson());
  }

  @override
  Future<void> updateEvent(EventModel event) async {
    await _eventDoc(event.id).set(event.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final eventRef = _eventDoc(eventId);
    await _deleteSubcollection(eventRef.collection('tickets'));
    await _deleteSubcollection(eventRef.collection('roles'));
    await eventRef.delete();
  }

  Future<void> _deleteSubcollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    // Chaque lot 400 documents (limite Firestore : 500 écritures / batch).
    // Un doc absent (rejeu) sort de la requête : no-op sûr.
    while (true) {
      final snapshot = await collection.limit(400).get();
      if (snapshot.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  @override
  Future<EventModel?> fetchEventById(String eventId) async {
    final doc = await _eventDoc(eventId).get();
    final data = doc.data();
    if (data == null) return null;
    return EventModel.fromJson(data);
  }

  @override
  Future<List<EventModel>> fetchAllEvents() async {
    final snapshot = await _events.orderBy('event_date_ms').get();
    return snapshot.docs
        .map((doc) => EventModel.fromJson(doc.data()))
        .toList(growable: false);
  }

  @override
  Future<List<EventRoleModel>> fetchRoles(String eventId) async {
    final snapshot = await _eventDoc(
      eventId,
    ).collection('roles').get();
    return snapshot.docs
        .map((doc) => EventRoleModel.fromJson(doc.data()))
        .toList(growable: false);
  }

  @override
  Future<void> assignRole(
    String eventId,
    String userId,
    Role role,
  ) async {
    final doc = _eventDoc(eventId).collection('roles').doc(userId);
    await doc.set(
      {
        'user_id': userId,
        'roles': FieldValue.arrayUnion([role.name]),
      },
      SetOptions(merge: true),
    );
  }
}