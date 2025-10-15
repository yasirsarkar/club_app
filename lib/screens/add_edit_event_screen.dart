// lib/screens/add_edit_event_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import '../providers/auth_provider.dart';

class AddEditEventScreen extends StatefulWidget {
  final EventModel? event;
  const AddEditEventScreen({this.event, super.key});

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String _title;
  late String _description;
  late String _location;
  late double _registrationFee;
  late DateTime _eventDate;
  File? _imageFile;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) { // Edit mode
      _title = widget.event!.title;
      _description = widget.event!.description;
      _location = widget.event!.location;
      _registrationFee = widget.event!.registrationFee;
      _eventDate = widget.event!.eventDate;
      _imageUrl = widget.event!.imageUrl;
    } else { // Add mode
      _title = '';
      _description = '';
      _location = '';
      _registrationFee = 0.0;
      _eventDate = DateTime.now();
      _imageUrl = null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDate),
    );
    if (time == null) return;

    setState(() {
      _eventDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    String finalImageUrl = _imageUrl ?? '';
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_imageFile != null) {
        final cloudinary = CloudinaryPublic('duxet36hm', 'club_app_uploads_image', cache: false);
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_imageFile!.path, resourceType: CloudinaryResourceType.Image),
        );
        finalImageUrl = response.secureUrl;
      }

      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      final event = EventModel(
        id: widget.event?.id ?? '',
        title: _title,
        description: _description,
        imageUrl: finalImageUrl,
        eventDate: _eventDate,
        location: _location,
        registrationFee: _registrationFee,
        createdBy: authProvider.user!.uid,
      );

      if (widget.event == null) {
        await eventProvider.addEvent(event);
      } else {
        await eventProvider.updateEvent(event);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'Create New Event' : 'Edit Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker UI
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : (_imageUrl != null && _imageUrl!.isNotEmpty
                      ? Image.network(_imageUrl!, fit: BoxFit.cover)
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to add a banner image'),
                    ],
                  )),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Event Title', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
                onSaved: (v) => _title = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), alignLabelWithHint: true),
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'Please enter details' : null,
                onSaved: (v) => _description = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Please enter a location' : null,
                onSaved: (v) => _location = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _registrationFee == 0.0 ? '' : _registrationFee.toStringAsFixed(0),
                decoration: const InputDecoration(labelText: 'Registration Fee (0 for free)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (v) => _registrationFee = double.tryParse(v!) ?? 0.0,
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListTile(
                  title: Text('Date & Time: ${DateFormat('dd MMM, yyyy - hh:mm a').format(_eventDate)}'),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: _pickDateTime,
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: Text(widget.event == null ? 'Create Event' : 'Save Changes'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}