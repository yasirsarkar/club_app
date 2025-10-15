// lib/screens/event_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import 'add_edit_event_screen.dart';
import 'event_attendees_screen.dart'; // <-- নতুন স্ক্রিন ইম্পোর্ট করুন

class EventDetailScreen extends StatefulWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isRegistered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.event.id)
        .collection('registrations')
        .doc(user.uid)
        .get();

    if (mounted) {
      setState(() {
        _isRegistered = doc.exists;
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    try {
      await eventProvider.registerForEvent(widget.event.id, user!.uid, user.displayName ?? 'N/A');
      setState(() => _isRegistered = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully registered for the event!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = Provider.of<AuthProvider>(context, listen: false).user?.role == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Event',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEditEventScreen(event: widget.event)),
                );
              },
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Event',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Are you sure you want to delete this event?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Provider.of<EventProvider>(context, listen: false).deleteEvent(widget.event.id);
                          Navigator.pop(ctx);
                          Navigator.pop(context);
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... আপনার আগের UI কোড (Image, Padding, etc.) ...
            Image.network(
              widget.event.imageUrl.isNotEmpty ? widget.event.imageUrl : 'https://via.placeholder.com/400x250?text=Event+Image',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.event.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildInfoRow(context, Icons.calendar_today, DateFormat('EEEE, dd MMMM, yyyy - hh:mm a').format(widget.event.eventDate)),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, Icons.location_on_outlined, widget.event.location),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, Icons.money, widget.event.registrationFee > 0 ? 'Fee: ৳${widget.event.registrationFee.toStringAsFixed(0)}' : 'Free Entry'),
                  const Divider(height: 32),
                  Text('Details', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(widget.event.description, style: const TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
      // --- এই অংশে পরিবর্তন আনা হয়েছে ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(heightFactor: 1, child: CircularProgressIndicator())
            : (isAdmin
        // যদি অ্যাডমিন হন
            ? ElevatedButton.icon(
          icon: const Icon(Icons.people_outline),
          label: const Text('View Attendees'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventAttendeesScreen(
                  eventId: widget.event.id,
                  eventTitle: widget.event.title,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        )
        // যদি সাধারণ সদস্য হন
            : ElevatedButton(
          onPressed: _isRegistered ? null : _register,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          child: Text(_isRegistered ? 'Already Registered ✔️' : 'Register Now'),
        )
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}