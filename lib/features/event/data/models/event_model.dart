import '../../domain/entities/event.dart';
import '../../domain/entities/event_status.dart';
import '../../domain/entities/event_type.dart';

/// Sérialisation d'un événement — document Firestore `events/{eventId}`.
///
/// Clés snake_case (même convention que `UserModel` / `TicketModel`).
/// Volontairement SANS `ticketsNumber` : côté distant c'est un compteur dérivé
/// (le nombre de billets de la sous-collection `tickets`), les clients ne
/// l'écrivent jamais — il n'est qu'une colonne locale recalculée au pull.
class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final DateTime startTime;
  final String brandingUrl;
  final EventType type;
  final String brandName;
  final String eventPlace;
  final int maxPlaces;
  final EventStatus status;
  final int updatedAtMs;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.startTime,
    this.brandingUrl = '',
    required this.type,
    required this.brandName,
    required this.eventPlace,
    required this.maxPlaces,
    required this.status,
    this.updatedAtMs = 0,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      eventDate: DateTime.fromMillisecondsSinceEpoch(
        json['event_date_ms'] as int,
      ),
      startTime: DateTime.fromMillisecondsSinceEpoch(
        json['start_time_ms'] as int,
      ),
      brandingUrl: json['branding_url'] as String? ?? '',
      type: EventType.values.byName(json['event_type'] as String),
      brandName: json['brand_name'] as String? ?? '',
      eventPlace: json['event_place'] as String? ?? '',
      maxPlaces: json['max_places'] as int,
      status: EventStatus.values.byName(json['event_status'] as String),
      updatedAtMs: json['updated_at_ms'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date_ms': eventDate.millisecondsSinceEpoch,
      'start_time_ms': startTime.millisecondsSinceEpoch,
      'branding_url': brandingUrl,
      'event_type': type.name,
      'brand_name': brandName,
      'event_place': eventPlace,
      'max_places': maxPlaces,
      'event_status': status.name,
      'updated_at_ms': updatedAtMs,
    };
  }

  factory EventModel.fromEntity(Event event, {int updatedAtMs = 0}) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      eventDate: event.eventDate,
      startTime: event.startTime,
      brandingUrl: event.brandingUrl,
      type: event.type,
      brandName: event.brandName,
      eventPlace: event.eventPlace,
      maxPlaces: event.maxPlaces,
      status: event.status,
      updatedAtMs: updatedAtMs,
    );
  }

  Event toEntity() {
    return Event(
      id: id,
      title: title,
      description: description,
      eventDate: eventDate,
      startTime: startTime,
      brandingUrl: brandingUrl,
      type: type,
      brandName: brandName,
      eventPlace: eventPlace,
      maxPlaces: maxPlaces,
      status: status,
    );
  }
}