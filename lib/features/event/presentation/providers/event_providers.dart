import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_event_repository.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/get_discover_events.dart';
import '../../domain/usecases/get_event_by_id.dart';
import '../../domain/usecases/get_my_events.dart';
import '../../domain/usecases/update_event.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return MockEventRepository.demo();
});

final createEventProvider = Provider<CreateEvent>((ref) {
  return CreateEvent(ref.watch(eventRepositoryProvider));
});

final updateEventProvider = Provider<UpdateEvent>((ref) {
  return UpdateEvent(ref.watch(eventRepositoryProvider));
});

final deleteEventProvider = Provider<DeleteEvent>((ref) {
  return DeleteEvent(ref.watch(eventRepositoryProvider));
});

final getMyEventsProvider = Provider<GetMyEvents>((ref) {
  return GetMyEvents(ref.watch(eventRepositoryProvider));
});

final myEventsProvider = FutureProvider.family<List<Event>, String>((
  ref,
  userId,
) {
  return ref.watch(getMyEventsProvider).call(userId);
});

final discoverEventsProvider = FutureProvider<List<Event>>((ref) {
  return ref.watch(getDiscoverEventsProvider).call();
});

final getDiscoverEventsProvider = Provider<GetDiscoverEvents>((ref) {
  return GetDiscoverEvents(ref.watch(eventRepositoryProvider));
});

final eventProvider = FutureProvider.family<Event, String>((ref, eventId) {
  return ref.watch(getEventByIdProvider).call(eventId);
});

final getEventByIdProvider = Provider<GetEventById>((ref) {
  return GetEventById(ref.watch(eventRepositoryProvider));
});
