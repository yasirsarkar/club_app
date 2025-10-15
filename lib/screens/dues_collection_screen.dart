// lib/screens/dues_collection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dues_provider.dart';
import '../providers/auth_provider.dart';
import '../models/member_due_status.dart';
import 'record_payment_screen.dart'; // <-- নতুন স্ক্রিন ইম্পোর্ট করা হয়েছে

class DuesCollectionScreen extends StatefulWidget {
  const DuesCollectionScreen({super.key});

  @override
  State<DuesCollectionScreen> createState() => _DuesCollectionScreenState();
}

class _DuesCollectionScreenState extends State<DuesCollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duesProvider = Provider.of<DuesProvider>(context);
    final currentMonthYear = DateFormat('MMMM, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('Dues for $currentMonthYear'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Due (${duesProvider.unpaidMembers.length})'),
            Tab(text: 'Paid (${duesProvider.paidMembers.length})'),
          ],
        ),
      ),
      body: duesProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildMemberList(context, duesProvider.unpaidMembers, true),
          _buildMemberList(context, duesProvider.paidMembers, false),
        ],
      ),
    );
  }

  // --- এই ফাংশনটিতে পরিবর্তন আনা হয়েছে ---
  Widget _buildMemberList(
      BuildContext context, List<MemberWithDueStatus> members, bool isDueList) {
    if (members.isEmpty) {
      return Center(
          child: Text(isDueList
              ? 'No dues for this month!'
              : 'No payments recorded yet for this month.'));
    }

    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final item = members[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(item.member.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plan: ${item.plan.planName} (৳${item.plan.amount.toStringAsFixed(0)})'),
                if (item.member.paidUpTo != null && item.member.paidUpTo!.isNotEmpty)
                  Text('Paid up to: ${DateFormat('MMM, yyyy').format(DateTime.parse('${item.member.paidUpTo}-01'))}', style: const TextStyle(color: Colors.black54)),
              ],
            ),
            trailing: isDueList
                ? ElevatedButton(
              onPressed: () {
                // নতুন পেমেন্ট রেকর্ড স্ক্রিনে নেভিগেট করা
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RecordPaymentScreen(memberDueStatus: item),
                  ),
                );
              },
              child: const Text('Record Payment'),
            )
                : Text(
              'Paid on\n${DateFormat('dd/MM/yy').format(item.paymentDate!)}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}