// lib/screens/my_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isEditMode = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form fields' controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _professionController;
  late TextEditingController _bloodGroupController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _professionController = TextEditingController(text: user?.profession ?? '');
    _bloodGroupController = TextEditingController(text: user?.bloodGroup ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _professionController.dispose();
    _bloodGroupController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final dataToUpdate = {
      'displayName': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'profession': _professionController.text.trim(),
      'bloodGroup': _bloodGroupController.text.trim(),
    };

    try {
      await Provider.of<AuthProvider>(context, listen: false).updateUserProfile(dataToUpdate);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
      );
      setState(() => _isEditMode = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('User not found.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Edit এবং Save বাটন পরিবর্তন হবে
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditMode ? Icons.save : Icons.edit),
              tooltip: _isEditMode ? 'Save Changes' : 'Edit Profile',
              onPressed: () {
                if (_isEditMode) {
                  _saveProfile();
                } else {
                  setState(() => _isEditMode = true);
                }
              },
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // প্রোফাইল ছবি ও নাম
              CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage('assets/images/profile_placeholder.png'), // TODO: Use user's actual image
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 16),
              _isEditMode
                  ? TextFormField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
                decoration: const InputDecoration(border: InputBorder.none),
                validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
              )
                  : Text(user.displayName ?? '', style: Theme.of(context).textTheme.headlineSmall),
              Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // বিস্তারিত তথ্য
              _buildProfileInfoTile(
                icon: Icons.phone_outlined,
                title: 'Phone',
                value: user.phone,
                controller: _phoneController,
                isEditMode: _isEditMode,
                validator: (v) => v!.isEmpty || v.length < 11 ? 'Enter a valid phone number' : null,
              ),
              _buildProfileInfoTile(
                icon: Icons.location_on_outlined,
                title: 'Address',
                value: user.address,
                controller: _addressController,
                isEditMode: _isEditMode,
                validator: (v) => v!.isEmpty ? 'Enter your address' : null,
              ),
              _buildProfileInfoTile(
                icon: Icons.bloodtype_outlined,
                title: 'Blood Group',
                value: user.bloodGroup,
                controller: _bloodGroupController,
                isEditMode: _isEditMode,
                validator: (v) => v!.isEmpty ? 'Enter your blood group' : null,
              ),
              _buildProfileInfoTile(
                icon: Icons.work_outline,
                title: 'Profession',
                value: user.profession,
                controller: _professionController,
                isEditMode: _isEditMode,
                validator: (v) => v!.isEmpty ? 'Enter your profession' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // একটি Helper Widget যা প্রতিটি তথ্য সুন্দরভাবে দেখায়
  Widget _buildProfileInfoTile({
    required IconData icon,
    required String title,
    required String? value,
    required TextEditingController controller,
    required bool isEditMode,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: isEditMode
          ? TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      )
          : ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(
          value ?? 'Not set',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}