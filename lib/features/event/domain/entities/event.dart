class Event {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final int capacity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.capacity,
    required this.createdAt,
    required this.updatedAt,
  });

  Event copyWith({
    String? id,
    String? organizerId,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    int? capacity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
