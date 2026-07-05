import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String role;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.role = 'admin',
  });

  @override
  List<Object?> get props => [uid, email, name, photoUrl, role];
}
