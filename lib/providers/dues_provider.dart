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
      // subscriptionPlanId আছে এমন সব সদস্যকে আনা হচ্ছে
      final membersFuture = _firestore.collection('members').where('subscriptionPlanId', isNotEqualTo: null).get();
      final transactionsFuture = _firestore.collection('transactions').where('paymentForMonth', isEqualTo: currentMonth).get();

      final results = await Future.wait([plansFuture, membersFuture, transactionsFuture]);

      final plansSnapshot = results[0] as QuerySnapshot;
      final membersSnapshot = results[1] as QuerySnapshot;
      final transactionsSnapshot = results[2] as QuerySnapshot;

      final List<SubscriptionPlan> plans = plansSnapshot.docs.map((doc) => SubscriptionPlan.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      final List<Member> membersWithPlans = membersSnapshot.docs.map((doc) => Member.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      final List<DocumentSnapshot> transactions = transactionsSnapshot.docs;

      final List<MemberWithDueStatus> tempUnpaid = [];
      final List<MemberWithDueStatus> tempPaid = [];

      for (var member in membersWithPlans) {
        final plan = plans.firstWhere((p) => p.id == member.subscriptionPlanId, orElse: () => SubscriptionPlan(id: '', planName: 'N/A', amount: 0, description: ''));
        if (plan.id.isEmpty) continue;

        DocumentSnapshot? transaction;
        for (final t in transactions) {
          // Firestore-এ ডেটা স্ট্রিং হিসেবে সেভ হতে পারে, তাই toString() ব্যবহার করা নিরাপদ
          if (t['memberId'].toString() == member.id.toString()) {
            transaction = t;
            break;
          }
        }

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

  // --- নতুন ফাংশন ---
  Future<void> recordMultiMonthPayment(String memberId, double amountPerMonth, List<String> months, String recordedByUid) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      for (final month in months) {
        final transactionRef = firestore.collection('transactions').doc();
        batch.set(transactionRef, {
          'memberId': memberId,
          'amount': amountPerMonth,
          'date': Timestamp.now(),
          'paymentForMonth': month,
          'type': 'Subscription',
          'recordedBy': recordedByUid,
        });
      }

      months.sort();
      final lastPaidMonth = months.last;
      final memberRef = firestore.collection('members').doc(memberId);
      batch.update(memberRef, {'paidUpTo': lastPaidMonth});

      final userRef = firestore.collection('users').doc(memberId);
      batch.update(userRef, {'paidUpTo': lastPaidMonth});

      await batch.commit();
      await fetchDuesStatusForCurrentMonth();

    } catch (e) {
      print('Error recording multi-month payment: $e');
      rethrow;
    }
  }
}