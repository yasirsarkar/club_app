// lib/models/member_due_status.dart

import 'member_model.dart';
import 'subscription_plan_model.dart';

class MemberWithDueStatus {
  final Member member;
  final SubscriptionPlan plan;
  final bool isPaid;
  final DateTime? paymentDate;

  MemberWithDueStatus({
    required this.member,
    required this.plan,
    required this.isPaid,
    this.paymentDate,
  });
}