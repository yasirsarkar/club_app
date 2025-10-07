import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member_model.dart';
import '../providers/member_provider.dart';
import 'add_edit_member_screen.dart';

class MemberListScreen extends StatelessWidget {
  const MemberListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              bool? added = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddEditMemberScreen(),
                ),
              );

              if (added == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Member added successfully')),
                );
              }
            },
          )
        ],
      ),
      body: memberProvider.members.isEmpty
          ? const Center(child: Text('No members yet.'))
          : ListView.builder(
        itemCount: memberProvider.members.length,
        itemBuilder: (context, index) {
          final member = memberProvider.members[index];

          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: member.profileImage.startsWith('assets/')
                    ? AssetImage(member.profileImage) as ImageProvider
                    : NetworkImage(member.profileImage),
              ),
              title: Text(member.name),
              subtitle: Text('${member.email}\n${member.phone}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      bool? updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditMemberScreen(member: member),
                        ),
                      );

                      if (updated == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Member updated successfully')),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: Text(
                              'Are you sure you want to delete ${member.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                memberProvider.deleteMember(member.id);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
