// lib/screens/member_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/member_model.dart';

class MemberDetailScreen extends StatelessWidget {
  final Member member;
  const MemberDetailScreen({required this.member, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(member.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero অ্যানিমেশনের জন্য এই 위জেটটি যোগ করা হয়েছে
              Hero(
                tag: member.id, // এই ট্যাগটি দুটি স্ক্রিনকে যুক্ত করে
                child: CircleAvatar(
                  radius: 80,
                  // ইন্টারনেট থেকে ছবি লোড করার সঠিক পদ্ধতি
                  backgroundImage: member.profileImage.isNotEmpty
                      ? NetworkImage(member.profileImage)
                      : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                member.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // তথ্যের জন্য সুন্দর UI
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined),
                        title: const Text('Email'),
                        subtitle: Text(member.email, style: const TextStyle(fontSize: 16)),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: const Text('Phone'),
                        subtitle: Text(member.phone, style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}