import 'package:flutter_test/flutter_test.dart';
import 'package:ticketpass/features/event/data/models/event_model.dart';
import 'package:ticketpass/features/event/domain/entities/event.dart';
import 'package:ticketpass/features/event/domain/entities/event_status.dart';
import 'package:ticketpass/features/event/domain/entities/event_type.dart';

void main() {
  test('round-trip toJson/fromJson conserve timestamps et horodatage', () {
    final model = EventModel(
      id: 'ev1',
      title: 'Concert',
      description: 'Description',
      eventDate: DateTime(2026, 10, 1),
      startTime: DateTime(2026, 10, 1, 20),
      brandingUrl: '',
      type: EventType.festival,
      brandName: 'Artiste',
      eventPlace: 'Paris',
      maxPlaces: 100,
      status: EventStatus.passed,
      updatedAtMs: 1234,
    );

    final restored = EventModel.fromJson(model.toJson());

    expect(restored.eventDate, model.eventDate);
    expect(restored.startTime, model.startTime);
    expect(restored.type, EventType.festival);
    expect(restored.status, EventStatus.passed);
    expect(restored.updatedAtMs, 1234);
  });

  test('clés remote en snake_case, jamais de tickets_number', () {
    final json = EventModel.fromEntity(
      Event(
        id: 'ev1',
        title: 'Concert',
        description: 'Description',
        eventDate: DateTime(2026, 10, 1),
        startTime: DateTime(2026, 10, 1, 20),
        ticketsNumber: 50,
        type: EventType.concert,
        brandName: 'Artiste',
        eventPlace: 'Paris',
        maxPlaces: 100,
        status: EventStatus.upcoming,
      ),
    ).toJson();

    expect(json['event_date_ms'], DateTime(2026, 10, 1).millisecondsSinceEpoch);
    expect(json['start_time_ms'], DateTime(2026, 10, 1, 20).millisecondsSinceEpoch);
    expect(json.containsKey('tickets_number'), isFalse);
    expect(json['event_type'], 'concert');
    expect(json['event_status'], 'upcoming');
    expect(json['updated_at_ms'], 0);
  });

  test('fromJson tolère les champs optionnels absents', () {
    final restored = EventModel.fromJson({
      'id': 'ev1',
      'title': 'Concert',
      'event_date_ms': 0,
      'start_time_ms': 0,
      'event_type': 'concert',
      'max_places': 100,
      'event_status': 'upcoming',
    });

    expect(restored.description, '');
    expect(restored.brandingUrl, '');
    expect(restored.brandName, '');
    expect(restored.eventPlace, '');
    expect(restored.updatedAtMs, 0);
  });
}