import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/ticket/data/models/ticket_model.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';

void main() {
  const base = TicketModel(
    id: 't1',
    status: TicketStatus.valid,
    uniqueCode: 'uc-1',
    qrSignature: 'sig-1',
    userId: 'uid-1',
    eventId: 'ev-1',
    updatedAtMs: 1234,
  );

  test('round-trip toJson/fromJson conserve toutes les clés', () {
    final restored = TicketModel.fromJson(base.toJson());

    expect(restored.id, base.id);
    expect(restored.status, base.status);
    expect(restored.uniqueCode, base.uniqueCode);
    expect(restored.qrSignature, base.qrSignature);
    expect(restored.userId, base.userId);
    expect(restored.eventId, base.eventId);
    expect(restored.updatedAtMs, 1234);
  });

  test('clés remote en snake_case ; user_id tolère l’absence', () {
    final json = base.toJson();
    expect(json['unique_code'], 'uc-1');
    expect(json['qr_signature'], 'sig-1');
    expect(json['user_id'], 'uid-1');
    expect(json['event_id'], 'ev-1');
    expect(json['updated_at_ms'], 1234);

    final withoutUserId = TicketModel.fromJson({
      'id': 't2',
      'status': 'unused',
      'unique_code': 'uc-2',
      'qr_signature': 'sig-2',
      'event_id': 'ev-1',
    });
    expect(withoutUserId.userId, '');
    expect(withoutUserId.updatedAtMs, 0);
  });

  test('fromEntity/ticket vers modèle puis toEntity', () {
    final model = TicketModel.fromEntity(
      const Ticket(
        id: 't1',
        status: TicketStatus.valid,
        uniqueCode: 'uc-1',
        qrSignature: 'sig-1',
        userId: 'uid-1',
        eventId: 'ev-1',
      ),
      updatedAtMs: 42,
    );

    expect(model.updatedAtMs, 42);
    final entity = model.toEntity();
    expect(entity.id, 't1');
    expect(entity.status, TicketStatus.valid);
  });
}