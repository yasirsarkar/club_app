// lib/screens/add_edit_notice_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notice_model.dart';
import '../providers/notice_provider.dart';
import '../providers/auth_provider.dart';

class AddEditNoticeScreen extends StatefulWidget {
  final Notice? notice;
  const AddEditNoticeScreen({this.notice, super.key});

  @override
  State<AddEditNoticeScreen> createState() => _AddEditNoticeScreenState();
}

class _AddEditNoticeScreenState extends State<AddEditNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _details;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = widget.notice?.title ?? '';
    _details = widget.notice?.details ?? '';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final noticeProvider = Provider.of<NoticeProvider>(context, listen: false);
    final authorName = Provider.of<AuthProvider>(context, listen: false).user?.displayName ?? 'Admin';

    try {
      final newNotice = Notice(
        id: widget.notice?.id ?? '',
        title: _title,
        details: _details,
        authorName: authorName,
        timestamp: DateTime.now(),
      );
      if (widget.notice == null) {
        await noticeProvider.addNotice(newNotice);
      } else {
        await noticeProvider.updateNotice(newNotice);
      }
      if (mounted) Navigator.of(context).pop();
      if (widget.notice != null && mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.notice == null ? 'Post New Notice' : 'Edit Notice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'Notice Title', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
                  onSaved: (v) => _title = v!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _details,
                  decoration: const InputDecoration(labelText: 'Details', border: OutlineInputBorder(), alignLabelWithHint: true),
                  maxLines: 10,
                  validator: (v) => v!.isEmpty ? 'Please enter details' : null,
                  onSaved: (v) => _details = v!,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: Text(widget.notice == null ? 'Post Notice' : 'Save Changes'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}