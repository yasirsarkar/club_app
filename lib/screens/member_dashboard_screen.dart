// lib/screens/member_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/subscription_plan_model.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_plan_provider.dart';
import 'all_members_screen.dart';
import 'notice_screen.dart';
import 'payment_history_screen.dart';
import 'my_profile_screen.dart';
import 'event_list_screen.dart'; // <-- ইভেন্ট স্ক্রিন ইম্পোর্ট

class MemberDashboardScreen extends StatelessWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final planProvider = Provider.of<SubscriptionPlanProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Could not load user data.')));
    }

    SubscriptionPlan? plan;
    if (user.subscriptionPlanId != null && user.subscriptionPlanId!.isNotEmpty) {
      try {
        plan = planProvider.plans.firstWhere((p) => p.id == user.subscriptionPlanId);
      } catch (e) {
        plan = null;
      }
    }

    int dueMonths = 0;
    if (user.subscriptionPlanId != null) {
      if (user.paidUpTo != null && user.paidUpTo!.isNotEmpty) {
        final now = DateTime.now();
        final lastPaidParts = user.paidUpTo!.split('-');
        final lastPaidDate = DateTime(int.parse(lastPaidParts[0]), int.parse(lastPaidParts[1]));
        dueMonths = (now.year - lastPaidDate.year) * 12 + (now.month - lastPaidDate.month);
      } else {
        dueMonths = 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- প্রোফাইল সামারি কার্ড ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: (user.displayName != null) // TODO: Use user's actual image
                          ? const AssetImage('assets/images/profile_placeholder.png') as ImageProvider
                          : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? 'No Name',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(user.email ?? 'No Email', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- "My Subscription" কার্ড ---
            if (plan != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Subscription', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const Divider(height: 20),
                      ListTile(
                        leading: const Icon(Icons.card_membership, color: Colors.blue),
                        title: const Text('Current Plan'),
                        subtitle: Text('${plan.planName} - ৳${plan.amount.toStringAsFixed(0)}/month'),
                      ),
                      ListTile(
                        leading: Icon(dueMonths <= 0 ? Icons.check_circle : Icons.error, color: dueMonths <= 0 ? Colors.green : Colors.red),
                        title: const Text('Payment Status'),
                        subtitle: Text(dueMonths <= 0 ? 'All dues are clear' : '$dueMonths month(s) pending'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.history),
                            label: const Text('View History'),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Online payment feature is coming soon!'))
                              );
                            },
                            child: const Text('Pay Now'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            Text('Quick Links', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildDashboardCard(
                  context,
                  icon: Icons.list_alt,
                  title: 'সদস্য তালিকা',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllMembersScreen())),
                ),
                // --- পরিবর্তনটি এখানে ---
                _buildDashboardCard(
                  context,
                  icon: Icons.event_available_outlined,
                  title: 'ইভেন্ট',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventListScreen())),
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.campaign_outlined,
                  title: 'নোটিশ বোর্ড',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeScreen())),
                ),
                _buildDashboardCard(
                  context,
                  icon: Icons.person_outline,
                  title: 'আমার প্রোফাইল',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProfileScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}