class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage; // URL or asset path

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
  });

  factory Member.fromMap(String id, Map<String, dynamic> map) {
    return Member(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
    };
  }
}
