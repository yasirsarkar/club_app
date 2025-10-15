// lib/screens/payment_history_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Payment History'),
      ),
      body: user == null
          ? const Center(child: Text('You must be logged in to see history.'))
          : StreamBuilder<QuerySnapshot>(
        // শুধুমাত্র এই ব্যবহারকারীর লেনদেনগুলো আনা হচ্ছে
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('memberId', isEqualTo: user.uid)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('You have no payment history yet.'));
          }

          final transactions = snapshot.data!.docs;

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transData = transactions[index].data() as Map<String, dynamic>;
              final date = (transData['date'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd MMMM, yyyy').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                        transData['type'] == 'Subscription'
                            ? Icons.autorenew
                            : Icons.card_giftcard
                    ),
                  ),
                  title: Text(
                    '${transData['type'] ?? ''} Payment',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Paid on: $formattedDate\nFor month: ${transData['paymentForMonth'] ?? 'N/A'}',
                  ),
                  trailing: Text(
                    '৳ ${transData['amount']?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}