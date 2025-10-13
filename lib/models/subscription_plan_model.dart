// lib/models/subscription_plan_model.dart

class SubscriptionPlan {
  final String id;
  final String planName;
  final double amount;
  final String description;

  SubscriptionPlan({
    required this.id,
    required this.planName,
    required this.amount,
    required this.description,
  });

  factory SubscriptionPlan.fromMap(String id, Map<String, dynamic> data) {
    return SubscriptionPlan(
      id: id,
      planName: data['planName'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planName': planName,
      'amount': amount,
      'description': description,
    };
  }
}