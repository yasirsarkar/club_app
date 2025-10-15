import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String status;
  // --- নতুন ফিল্ড ---
  final String? address;
  final String? bloodGroup;
  final String? profession;
  final String? subscriptionPlanId;
  final String? paidUpTo;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.status,
    this.address,
    this.bloodGroup,
    this.profession,
    this.subscriptionPlanId,
    this.paidUpTo,
  });

  factory Member.fromMap(String id, Map<String, dynamic> data) {
    return Member(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      status: data['status'] ?? 'Approved',
      address: data['address'],
      bloodGroup: data['bloodGroup'],
      profession: data['profession'],
      subscriptionPlanId: data['subscriptionPlanId'], // Map this field
      paidUpTo: data['paidUpTo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'status': status,
      'address': address,
      'bloodGroup': bloodGroup,
      'profession': profession,
      'subscriptionPlanId': subscriptionPlanId, // Map this field
      'paidUpTo': paidUpTo,
    };
  }
}