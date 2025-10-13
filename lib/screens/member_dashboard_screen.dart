import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'all_members_screen.dart'; // নতুন Member List স্ক্রিন
import 'notice_screen.dart'; // নোটিশ স্ক্রিন
import 'plan_management_screen.dart';

class MemberDashboardScreen extends StatelessWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // যদি কোনো কারণে ইউজার লোড না হয়
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Could not load user data.')));
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
                      backgroundImage: (user.displayName != null) // TODO: Use user's actual image from Firestore
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

            // --- নেভিগেশন গ্রিড ---
            Text('Essential Links', style: Theme.of(context).textTheme.titleLarge),
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
                _buildDashboardCard(
                  context,
                  icon: Icons.payment,
                  title: 'চাঁদার ইতিহাস',
                  onTap: () { /* TODO: Navigate to Payment History Screen */ },
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
                  onTap: () { /* TODO: Navigate to User's Own Profile Screen */ },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // একটি হেল্পার ফাংশন, যা প্রতিটি কার্ড তৈরি করে
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