import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.countryCode,
    super.profilePictureUrl,
    required super.type,
    required super.role,
    super.classId,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      type: json['type'] as String? ?? '',
      role: json['role'] as String? ?? '',
      classId: json['class_id'] as int?,
    );
  }
}
