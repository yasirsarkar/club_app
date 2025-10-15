// lib/providers/member_provider.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore ইম্পোর্ট করুন
import 'package:flutter/material.dart';
import '../models/member_model.dart';

class MemberProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Member> _members = [];
  StreamSubscription<QuerySnapshot>? _sub;

  MemberProvider() {
    fetchMembers();
  }

  void fetchMembers() {
    _sub = _firestore.collection('members').snapshots().listen((snapshot) {
      _members = snapshot.docs.map((doc) => Member.fromMap(doc.id, doc.data())).toList();
      notifyListeners();
    });
  }

  List<Member> get members => _members;

  Future<void> addMember(Member member) async {
    // TODO: Add member logic should also create a corresponding 'users' document
    await _firestore.collection('members').doc(member.id).set(member.toMap());
  }

  // --- এই ফাংশনটিতে পরিবর্তন আনা হয়েছে ---
  Future<void> updateMember(Member member) async {
    try {
      final batch = _firestore.batch();

      // ১. 'members' কালেকশন আপডেট করা
      final memberRef = _firestore.collection('members').doc(member.id);
      batch.update(memberRef, member.toMap());

      // ২. 'users' কালেকশনও আপডেট করা
      final userRef = _firestore.collection('users').doc(member.id);
      batch.update(userRef, {
        'subscriptionPlanId': member.subscriptionPlanId,
        'paidUpTo': member.paidUpTo,
      });

      await batch.commit();
    } catch (e) {
      print('Error updating member in both collections: $e');
      rethrow;
    }
  }

  Future<void> deleteMember(String memberId) async {
    final batch = _firestore.batch();
    batch.delete(_firestore.collection('members').doc(memberId));
    batch.delete(_firestore.collection('users').doc(memberId));
    await batch.commit();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}