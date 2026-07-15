import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}