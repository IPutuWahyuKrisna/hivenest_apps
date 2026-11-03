import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.email,
    required super.image,
    required super.role,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        username: json['username'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        image: json['image'] as String? ?? '',
        role: json['role'] as String? ?? '',
        token: json['token'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'email': email,
        'image': image,
        'role': role,
        'token': token,
      };
}
