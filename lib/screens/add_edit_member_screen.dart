// lib/screens/add_edit_member_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../models/member_model.dart';
import '../providers/member_provider.dart';
import '../providers/subscription_plan_provider.dart';

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
  String? _selectedPlanId;

  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      name = widget.member!.name;
      email = widget.member!.email;
      phone = widget.member!.phone;
      _imageUrl = widget.member!.profileImage;
      _selectedPlanId = widget.member!.subscriptionPlanId;
    } else {
      name = '';
      email = '';
      phone = '';
      _imageUrl = null;
      _selectedPlanId = null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    String finalImageUrl = _imageUrl ?? '';

    try {
      if (_imageFile != null) {
        final cloudinary = CloudinaryPublic('duxet36hm', 'club_app_uploads_image', cache: false);
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_imageFile!.path, resourceType: CloudinaryResourceType.Image),
        );
        finalImageUrl = response.secureUrl;
      }

      final member = Member(
        // --- সঠিক লাইন ---
        id: widget.member?.id ?? DateTime.now().toIso8601String(),
        name: name,
        email: email,
        phone: phone,
        profileImage: finalImageUrl,
        status: widget.member?.status ?? 'Approved',
        subscriptionPlanId: _selectedPlanId,
        address: widget.member?.address,
        bloodGroup: widget.member?.bloodGroup,
        profession: widget.member?.profession,
      );

      if (widget.member == null) {
        await memberProvider.addMember(member);
      } else {
        await memberProvider.updateMember(member);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<SubscriptionPlanProvider>(context, listen: false);
    final hintItem = DropdownMenuItem<String>(
      value: null,
      child: Text('No Plan / Unassigned', style: TextStyle(color: Colors.grey.shade600)),
    );
    final planItems = planProvider.plans.map((plan) {
      return DropdownMenuItem<String>(
        value: plan.id,
        child: Text('${plan.planName} (৳${plan.amount.toStringAsFixed(0)})'),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.member == null ? 'Add Member' : 'Edit Member')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider
                            : (_imageUrl != null && _imageUrl!.isNotEmpty
                            ? NetworkImage(_imageUrl!)
                            : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter a name';
                    if (value.trim().length < 3) return 'Name must be at least 3 characters long';
                    return null;
                  },
                  onSaved: (val) => name = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter an email';
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
                    return null;
                  },
                  onSaved: (val) => email = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: phone,
                  decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Please enter a phone number';
                    if (value.length != 11) return 'Phone number must be 11 digits';
                    if (int.tryParse(value) == null) return 'Please enter a valid phone number';
                    return null;
                  },
                  onSaved: (val) => phone = val!,
                ),
                const SizedBox(height: 16),
                if (planProvider.plans.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPlanId,
                    decoration: const InputDecoration(
                      labelText: 'Subscription Plan',
                      border: OutlineInputBorder(),
                    ),
                    items: [hintItem, ...planItems],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPlanId = newValue;
                      });
                    },
                    onSaved: (value) => _selectedPlanId = value,
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.member == null ? 'Add Member' : 'Save Changes'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}