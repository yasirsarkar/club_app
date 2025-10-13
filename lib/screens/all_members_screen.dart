import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member_model.dart';
import '../providers/auth_provider.dart';
import '../providers/member_provider.dart';
import 'add_edit_member_screen.dart';
import 'member_detail_screen.dart';

class AllMembersScreen extends StatelessWidget {
  const AllMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context);
    final bool isAdmin = authProvider.user?.role == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Members'),
      ),
      body: memberProvider.members.isEmpty
          ? const Center(child: Text('No members found.'))
          : ListView.builder(
              itemCount: memberProvider.members.length,
              itemBuilder: (context, index) {
                final member = memberProvider.members[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MemberDetailScreen(member: member),
                        ),
                      );
                    },
                    leading: Hero(
                      tag: member.id,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: member.profileImage.isNotEmpty
                            ? NetworkImage(member.profileImage)
                            : const AssetImage(
                                    'assets/images/profile_placeholder.png')
                                as ImageProvider,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    title: Text(member.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                      builder: (_) =>
                                          AddEditMemberScreen(member: member),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  member.status == 'Approved'
                                      ? Icons.pause_circle_outline
                                      : Icons.play_circle_outline,
                                  color: member.status == 'Approved'
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                tooltip: member.status == 'Approved'
                                    ? 'Suspend Member'
                                    : 'Unsuspend Member',
                                onPressed: () {
                                  final newStatus = member.status == 'Approved'
                                      ? 'Suspended'
                                      : 'Approved';
                                  final actionText = newStatus == 'Suspended'
                                      ? 'suspend'
                                      : 'approve';

                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Confirm ${actionText.capitalize()}'),
                                      content: Text(
                                          'Are you sure you want to $actionText ${member.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final scaffoldMessenger =
                                                ScaffoldMessenger.of(context);
                                            final navigator = Navigator.of(ctx);
                                            try {
                                              final firestore =
                                                  FirebaseFirestore.instance;
                                              final batch = firestore.batch();
                                              batch.update(
                                                  firestore
                                                      .collection('users')
                                                      .doc(member.id),
                                                  {'status': newStatus});
                                              batch.update(
                                                  firestore
                                                      .collection('members')
                                                      .doc(member.id),
                                                  {'status': newStatus});
                                              await batch.commit();
                                              navigator.pop();
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '${member.name} has been ${actionText}d.'),
                                                ),
                                              );
                                            } catch (e) {
                                              navigator.pop();
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to $actionText member: $e')),
                                              );
                                            }
                                          },
                                          child: Text(
                                            actionText.capitalize(),
                                            style: TextStyle(
                                                color: actionText == 'suspend'
                                                    ? Colors.orange
                                                    : Colors.green),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              // --- Delete Button (Updated) ---
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete Member',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: Text(
                                          'Are you sure you want to delete ${member.name}? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final scaffoldMessenger =
                                                ScaffoldMessenger.of(context);
                                            final navigator = Navigator.of(ctx);
                                            try {
                                              final firestore =
                                                  FirebaseFirestore.instance;
                                              final batch = firestore.batch();
                                              batch.delete(firestore
                                                  .collection('users')
                                                  .doc(member.id));
                                              batch.delete(firestore
                                                  .collection('members')
                                                  .doc(member.id));
                                              await batch.commit();
                                              navigator.pop();
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        '${member.name} has been deleted.')),
                                              );
                                            } catch (e) {
                                              navigator.pop();
                                              scaffoldMessenger.showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to delete member: $e')),
                                              );
                                            }
                                          },
                                          child: const Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
