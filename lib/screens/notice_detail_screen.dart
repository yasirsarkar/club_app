// lib/screens/notice_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/notice_model.dart';
import '../providers/notice_provider.dart';
import '../providers/auth_provider.dart';
import 'add_edit_notice_screen.dart';

class NoticeDetailScreen extends StatelessWidget {
  final Notice notice;
  const NoticeDetailScreen({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = Provider.of<AuthProvider>(context, listen: false).user?.role == 'Admin';
    final formattedDate = DateFormat('dd MMMM, yyyy - hh:mm a').format(notice.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice Details'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditNoticeScreen(notice: notice))),
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Are you sure you want to delete this notice?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Provider.of<NoticeProvider>(context, listen: false).deleteNotice(notice.id);
                          Navigator.pop(ctx); // Close dialog
                          Navigator.pop(context); // Go back from detail screen
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notice.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Posted by ${notice.authorName} on $formattedDate', style: const TextStyle(color: Colors.grey)),
            const Divider(height: 32),
            Text(notice.details, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}