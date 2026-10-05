import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String countryCode;
  final String? profilePictureUrl;
  final String type;
  final String role;
  final int? classId;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.countryCode,
    this.profilePictureUrl,
    required this.type,
    required this.role,
    this.classId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        countryCode,
        profilePictureUrl,
        type,
        role,
        classId,
      ];
}
