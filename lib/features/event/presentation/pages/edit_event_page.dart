import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/page_header.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_type.dart';
import '../providers/event_providers.dart';

class EditEventPage extends ConsumerStatefulWidget {
  final Event event;

  const EditEventPage({super.key, required this.event});

  @override
  ConsumerState<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends ConsumerState<EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _eventPlaceController;
  late final TextEditingController _maxPlacesController;
  late final TextEditingController _brandNameController;

  late DateTime _selectedDate;
  late EventType _eventType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(
      text: widget.event.description,
    );
    _eventPlaceController = TextEditingController(
      text: widget.event.eventPlace,
    );
    _maxPlacesController = TextEditingController(
      text: widget.event.maxPlaces.toString(),
    );
    _brandNameController = TextEditingController(
      text: widget.event.brandName,
    );
    _selectedDate = widget.event.startTime;
    _eventType = widget.event.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _eventPlaceController.dispose();
    _maxPlacesController.dispose();
    _brandNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(firstDate)
          ? firstDate
          : _selectedDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final updatedEvent = widget.event.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      eventDate: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      startTime: _selectedDate,
      eventPlace: _eventPlaceController.text.trim(),
      maxPlaces: int.parse(_maxPlacesController.text.trim()),
      brandName: _brandNameController.text.trim(),
      type: _eventType,
    );

    try {
      await ref.read(updateEventProvider).call(updatedEvent);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la modification : $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteEvent() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer cet événement ?'),
          content: const Text(
            'Cette action supprimera définitivement l’événement.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(deleteEventProvider).call(widget.event.id);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppTheme.pagePadding(
              bottom: AppSpacing.bottomClearanceNoNav,
            ),
            children: [
              PageHeader(
                title: 'Modifier l’événement',
                showBack: true,
                onBack: () => Navigator.pop(context),
                trailing: PressableScale(
                  onTap: _isLoading ? null : _deleteEvent,
                  pressedScale: 0.9,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.glassSubtle,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.errorBorder),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.errorText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
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
                    return 'Entre une capacité supérieure à 0.';
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
              TextFormField(
                readOnly: true,
                onTap: _isLoading ? null : _selectDate,
                decoration: InputDecoration(
                  labelText: 'Date de l’événement',
                  suffixIcon: const Icon(Icons.calendar_today),
                  hintText: dateLabel,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                onTap: _isLoading ? null : _selectTime,
                decoration: InputDecoration(
                  labelText: 'Heure de début',
                  suffixIcon: const Icon(Icons.schedule),
                  hintText: timeLabel,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Enregistrer les modifications',
                fullWidth: true,
                onPressed: _isLoading ? null : _saveEvent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}