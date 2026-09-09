import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ticketpass/core/providers/current_user_provider.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_status.dart';
import '../../domain/entities/event_type.dart';
import '../providers/event_providers.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  const CreateEventPage({super.key});

  @override
  ConsumerState<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends ConsumerState<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _eventPlaceController = TextEditingController();
  final _maxPlacesController = TextEditingController();
  final _brandNameController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  EventType _eventType = EventType.other;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _eventPlaceController.dispose();
    _maxPlacesController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) return;

    setState(() {
      _selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _selectedDate.hour,
        _selectedDate.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (selectedTime == null || !mounted) return;

    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final event = Event(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      eventDate: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      startTime: _selectedDate,
      type: _eventType,
      brandName: _brandNameController.text.trim(),
      eventPlace: _eventPlaceController.text.trim(),
      maxPlaces: int.parse(_maxPlacesController.text.trim()),
      status: EventStatus.upcoming,
    );

    try {
      final userId = ref.read(currentUserIdProvider);
      await ref.read(createEventProvider).call(event, userId: userId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement créé avec succès.')),
      );

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de créer l’événement.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(_selectedDate);
    final timeLabel = TimeOfDay.fromDateTime(_selectedDate).format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un événement')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de l’événement',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le titre est obligatoire.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La description est obligatoire.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _eventPlaceController,
                decoration: const InputDecoration(labelText: 'Lieu'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le lieu est obligatoire.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _maxPlacesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacité max'),
                validator: (value) {
                  final maxPlaces = int.tryParse(value ?? '');
                  if (maxPlaces == null || maxPlaces <= 0) {
                    return 'Entre une capacité valide.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandNameController,
                decoration: const InputDecoration(labelText: 'Nom de marque'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EventType>(
                initialValue: _eventType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: EventType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _eventType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.grey),
                ),
                title: const Text('Date de l’événement'),
                subtitle: Text(dateLabel),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: const BorderSide(color: Colors.grey),
                ),
                title: const Text('Heure de début'),
                subtitle: Text(timeLabel),
                trailing: const Icon(Icons.schedule),
                onTap: _pickTime,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _saveEvent,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Créer l’événement'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}