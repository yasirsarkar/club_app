// lib/models/notice_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String id;
  final String title;
  final String details;
  final String authorName;
  final DateTime timestamp;

  Notice({
    required this.id,
    required this.title,
    required this.details,
    required this.authorName,
    required this.timestamp,
  });

  factory Notice.fromMap(String id, Map<String, dynamic> data) {
    return Notice(
      id: id,
      title: data['title'] ?? '',
      details: data['details'] ?? '',
      authorName: data['authorName'] ?? 'Admin',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'details': details,
      'authorName': authorName,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}