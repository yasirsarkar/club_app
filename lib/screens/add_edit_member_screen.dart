// member_add_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member_model.dart';
import '../providers/member_provider.dart';

class AddEditMemberScreen extends StatefulWidget {
  final Member? member;
  const AddEditMemberScreen({this.member, super.key});

  @override
  State<AddEditMemberScreen> createState() => _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends State<AddEditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String email;
  late String phone;
  late String profileImage;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      name = widget.member!.name;
      email = widget.member!.email;
      phone = widget.member!.phone;
      profileImage = widget.member!.profileImage;
    } else {
      name = '';
      email = '';
      phone = '';
      profileImage = 'assets/profile1.png';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final memberProvider = Provider.of<MemberProvider>(context, listen: false);

    print('Form submitted. Preparing to write to Firestore...'); // Debug Message

    try {
      final member = Member(
        id: widget.member?.id ?? DateTime.now().toIso8601String(),
        name: name,
        email: email,
        phone: phone,
        profileImage: profileImage,
      );

      if (widget.member == null) {
        print('Calling addMember...'); // Debug Message
        await memberProvider.addMember(member);
      } else {
        print('Calling updateMember...'); // Debug Message
        await memberProvider.updateMember(member);
      }

      print('Firestore write successful! Now popping the page.'); // Debug Message
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      // Any error will be caught here
      print('!!!!!!!!!! AN ERROR OCCURRED !!!!!!!!!!'); // Debug Message
      print('ERROR DETAILS: $error'); // Debug Message

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.member == null ? 'Add Member' : 'Edit Member')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow
            child: Column(
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Please enter a name' : null,
                  onSaved: (val) => name = val!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Please enter an email' : null,
                  onSaved: (val) => email = val!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Please enter a phone number' : null,
                  onSaved: (val) => phone = val!,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.member == null ? 'Add Member' : 'Update Member'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}