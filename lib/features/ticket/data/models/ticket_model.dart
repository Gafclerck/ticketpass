import '../../domain/entities/ticket.dart';
import '../../domain/entities/ticket_status.dart';

/// Modèle de données du billet — seul point de (dé)sérialisation.
///
/// C'est le contrat de données partagé entre Firestore (remote), drift (local)
/// et le domaine. Il parle JSON / row, jamais d'API Firebase.
class TicketModel {
  final String id;
  final TicketStatus status;
  final String uniqueCode;
  final String qrSignature;
  final String userId;
  final String eventId;

  const TicketModel({
    required this.id,
    required this.status,
    required this.uniqueCode,
    required this.qrSignature,
    required this.userId,
    required this.eventId,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      status: TicketStatus.values.byName(json['status'] as String),
      uniqueCode: json['unique_code'] as String,
      qrSignature: json['qr_signature'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'unique_code': uniqueCode,
      'qr_signature': qrSignature,
      'user_id': userId,
      'event_id': eventId,
    };
  }

  /// Conversion vers l'entité domaine.
  Ticket toEntity() {
    return Ticket(
      id: id,
      status: status,
      uniqueCode: uniqueCode,
      qrSignature: qrSignature,
      userId: userId,
      eventId: eventId,
    );
  }

  factory TicketModel.fromEntity(Ticket ticket) {
    return TicketModel(
      id: ticket.id,
      status: ticket.status,
      uniqueCode: ticket.uniqueCode,
      qrSignature: ticket.qrSignature,
      userId: ticket.userId,
      eventId: ticket.eventId,
    );
  }
}