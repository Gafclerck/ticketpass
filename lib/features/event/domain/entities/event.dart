import 'event_type.dart';
import 'event_status.dart';

/// Événement — spec `docs/classe.md`.
///
/// Champ `organizerId` supprimé : la relation de possession est portée par
/// [EventUserRole] (role `Role.organiser`), comme dans le diagramme de classe.
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final DateTime startTime;
  final String brandingUrl;
  final int ticketsNumber;
  final EventType type;
  final String brandName;
  final String eventPlace;
  final int maxPlaces;
  final EventStatus status;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.startTime,
    this.brandingUrl = '',
    this.ticketsNumber = 0,
    required this.type,
    required this.brandName,
    required this.eventPlace,
    required this.maxPlaces,
    required this.status,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    DateTime? startTime,
    String? brandingUrl,
    int? ticketsNumber,
    EventType? type,
    String? brandName,
    String? eventPlace,
    int? maxPlaces,
    EventStatus? status,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      brandingUrl: brandingUrl ?? this.brandingUrl,
      ticketsNumber: ticketsNumber ?? this.ticketsNumber,
      type: type ?? this.type,
      brandName: brandName ?? this.brandName,
      eventPlace: eventPlace ?? this.eventPlace,
      maxPlaces: maxPlaces ?? this.maxPlaces,
      status: status ?? this.status,
    );
  }
}