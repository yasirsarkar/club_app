// lib/providers/notice_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notice_model.dart';

class NoticeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Notice> _notices = [];

  List<Notice> get notices => _notices;

  NoticeProvider() {
    fetchNotices();
  }

  void fetchNotices() {
    _firestore
        .collection('notices')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notices = snapshot.docs
          .map((doc) => Notice.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    });
  }

  Future<void> addNotice(Notice notice) async {
    await _firestore.collection('notices').add(notice.toMap());
  }

  Future<void> updateNotice(Notice notice) async {
    await _firestore.collection('notices').doc(notice.id).update(notice.toMap());
  }

  Future<void> deleteNotice(String id) async {
    await _firestore.collection('notices').doc(id).delete();
  }
}