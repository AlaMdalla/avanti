import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import 'event_form_screen.dart';

class EventViewScreen extends StatefulWidget {
  final Event event;

  const EventViewScreen({super.key, required this.event});

  @override
  State<EventViewScreen> createState() => _EventViewScreenState();
}

class _EventViewScreenState extends State<EventViewScreen> {
  final _eventService = EventService();
  late Future<Event> _eventFuture;
  bool _isRegistered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _eventFuture = _eventService.getById(widget.event.id);
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final registered = await _eventService.isUserRegistered(
          widget.event.id,
          user.id,
        );
        if (mounted) {
          setState(() {
            _isRegistered = registered;
          });
        }
      }
    } catch (e) {
      print('Error checking registration: $e');
    }
  }

  Future<void> _toggleRegistration() async {
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
      if (_isRegistered) {
        await _eventService.unregisterFromEvent(widget.event.id, user.id);
      } else {
        await _eventService.registerForEvent(widget.event.id, user.id);
      }

      if (mounted) {
        setState(() {
          _isRegistered = !_isRegistered;
          _eventFuture = _eventService.getById(widget.event.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isRegistered
                  ? 'You are now registered for this event'
                  : 'You have been unregistered from this event',
            ),
          ),
        );
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

  Future<void> _deleteEvent() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.id != widget.event.createdBy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete your own events')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _eventService.delete(widget.event.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        elevation: 0,
      ),
      body: FutureBuilder<Event>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final event = snapshot.data!;
          final dateFormat = DateFormat('EEEE, MMMM dd, yyyy - hh:mm a');
          final user = Supabase.instance.client.auth.currentUser;
          final isCreator = user?.id == event.createdBy;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (event.imageUrl != null)
                  Image.network(
                    event.imageUrl!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  )
                else
                  Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.event,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: event.isUpcoming ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.isUpcoming ? 'Upcoming' : 'Past Event',
                          style: TextStyle(
                            color:
                                event.isUpcoming ? Colors.blue[800] : Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date and Time
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        title: 'Date & Time',
                        content: dateFormat.format(event.eventDate),
                      ),
                      const SizedBox(height: 12),

                      // Location or Online
                      if (event.isOnline)
                        _buildInfoRow(
                          icon: Icons.videocam,
                          title: 'Event Type',
                          content: 'Online Event',
                        )
                      else if (event.location != null)
                        _buildInfoRow(
                          icon: Icons.location_on,
                          title: 'Location',
                          content: event.location!,
                        ),

                      if (event.isOnline && event.eventLink != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.link,
                          title: 'Event Link',
                          content: event.eventLink!,
                          isLink: true,
                        ),
                      ],

                      // Attendees
                      if (event.maxAttendees != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.people,
                          title: 'Attendees',
                          content:
                              '${event.currentAttendees ?? 0}/${event.maxAttendees} (${event.spotsLeft} spots left)',
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Description
                      if (event.description != null && event.description!.isNotEmpty) ...[
                        const Text(
                          'About This Event',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description!,
                          style: const TextStyle(height: 1.6),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _toggleRegistration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isRegistered ? Colors.red : Colors.blue,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _isRegistered
                                          ? 'Unregister'
                                          : event.hasSpace
                                              ? 'Register'
                                              : 'Event Full',
                                    ),
                            ),
                          ),
                          if (isCreator) ...[
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventFormScreen(event: event),
                                  ),
                                ).then((_) {
                                  setState(() {
                                    _eventFuture = _eventService.getById(event.id);
                                  });
                                });
                              },
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit Event',
                            ),
                            IconButton(
                              onPressed: _deleteEvent,
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete Event',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(fontSize: 16),
                maxLines: isLink ? 1 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
