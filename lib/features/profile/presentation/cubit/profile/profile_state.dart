import 'package:equatable/equatable.dart';
import 'package:pythagoras/features/profile/domain/entities/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;

  const ProfileLoaded(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class ProfileFailure extends ProfileState {
  final String message;
  final bool isSessionExpired;

  const ProfileFailure(this.message, {this.isSessionExpired = false});

  @override
  List<Object?> get props => [message, isSessionExpired];
}
