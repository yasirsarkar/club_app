import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get membersRef => _db.collection('members');

  Future<void> addMember(Member member) async {
    await membersRef.add(member.toMap());
  }

  Future<void> updateMember(Member member) async {
    await membersRef.doc(member.id).update(member.toMap());
  }

  Future<void> deleteMember(String id) async {
    await membersRef.doc(id).delete();
  }

  Stream<List<Member>> getMembers() {
    return membersRef.snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Member.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }
}
