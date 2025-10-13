// lib/screens/add_edit_plan_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription_plan_model.dart';
import '../providers/subscription_plan_provider.dart';

class AddEditPlanScreen extends StatefulWidget {
  final SubscriptionPlan? plan;
  const AddEditPlanScreen({this.plan, super.key});

  @override
  State<AddEditPlanScreen> createState() => _AddEditPlanScreenState();
}

class _AddEditPlanScreenState extends State<AddEditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _planName;
  late double _amount;
  late String _description;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _planName = widget.plan?.planName ?? '';
    _amount = widget.plan?.amount ?? 0.0;
    _description = widget.plan?.description ?? '';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final planProvider =
    Provider.of<SubscriptionPlanProvider>(context, listen: false);

    final newPlan = SubscriptionPlan(
      id: widget.plan?.id ?? '',
      planName: _planName,
      amount: _amount,
      description: _description,
    );

    try {
      if (widget.plan == null) {
        await planProvider.addPlan(newPlan);
      } else {
        await planProvider.updatePlan(newPlan);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(widget.plan == null ? 'Add New Plan' : 'Edit Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _planName,
                  decoration: const InputDecoration(
                      labelText: 'Plan Name (e.g., Silver Member)',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter a plan name' : null,
                  onSaved: (v) => _planName = v!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue:
                  _amount == 0.0 ? '' : _amount.toStringAsFixed(0),
                  decoration: const InputDecoration(
                      labelText: 'Monthly Amount (BDT)',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter an amount';
                    if (double.tryParse(v) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(v) <= 0) {
                      return 'Amount must be greater than zero';
                    }
                    return null;
                  },
                  onSaved: (v) => _amount = double.parse(v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter a description'
                      : null,
                  onSaved: (v) => _description = v!,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                    child: Text(
                        widget.plan == null ? 'Create Plan' : 'Save Changes'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}