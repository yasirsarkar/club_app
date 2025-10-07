import 'package:flutter/material.dart';
import '../models/member_model.dart';

class MemberDetailScreen extends StatelessWidget {
  final Member member;
  const MemberDetailScreen({required this.member, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(member.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(member.profileImage),
            ),
            const SizedBox(height: 16),
            Text('Email: ${member.email}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Phone: ${member.phone}', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
