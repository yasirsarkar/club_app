import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberApprovalScreen extends StatelessWidget {
  const MemberApprovalScreen({super.key});

  Future<void> _approveUser(String uid, Map<String, dynamic> userData) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    final userRef = firestore.collection('users').doc(uid);
    batch.update(userRef, {'status': 'Approved'});

    final memberRef = firestore.collection('members').doc(uid);
    batch.set(memberRef, {
      'id': uid,
      'name': userData['displayName'] ?? 'No Name Provided',
      'email': userData['email'] ?? 'No Email Provided',
      'phone': '',
      'profileImage': userData['photoURL'] ?? '',
      'status': 'Approved',
      'address': '',
      'bloodGroup': '',
      'profession': '',
    });

    await batch.commit();
    print('User $uid approved and added to members list.');
  }

  void _rejectUser(String uid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'status': 'Rejected'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('status', isEqualTo: 'Pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending applications found.'));
          }

          final pendingUsers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pendingUsers.length,
            itemBuilder: (context, index) {
              final userDoc = pendingUsers[index];
              final userData = userDoc.data() as Map<String, dynamic>;
              final String userName = userData['displayName'] ?? 'No Name';
              final String userEmail = userData['email'] ?? 'No Email';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(userEmail),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _approveUser(userDoc.id, userData);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          _rejectUser(userDoc.id);
                        },
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Reject'),
                      ),
                    ],
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