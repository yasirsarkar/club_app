// lib/providers/event_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<EventModel> _events = [];

  List<EventModel> get events => _events;

  EventProvider() {
    fetchEvents();
  }

  // সকল ইভেন্টের তালিকা নিয়ে আসে
  void fetchEvents() {
    _firestore
        .collection('events')
        .orderBy('eventDate', descending: false) // তারিখ অনুযায়ী সাজানো
        .snapshots()
        .listen((snapshot) {
      _events = snapshot.docs
          .map((doc) => EventModel.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    });
  }

  // নতুন ইভেন্ট যোগ করে
  Future<void> addEvent(EventModel event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  // বিদ্যমান ইভেন্ট আপডেট করে
  Future<void> updateEvent(EventModel event) async {
    await _firestore.collection('events').doc(event.id).update(event.toMap());
  }

  // ইভেন্ট ডিলিট করে
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  // কোনো সদস্যকে ইভেন্টে রেজিস্টার করায়
  Future<void> registerForEvent(String eventId, String userId, String userName) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .doc(userId)
        .set({
      'userName': userName,
      'registrationDate': Timestamp.now(),
    });
  }

  // কোনো ইভেন্টের জন্য রেজিস্টার্ড সদস্যদের তালিকা নিয়ে আসে
  Stream<QuerySnapshot> getEventRegistrations(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .snapshots();
  }
}