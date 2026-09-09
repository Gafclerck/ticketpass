import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/event.dart';
import '../pages/create_event_page.dart';
import '../pages/edit_event_page.dart';
import '../providers/event_providers.dart';

class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  static const _organizerId = 'demo-organizer-id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(myEventsProvider(_organizerId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Mes événements'),
        centerTitle: true,
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Erreur : $error')),
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('Aucun événement pour le moment.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myEventsProvider(_organizerId));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = events[index];
                return _EventCard(
                  event: event,
                  onUpdated: () {
                    ref.invalidate(myEventsProvider(_organizerId));
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final isCreated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventPage()),
          );

          if (isCreated == true) {
            ref.invalidate(myEventsProvider(_organizerId));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onUpdated;

  const _EventCard({required this.event, required this.onUpdated});

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(event.date);

    return Card(
      child: ListTile(
        onTap: () async {
          final isUpdated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => EditEventPage(event: event)),
          );

          if (isUpdated == true) {
            onUpdated();
          }
        },
        leading: const CircleAvatar(child: Icon(Icons.event)),
        title: Text(event.title),
        subtitle: Text(
          '$dateLabel\n${event.location} • ${event.capacity} places',
        ),
        isThreeLine: true,
      ),
    );
  }
}
