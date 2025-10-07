import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';

class MemberService {
  final CollectionReference _membersCollection =
  FirebaseFirestore.instance.collection('members');

  Stream<List<Member>> membersStream() {
    return _membersCollection.snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) =>
            Member.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addMember(Member member) async {
    await _membersCollection.doc(member.id).set(member.toMap());
  }

  Future<void> updateMember(Member member) async {
    await _membersCollection.doc(member.id).update(member.toMap());
  }

  Future<void> deleteMember(String id) async {
    await _membersCollection.doc(id).delete();
  }
}
