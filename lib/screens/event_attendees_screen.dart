// lib/screens/event_attendees_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class EventAttendeesScreen extends StatelessWidget {
  final String eventId;
  final String eventTitle;

  const EventAttendeesScreen({super.key, required this.eventId, required this.eventTitle});

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendees for $eventTitle'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventProvider.getEventRegistrations(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No members have registered for this event yet.'));
          }

          final attendees = snapshot.data!.docs;

          return ListView.builder(
            itemCount: attendees.length,
            itemBuilder: (context, index) {
              final attendeeData = attendees[index].data() as Map<String, dynamic>;
              final date = (attendeeData['registrationDate'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd MMM, yyyy - hh:mm a').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(attendeeData['userName'] ?? 'Unknown Member'),
                  subtitle: Text('Registered on: $formattedDate'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}