import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/profile/domain/usecases/update_personal_profile_use_case.dart';
import 'package:pythagoras/features/profile/domain/usecases/upload_profile_picture_use_case.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UploadProfilePictureUseCase uploadProfilePictureUseCase;
  final UpdatePersonalProfileUseCase updatePersonalProfileUseCase;
  File? selectedImage;

  EditProfileCubit(
    this.uploadProfilePictureUseCase,
    this.updatePersonalProfileUseCase,
  ) : super(EditProfileInitial());

  Future<void> saveChanges({required String name, String? password}) async {
    emit(EditProfileLoading());

    // Update profile data (name and optionally password)
    final updateResult = await updatePersonalProfileUseCase(
      name: name,
      password: password,
    );

    updateResult.fold(
      (failure) => emit(EditProfileFailure(failure.message)),
      (userProfile) => emit(EditProfileSuccess(
        userProfile: userProfile,
      )),
    );
  }
}
