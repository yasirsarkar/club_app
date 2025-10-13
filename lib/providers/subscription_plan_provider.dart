// lib/providers/subscription_plan_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_plan_model.dart';

class SubscriptionPlanProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<SubscriptionPlan> _plans = [];

  List<SubscriptionPlan> get plans => _plans;

  SubscriptionPlanProvider() {
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    try {
      _firestore
          .collection('subscription_plans')
          .orderBy('amount')
          .snapshots()
          .listen((snapshot) {
        _plans = snapshot.docs
            .map((doc) => SubscriptionPlan.fromMap(doc.id, doc.data()))
            .toList();
        notifyListeners();
      });
    } catch (e) {
      print('Error fetching plans: $e');
    }
  }

  Future<void> addPlan(SubscriptionPlan plan) async {
    try {
      await _firestore.collection('subscription_plans').add(plan.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePlan(SubscriptionPlan plan) async {
    try {
      await _firestore
          .collection('subscription_plans')
          .doc(plan.id)
          .update(plan.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePlan(String id) async {
    try {
      await _firestore.collection('subscription_plans').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}