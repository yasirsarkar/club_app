enum Role { admin, committee, member }

class UserModel {
  final String id;
  final String name;
  final String email;
  final Role role;

  UserModel({required this.id, required this.name, required this.email, required this.role});
}
