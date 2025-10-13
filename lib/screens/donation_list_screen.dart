// lib/screens/donation_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/donation_provider.dart';
import 'add_edit_donation_screen.dart';
import 'package:intl/intl.dart'; // তারিখ ফরম্যাট করার জন্য

class DonationListScreen extends StatelessWidget {
  const DonationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donationProvider = Provider.of<DonationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Management'),
      ),
      body: donationProvider.donations.isEmpty
          ? const Center(child: Text('No donations recorded yet.'))
          : ListView.builder(
        itemCount: donationProvider.donations.length,
        itemBuilder: (context, index) {
          final donation = donationProvider.donations[index];
          // তারিখটিকে সুন্দরভাবে দেখানোর জন্য ফরম্যাট করা
          final formattedDate = DateFormat('dd MMM, yyyy').format(donation.date);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                donation.donorName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Date: $formattedDate'),
                  if (donation.note != null && donation.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('Note: ${donation.note}'),
                    ),
                ],
              ),
              trailing: Text(
                '৳ ${donation.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditDonationScreen(donation: donation),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditDonationScreen()),
        ),
        child: const Icon(Icons.add),
        tooltip: 'Add Donation',
      ),
    );
  }
}