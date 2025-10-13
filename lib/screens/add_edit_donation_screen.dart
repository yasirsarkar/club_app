// lib/screens/add_edit_donation_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/donation_model.dart';
import '../providers/donation_provider.dart';
import '../providers/auth_provider.dart';

class AddEditDonationScreen extends StatefulWidget {
  final Donation? donation;
  const AddEditDonationScreen({this.donation, super.key});

  @override
  State<AddEditDonationScreen> createState() => _AddEditDonationScreenState();
}

class _AddEditDonationScreenState extends State<AddEditDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _donorName;
  late double _amount;
  late DateTime _date;
  String? _note;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.donation != null) {
      // Edit mode
      _donorName = widget.donation!.donorName;
      _amount = widget.donation!.amount;
      _date = widget.donation!.date;
      _note = widget.donation!.note;
    } else {
      // Add mode
      _donorName = '';
      _amount = 0.0;
      _date = DateTime.now();
      _note = null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recordedByUid = authProvider.user?.uid ?? 'unknown_admin';

    final donationProvider = Provider.of<DonationProvider>(context, listen: false);

    try {
      if (widget.donation == null) {
        // Add new donation
        final newDonation = Donation(
          id: '', // Firestore will generate this
          donorName: _donorName,
          amount: _amount,
          date: _date,
          note: _note,
          recordedByUid: recordedByUid,
        );
        await donationProvider.addDonation(newDonation);
      } else {
        // Update existing donation
        final updatedDonation = Donation(
          id: widget.donation!.id,
          donorName: _donorName,
          amount: _amount,
          date: _date,
          note: _note,
          recordedByUid: widget.donation!.recordedByUid, // Keep original recorder
        );
        await donationProvider.updateDonation(updatedDonation);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Operation Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.donation == null ? 'Add Donation' : 'Edit Donation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _donorName,
                  decoration: const InputDecoration(labelText: 'Donor Name', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a donor name' : null,
                  onSaved: (v) => _donorName = v!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _amount == 0.0 ? '' : _amount.toStringAsFixed(0),
                  decoration: const InputDecoration(labelText: 'Amount (BDT)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter an amount';
                    if (double.tryParse(v) == null) return 'Please enter a valid number';
                    if (double.parse(v) <= 0) return 'Amount must be greater than zero';
                    return null;
                  },
                  onSaved: (v) => _amount = double.parse(v!),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4)
                  ),
                  child: ListTile(
                    title: Text('Date: ${DateFormat('dd MMMM, yyyy').format(_date)}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _note,
                  decoration: const InputDecoration(labelText: 'Note (Optional)', border: OutlineInputBorder()),
                  maxLines: 3,
                  onSaved: (v) => _note = v,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.donation == null ? 'Add Donation' : 'Save Changes'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}