import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/core/security/ticket_signature_service.dart';

void main() {
  group('TicketSignatureService (UC5)', () {
    test('une signature valide se vérifie', () {
      final signature = TicketSignatureService.sign('ticket-1', 'event-1');

      expect(
        TicketSignatureService.verify('ticket-1', 'event-1', signature),
        isTrue,
      );
    });

    test('un ticketId falsifié fait échouer la vérification', () {
      final signature = TicketSignatureService.sign('ticket-1', 'event-1');

      expect(
        TicketSignatureService.verify('ticket-2', 'event-1', signature),
        isFalse,
      );
    });

    test('un eventId falsifié fait échouer la vérification', () {
      final signature = TicketSignatureService.sign('ticket-1', 'event-1');

      expect(
        TicketSignatureService.verify('ticket-1', 'event-2', signature),
        isFalse,
      );
    });

    test('une signature falsifiée fait échouer la vérification', () {
      final signature = TicketSignatureService.sign('ticket-1', 'event-1');
      final tampered = '${signature.substring(0, signature.length - 1)}z';

      expect(
        TicketSignatureService.verify('ticket-1', 'event-1', tampered),
        isFalse,
      );
    });

    test('buildQrPayload puis verifyQrPayload valide le billet', () {
      final payload = TicketSignatureService.buildQrPayload(
        'ticket-1',
        'event-1',
      );

      expect(TicketSignatureService.verifyQrPayload(payload), isTrue);
    });

    test('un payload mal formé est rejeté sans planter', () {
      expect(TicketSignatureService.verifyQrPayload('n-importe-quoi'), isFalse);
    });
  });
}
