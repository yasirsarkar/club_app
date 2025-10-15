// lib/screens/notice_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/notice_provider.dart';
import '../providers/auth_provider.dart';
import 'notice_detail_screen.dart';
import 'add_edit_notice_screen.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noticeProvider = Provider.of<NoticeProvider>(context);
    final bool isAdmin = Provider.of<AuthProvider>(context, listen: false).user?.role == 'Admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Notice Board')),
      body: noticeProvider.notices.isEmpty
          ? const Center(child: Text('No notices found.'))
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: noticeProvider.notices.length,
        itemBuilder: (context, index) {
          final notice = noticeProvider.notices[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(notice.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Posted on: ${DateFormat('dd MMMM, yyyy').format(notice.timestamp)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoticeDetailScreen(notice: notice))),
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditNoticeScreen())),
        child: const Icon(Icons.add),
        tooltip: 'Post New Notice',
      )
          : null,
    );
  }
}