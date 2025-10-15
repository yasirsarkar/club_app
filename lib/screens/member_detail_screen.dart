// lib/screens/member_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/member_model.dart';
import '../models/subscription_plan_model.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_plan_provider.dart';
import 'add_edit_member_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  final Member member;
  const MemberDetailScreen({required this.member, super.key});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabCount = 1; // Default to 1 tab for general members

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isAdmin = authProvider.user?.role == 'Admin';
    final bool isViewingOwnProfile = authProvider.user?.uid == widget.member.id;

    if (isAdmin || isViewingOwnProfile) {
      _tabCount = 3; // Admins and self-viewers get 3 tabs
    }

    _tabController = TabController(length: _tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isAdmin = authProvider.user?.role == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member.name),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Member',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditMemberScreen(member: widget.member),
                  ),
                );
              },
            ),
        ],
        bottom: _tabCount > 1
            ? TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Personal'),
            Tab(icon: Icon(Icons.monetization_on), text: 'Financial'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        )
            : null,
      ),
      body: _tabCount > 1
          ? TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalInfoTab(context, widget.member),
          _buildFinancialStatusTab(context, widget.member),
          _buildTransactionHistoryTab(context, widget.member.id),
        ],
      )
          : _buildPersonalInfoTab(context, widget.member),
    );
  }

  Widget _buildPersonalInfoTab(BuildContext context, Member member) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Hero(
            tag: member.id,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: member.profileImage.isNotEmpty
                  ? NetworkImage(member.profileImage)
                  : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
            ),
          ),
          const SizedBox(height: 16),
          Text(member.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          _buildInfoCard([
            _buildInfoTile(Icons.email_outlined, 'Email', member.email),
            _buildInfoTile(Icons.phone_outlined, 'Phone', member.phone),
            _buildInfoTile(Icons.location_on_outlined, 'Address', member.address),
            _buildInfoTile(Icons.bloodtype_outlined, 'Blood Group', member.bloodGroup),
            _buildInfoTile(Icons.work_outline, 'Profession', member.profession),
          ]),
        ],
      ),
    );
  }

  Widget _buildFinancialStatusTab(BuildContext context, Member member) {
    final planProvider = Provider.of<SubscriptionPlanProvider>(context);

    // --- পরিবর্তনটি এখানে ---
    SubscriptionPlan? plan;
    if (member.subscriptionPlanId != null && member.subscriptionPlanId!.isNotEmpty) {
      try {
        plan = planProvider.plans.firstWhere((p) => p.id == member.subscriptionPlanId);
      } catch (e) {
        plan = null; // যদি প্ল্যান খুঁজে না পাওয়া যায়
      }
    }
    // ----------------------

    if (plan == null) {
      return const Center(child: Text('No subscription plan assigned to this member.'));
    }

    int dueMonths = 0;
    if (member.paidUpTo != null && member.paidUpTo!.isNotEmpty) {
      final now = DateTime.now();
      final lastPaidParts = member.paidUpTo!.split('-');
      final lastPaidDate = DateTime(int.parse(lastPaidParts[0]), int.parse(lastPaidParts[1]));
      dueMonths = (now.year - lastPaidDate.year) * 12 + (now.month - lastPaidDate.month);
    } else {
      dueMonths = 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildInfoCard([
            _buildInfoTile(Icons.card_membership, 'Subscription Plan', plan.planName),
            _buildInfoTile(Icons.attach_money, 'Monthly Due', '৳${plan.amount.toStringAsFixed(0)}'),
            _buildInfoTile(Icons.event_available, 'Paid Up To', member.paidUpTo != null ? DateFormat('MMMM, yyyy').format(DateTime.parse('${member.paidUpTo}-01')) : 'N/A'),
            _buildInfoTile(Icons.error_outline, 'Current Dues', '$dueMonths month(s) pending', color: dueMonths > 0 ? Colors.red : Colors.green),
          ]),
        ],
      ),
    );
  }

  Widget _buildTransactionHistoryTab(BuildContext context, String memberId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('transactions').where('memberId', isEqualTo: memberId).orderBy('date', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No transaction history found.'));

        return ListView(
          padding: const EdgeInsets.all(8),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text('${data['type']} Payment - ৳${data['amount']}'),
                subtitle: Text('Paid on: ${DateFormat('dd MMM, yyyy').format((data['date'] as Timestamp).toDate())}'),
                trailing: Text('For: ${data['paymentForMonth']}'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Helper Widgets
  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String? subtitle, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(title),
      subtitle: Text(
        subtitle ?? 'Not set',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color ?? Colors.black87),
      ),
    );
  }
}