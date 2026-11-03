import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String name;
  final String email;
  final String image;
  final String role;
  final String token;

  const User({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.image,
    required this.role,
    required this.token,
  });

  @override
  List<Object> get props => [id, username, name, email, image, role, token];
}
