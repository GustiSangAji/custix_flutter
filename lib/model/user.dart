class User {
  final int id;
  final String uuid;
  final String nama;
  final String email;
  final String phone;
  final String photo;
  final bool confirmed;
  final DateTime emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> permission;
  final Role role;

  User({
    required this.id,
    required this.uuid,
    required this.nama,
    required this.email,
    required this.phone,
    required this.photo,
    required this.confirmed,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.permission,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      uuid: json['uuid'],
      nama: json['nama'],
      email: json['email'],
      phone: json['phone'],
      photo: json['photo'],
      confirmed: json['confirmed'] == 1,
      emailVerifiedAt: DateTime.parse(json['email_verified_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      permission: List<String>.from(json['permission']),
      role: Role.fromJson(json['role']),
    );
  }
}

class Role {
  final int id;
  final String name;
  final String fullName;

  Role({
    required this.id,
    required this.name,
    required this.fullName,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      fullName: json['full_name'],
    );
  }
}