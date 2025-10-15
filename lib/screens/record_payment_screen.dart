// lib/screens/record_payment_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/member_due_status.dart';
import '../providers/dues_provider.dart';
import '../providers/auth_provider.dart';

class RecordPaymentScreen extends StatefulWidget {
  final MemberWithDueStatus memberDueStatus;

  const RecordPaymentScreen({super.key, required this.memberDueStatus});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final List<String> _selectedMonths = [];
  bool _isLoading = false;

  late List<String> _availableMonths;
  late DateTime _lastPaidMonth;

  @override
  void initState() {
    super.initState();
    _calculateAvailableMonths();
  }

  void _calculateAvailableMonths() {
    _availableMonths = [];
    final now = DateTime.now();

    // paidUpTo ফরম্যাট "yyyy-MM"
    if (widget.memberDueStatus.member.paidUpTo != null && widget.memberDueStatus.member.paidUpTo!.isNotEmpty) {
      final parts = widget.memberDueStatus.member.paidUpTo!.split('-');
      _lastPaidMonth = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    } else {
      // যদি কোনো পেমেন্ট না থাকে, এক বছর আগে থেকে শুরু করা যেতে পারে
      _lastPaidMonth = DateTime(now.year - 1, now.month);
    }

    // শেষ পেমেন্টের পরের মাস থেকে শুরু করে আগামী ৬ মাস পর্যন্ত দেখানো হবে
    DateTime monthToDisplay = DateTime(_lastPaidMonth.year, _lastPaidMonth.month + 1);
    for (int i = 0; i < 12; i++) {
      _availableMonths.add(DateFormat('yyyy-MM').format(monthToDisplay));
      monthToDisplay = DateTime(monthToDisplay.year, monthToDisplay.month + 1);
    }
  }

  void _onMonthSelected(bool? selected, String month) {
    setState(() {
      if (selected == true) {
        _selectedMonths.add(month);
      } else {
        _selectedMonths.remove(month);
      }
    });
  }

  Future<void> _submitPayments() async {
    if (_selectedMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one month.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final duesProvider = Provider.of<DuesProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await duesProvider.recordMultiMonthPayment(
        widget.memberDueStatus.member.id,
        widget.memberDueStatus.plan.amount,
        _selectedMonths,
        authProvider.user!.uid,
      );
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to record payment: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _selectedMonths.length * widget.memberDueStatus.plan.amount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Record Payment for ${widget.memberDueStatus.member.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _availableMonths.length,
              itemBuilder: (context, index) {
                final month = _availableMonths[index];
                final isSelected = _selectedMonths.contains(month);

                final monthDate = DateTime.parse('${month}-01');
                final monthName = DateFormat('MMMM, yyyy').format(monthDate);

                return CheckboxListTile(
                  title: Text(monthName),
                  subtitle: Text('Amount: ৳${widget.memberDueStatus.plan.amount.toStringAsFixed(0)}'),
                  value: isSelected,
                  onChanged: (selected) => _onMonthSelected(selected, month),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Selected:', style: TextStyle(fontSize: 16)),
                    Text(
                      '৳${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _submitPayments,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  child: const Text('Confirm Payment'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}