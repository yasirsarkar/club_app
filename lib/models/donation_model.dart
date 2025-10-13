// lib/models/donation_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Donation {
  final String id;
  final String donorName;
  final double amount;
  final DateTime date;
  final String? note;
  final String recordedByUid;

  Donation({
    required this.id,
    required this.donorName,
    required this.amount,
    required this.date,
    this.note,
    required this.recordedByUid,
  });

  factory Donation.fromMap(String id, Map<String, dynamic> data) {
    return Donation(
      id: id,
      donorName: data['donorName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'],
      recordedByUid: data['recordedByUid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donorName': donorName,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'note': note,
      'recordedByUid': recordedByUid,
    };
  }
}