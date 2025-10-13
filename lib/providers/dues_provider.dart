// lib/providers/dues_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/member_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/member_due_status.dart';

class DuesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MemberWithDueStatus> _unpaidMembers = [];
  List<MemberWithDueStatus> _paidMembers = [];
  bool _isLoading = true;

  List<MemberWithDueStatus> get unpaidMembers => _unpaidMembers;
  List<MemberWithDueStatus> get paidMembers => _paidMembers;
  bool get isLoading => _isLoading;

  DuesProvider() {
    fetchDuesStatusForCurrentMonth();
  }

  Future<void> fetchDuesStatusForCurrentMonth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

      final plansFuture = _firestore.collection('subscription_plans').get();
      final membersFuture = _firestore.collection('members').where('subscriptionPlanId', isNotEqualTo: null).get();
      final transactionsFuture = _firestore.collection('transactions').where('paymentForMonth', isEqualTo: currentMonth).get();

      final results = await Future.wait([plansFuture, membersFuture, transactionsFuture]);

      final plansSnapshot = results[0] as QuerySnapshot;
      final membersSnapshot = results[1] as QuerySnapshot;
      final transactionsSnapshot = results[2] as QuerySnapshot;

      final List<SubscriptionPlan> plans = plansSnapshot.docs.map((doc) => SubscriptionPlan.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      final List<Member> members = membersSnapshot.docs.map((doc) => Member.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      final List<DocumentSnapshot> transactions = transactionsSnapshot.docs;

      final List<MemberWithDueStatus> tempUnpaid = [];
      final List<MemberWithDueStatus> tempPaid = [];

      for (var member in members) {
        final plan = plans.firstWhere((p) => p.id == member.subscriptionPlanId, orElse: () => SubscriptionPlan(id: '', planName: 'N/A', amount: 0, description: ''));
        if (plan.id.isEmpty) continue;

        // --- পরিবর্তনটি এখানে ---
        // firstWhere-এর পরিবর্তে একটি নিরাপদ লুপ ব্যবহার করা হয়েছে
        DocumentSnapshot? transaction;
        for (final t in transactions) {
          if (t['memberId'] == member.id) {
            transaction = t;
            break;
          }
        }
        // --- পরিবর্তন শেষ ---

        if (transaction != null) {
          tempPaid.add(MemberWithDueStatus(
            member: member,
            plan: plan,
            isPaid: true,
            paymentDate: (transaction['date'] as Timestamp).toDate(),
          ));
        } else {
          tempUnpaid.add(MemberWithDueStatus(
            member: member,
            plan: plan,
            isPaid: false,
          ));
        }
      }

      _unpaidMembers = tempUnpaid;
      _paidMembers = tempPaid;
    } catch (e) {
      print('Error fetching dues status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // lib/providers/dues_provider.dart ফাইলের ভেতরে

  Future<void> recordPayment(String memberId, double amount, String recordedByUid) async {
    final String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    try {
      await _firestore.collection('transactions').add({
        'memberId': memberId,
        'amount': amount,
        'date': Timestamp.now(),
        'paymentForMonth': currentMonth,
        'type': 'Subscription',
        'recordedBy': recordedByUid,
      });
      // পেমেন্ট রেকর্ড হওয়ার পর তালিকাটি রিফ্রেশ করা হচ্ছে
      await fetchDuesStatusForCurrentMonth();
    } catch (e) {
      print('Error recording payment: $e');
      rethrow;
    }
  }
}