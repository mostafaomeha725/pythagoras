import 'dart:io';

import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileImageSelected extends EditProfileState {
  final File image;
  EditProfileImageSelected(this.image);
}

class EditProfileLoading extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final String? newProfilePictureUrl;
  final UserProfile? userProfile;
  EditProfileSuccess({this.newProfilePictureUrl, this.userProfile});
}

class EditProfileFailure extends EditProfileState {
  final String message;
  EditProfileFailure(this.message);
}
