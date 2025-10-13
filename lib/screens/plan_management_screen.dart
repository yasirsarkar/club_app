// lib/screens/plan_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_plan_provider.dart';
import '../providers/auth_provider.dart';
import 'add_edit_plan_screen.dart'; // <-- এই ইম্পোর্ট লাইনটি যোগ করা হয়েছে
import '../models/subscription_plan_model.dart';

class PlanManagementScreen extends StatelessWidget {
  const PlanManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<SubscriptionPlanProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isAdmin = authProvider.user?.role == 'Admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Plans')),
      body: planProvider.plans.isEmpty
          ? const Center(child: Text('No subscription plans created yet.'))
          : ListView.builder(
        itemCount: planProvider.plans.length,
        itemBuilder: (context, index) {
          final plan = planProvider.plans[index];
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(plan.planName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(plan.description),
              trailing: Text('৳ ${plan.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              onTap: isAdmin
                  ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddEditPlanScreen(plan: plan)))
                  : null,
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddEditPlanScreen())),
        child: const Icon(Icons.add),
        tooltip: 'Add New Plan',
      )
          : null,
    );
  }
}