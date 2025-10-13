class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String role;
  final String status;
  final String? phone;
  final String? address;
  final String? bloodGroup;
  final String? profession;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    required this.role,
    required this.status,
    this.phone,
    this.address,
    this.bloodGroup,
    this.profession,
  });
}