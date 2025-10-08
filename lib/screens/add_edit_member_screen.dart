import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
// নতুন ইম্পোর্ট
import 'package:cloudinary_public/cloudinary_public.dart';

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
    } else {
      name = '';
      email = '';
      phone = '';
      _imageUrl = null;
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    String finalImageUrl = _imageUrl ?? '';

    try {
      // যদি নতুন ছবি সিলেক্ট করা হয়, তবে Cloudinary-তে আপলোড হবে
      if (_imageFile != null) {
        print('Uploading new image to Cloudinary...');

        // Cloudinary সেটআপ: আপনার ড্যাশবোর্ডের তথ্য এখানে দিন
        final cloudinary = CloudinaryPublic('duxet36hm', 'club_app_uploads_image', cache: false);

        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_imageFile!.path, resourceType: CloudinaryResourceType.Image),
        );

        finalImageUrl = response.secureUrl; // নতুন URL পাওয়া
        print('Image uploaded. URL: $finalImageUrl');
      }

      final member = Member(
        id: widget.member?.id ?? DateTime.now().toIso8601String(),
        name: name,
        email: email,
        phone: phone,
        profileImage: finalImageUrl,
      );

      if (widget.member == null) {
        await memberProvider.addMember(member);
      } else {
        await memberProvider.updateMember(member);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      print('!!!!!!!!!! AN ERROR OCCURRED !!!!!!!!!!');
      print('ERROR DETAILS: $error');
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

  // UI কোডে কোনো পরিবর্তন নেই...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.member == null ? 'Add Member' : 'Edit Member')),
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
                            : const AssetImage('assets/profile_placeholder.png') as ImageProvider),
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
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Please enter a name' : null,
                  onSaved: (val) => name = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Please enter an email' : null,
                  onSaved: (val) => email = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: phone,
                  decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
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