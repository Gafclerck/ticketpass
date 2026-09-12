import 'ticket_status.dart';

/// Billet — spec `docs/classe.md`.
class Ticket {
  final String id;
  final TicketStatus status;
  final String uniqueCode;
  final String qrSignature;
  final String userId;
  final String eventId;

  const Ticket({
    required this.id,
    required this.status,
    required this.uniqueCode,
    required this.qrSignature,
    required this.userId,
    required this.eventId,
  });

  Ticket copyWith({
    String? id,
    TicketStatus? status,
    String? uniqueCode,
    String? qrSignature,
    String? userId,
    String? eventId,
  }) {
    return Ticket(
      id: id ?? this.id,
      status: status ?? this.status,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      qrSignature: qrSignature ?? this.qrSignature,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
    );
  }
}