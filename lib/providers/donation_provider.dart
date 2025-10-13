// lib/providers/donation_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';

class DonationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Donation> _donations = [];

  List<Donation> get donations => _donations;

  DonationProvider() {
    fetchDonations();
  }

  Future<void> fetchDonations() async {
    try {
      _firestore
          .collection('donations')
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {
        _donations = snapshot.docs
            .map((doc) => Donation.fromMap(doc.id, doc.data()))
            .toList();
        notifyListeners();
      });
    } catch (e) {
      print('Error fetching donations: $e');
    }
  }

  Future<void> addDonation(Donation donation) async {
    try {
      await _firestore.collection('donations').add(donation.toMap());
    } catch (e) {
      print('Error adding donation: $e');
      rethrow;
    }
  }

  Future<void> updateDonation(Donation donation) async {
    try {
      await _firestore
          .collection('donations')
          .doc(donation.id)
          .update(donation.toMap());
    } catch (e) {
      print('Error updating donation: $e');
      rethrow;
    }
  }

  Future<void> deleteDonation(String id) async {
    try {
      await _firestore.collection('donations').doc(id).delete();
    } catch (e) {
      print('Error deleting donation: $e');
      rethrow;
    }
  }
}