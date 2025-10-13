// lib/screens/dues_collection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dues_provider.dart';
import '../providers/auth_provider.dart';
import '../models/member_due_status.dart';

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
              ? 'All dues are paid for this month!'
              : 'No payments recorded yet.'));
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final item = members[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(item.member.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Plan: ${item.plan.planName}'),
            trailing: isDueList
                ? ElevatedButton(
              onPressed: () {
                // কনফার্মেশন ডায়ালগ দেখানো হচ্ছে
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Payment'),
                      content: Text('Are you sure you want to record payment of ৳${item.plan.amount.toStringAsFixed(0)} for ${item.member.name}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            final currentUser = authProvider.user;
                            if (currentUser != null) {
                              Provider.of<DuesProvider>(context, listen: false).recordPayment(
                                item.member.id,
                                item.plan.amount,
                                currentUser.uid,
                              );
                            }
                            Navigator.pop(ctx);
                          },
                          child: const Text('Confirm'),
                        )
                      ],
                    ));
              },
              child: Text('Record ৳${item.plan.amount.toStringAsFixed(0)}'),
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