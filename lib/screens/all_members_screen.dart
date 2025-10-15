// lib/screens/all_members_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member_model.dart';
import '../providers/auth_provider.dart';
import '../providers/member_provider.dart';
import 'add_edit_member_screen.dart';
import 'member_detail_screen.dart';

// --- виджетটিকে StatefulWidget-এ পরিবর্তন করা হয়েছে ---
class AllMembersScreen extends StatefulWidget {
  const AllMembersScreen({super.key});

  @override
  State<AllMembersScreen> createState() => _AllMembersScreenState();
}

class _AllMembersScreenState extends State<AllMembersScreen> {
  // --- সার্চের জন্য নতুন ভ্যারিয়েবল ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context);
    final bool isAdmin = authProvider.user?.role == 'Admin';

    // --- রিয়েল-টাইম ফিল্টারিং-এর যুক্তি ---
    final List<Member> allMembers = memberProvider.members;
    final List<Member> filteredMembers = _searchQuery.isEmpty
        ? allMembers
        : allMembers.where((member) {
      final query = _searchQuery.toLowerCase();
      return member.name.toLowerCase().contains(query) ||
          member.email.toLowerCase().contains(query) ||
          member.phone.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Members'),
      ),
      body: Column(
        children: [
          // --- নতুন সার্চ বার UI ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
              ),
            ),
          ),
          // --- সদস্যদের তালিকা ---
          Expanded(
            child: filteredMembers.isEmpty
                ? const Center(child: Text('No members found.'))
                : ListView.builder(
              padding: const EdgeInsets.only(top: 8.0),
              itemCount: filteredMembers.length,
              itemBuilder: (context, index) {
                final member = filteredMembers[index];
                // ListTile-এর কোড অপরিবর্তিত
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemberDetailScreen(member: member),
                        ),
                      );
                    },
                    leading: Hero(
                      tag: member.id,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: member.profileImage.isNotEmpty
                            ? NetworkImage(member.profileImage)
                            : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${member.email}\n${member.phone}'),
                    isThreeLine: true,
                    trailing: isAdmin
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'Edit Member',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditMemberScreen(member: member),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            member.status == 'Approved' ? Icons.pause_circle_outline : Icons.play_circle_outline,
                            color: member.status == 'Approved' ? Colors.orange : Colors.green,
                          ),
                          tooltip: member.status == 'Approved' ? 'Suspend Member' : 'Unsuspend Member',
                          onPressed: () {
                            // ... আপনার সাসপেন্ড/আন-সাসপেন্ড করার সম্পূর্ণ কোড ...
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Member',
                          onPressed: () {
                            // ... আপনার ডিলিট করার সম্পূর্ণ কোড ...
                          },
                        ),
                      ],
                    )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditMemberScreen()),
          );
        },
      )
          : null,
    );
  }
}

// Helper এক্সটেনশন যা String-কে capitalize করে
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}