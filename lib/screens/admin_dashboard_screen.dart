// lib/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'all_members_screen.dart';
import 'dues_collection_screen.dart';
import 'notice_screen.dart';
import 'event_list_screen.dart';
import 'election_screen.dart';
import 'settings_screen.dart';
import 'member_approval_screen.dart';
import 'donation_list_screen.dart';
import 'plan_management_screen.dart'; // <-- এই ইম্পোর্টটি থাকা আবশ্যক

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DashboardModule> modules = [
      DashboardModule(
        title: 'সদস্য ব্যবস্থাপনা',
        icon: Icons.people_outline,
        color: Colors.blue,
        subMenus: [
          SubMenuItem(title: 'সদস্যের তালিকা', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllMembersScreen()))),
          SubMenuItem(title: 'নতুন সদস্য অনুমোদন', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberApprovalScreen()))),
          SubMenuItem(title: 'সদস্য তালিকা এক্সপোর্ট (PDF/CSV)', onTap: () {}),
        ],
      ),
      DashboardModule(
        title: 'আর্থিক ব্যবস্থাপনা',
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.green,
        subMenus: [
          SubMenuItem(title: 'প্যাকেজ ব্যবস্থাপনা', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanManagementScreen()))),
          SubMenuItem(title: 'চাঁদা আদায়', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DuesCollectionScreen()))),
          SubMenuItem(title: 'অনুদান ব্যবস্থাপনা', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationListScreen()))),
          SubMenuItem(title: 'খরচের হিসাব', onTap: () {}),
          SubMenuItem(title: 'আর্থিক রিপোর্ট এক্সপোর্ট', onTap: () {}),
        ],
      ),
      DashboardModule(
        title: 'যোগাযোগ ও কার্যক্রম',
        icon: Icons.connect_without_contact_outlined,
        color: Colors.orange,
        subMenus: [
          SubMenuItem(title: 'নোটিশ ব্যবস্থাপনা', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeScreen()))),
          SubMenuItem(title: 'ইভেন্ট ব্যবস্থাপনা', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventListScreen()))),
          SubMenuItem(title: 'ফটো গ্যালারি', onTap: () {}),
          SubMenuItem(title: 'সদস্যদের মতামত', onTap: () {}),
        ],
      ),
      DashboardModule(
        title: 'অ্যাডমিনিস্ট্রেশন',
        icon: Icons.admin_panel_settings_outlined,
        color: Colors.purple,
        subMenus: [
          SubMenuItem(title: 'নির্বাচন সিস্টেম', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectionScreen()))),
          SubMenuItem(title: 'ভূমিকা ব্যবস্থাপনা (Roles)', onTap: () {}),
          SubMenuItem(title: 'অ্যাক্টিভিটি লগ', onTap: () {}),
          SubMenuItem(title: 'অ্যাপ সেটিংস', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ক্লাবের সারসংক্ষেপ', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Row(
              children: [
                StatCard(title: 'মোট সদস্য', value: '150', icon: Icons.groups, color: Colors.blue),
                SizedBox(width: 16),
                StatCard(title: 'মাসিক আয়', value: '৳ 25,000', icon: Icons.attach_money, color: Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('ম্যানেজমেন্ট মডিউল', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return ModuleCard(module: modules[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Classes & Widgets ---
class SubMenuItem {
  final String title;
  final VoidCallback onTap;
  SubMenuItem({required this.title, required this.onTap});
}

class DashboardModule {
  final String title;
  final IconData icon;
  final Color color;
  final List<SubMenuItem> subMenus;
  DashboardModule({required this.title, required this.icon, required this.color, required this.subMenus});
}

class ModuleCard extends StatelessWidget {
  final DashboardModule module;
  const ModuleCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: module.color.withOpacity(0.1),
          child: Icon(module.icon, color: module.color),
        ),
        title: Text(module.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: module.subMenus.map((subMenu) {
          return ListTile(
            title: Text(subMenu.title),
            leading: const Icon(Icons.arrow_right, size: 20),
            onTap: subMenu.onTap,
            dense: true,
          );
        }).toList(),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}