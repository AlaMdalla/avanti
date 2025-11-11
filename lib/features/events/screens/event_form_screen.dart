import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _eventLinkController;
  late TextEditingController _maxAttendeesController;

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _imageFile;
  String? _imageUrl;
  bool _isOnline = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _locationController =
        TextEditingController(text: widget.event?.location ?? '');
    _eventLinkController =
        TextEditingController(text: widget.event?.eventLink ?? '');
    _maxAttendeesController =
        TextEditingController(text: widget.event?.maxAttendees?.toString() ?? '');
    _selectedDate = widget.event?.eventDate ?? _selectedDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.event?.eventDate ?? DateTime.now());
    _isOnline = widget.event?.isOnline ?? false;
    _imageUrl = widget.event?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _eventLinkController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  DateTime _getCombinedDateTime() {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _imageUrl;

      // Upload image if new one was selected
      if (_imageFile != null) {
        imageUrl = await _eventService.uploadImage(
          _imageFile!,
          userId: user.id,
        );
      }

      final input = EventInput(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        eventDate: _getCombinedDateTime(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        categoryId: null,
        maxAttendees: _maxAttendeesController.text.isEmpty
            ? null
            : int.tryParse(_maxAttendeesController.text),
        isOnline: _isOnline,
        eventLink: _eventLinkController.text.trim().isEmpty
            ? null
            : _eventLinkController.text.trim(),
      );

      if (widget.event != null) {
        // Update existing event
        await _eventService.update(widget.event!.id, input);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event updated successfully')),
          );
        }
      } else {
        // Create new event
        final event = await _eventService.create(input, userId: user.id);
        if (imageUrl != null && mounted) {
          await _eventService.update(event.id, input.copyWith(imageUrl: imageUrl));
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event created successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Edit Event' : 'Create Event'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add event image',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Event Date *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Online/Offline toggle
              SwitchListTile(
                title: const Text('Online Event'),
                value: _isOnline,
                onChanged: (value) {
                  setState(() {
                    _isOnline = value;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Location or Event Link
              if (!_isOnline)
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                )
              else
                TextFormField(
                  controller: _eventLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Event Link',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
              const SizedBox(height: 16),

              // Max Attendees
              TextFormField(
                controller: _maxAttendeesController,
                decoration: const InputDecoration(
                  labelText: 'Max Attendees (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.event != null ? 'Update Event' : 'Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on EventInput {
  EventInput copyWith({
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    String? categoryId,
    int? maxAttendees,
    bool? isOnline,
    String? eventLink,
    String? imageUrl,
  }) {
    return EventInput(
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      location: location ?? this.location,
      categoryId: categoryId ?? this.categoryId,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      isOnline: isOnline ?? this.isOnline,
      eventLink: eventLink ?? this.eventLink,
    );
  }
}
