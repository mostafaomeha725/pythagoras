import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      selectedImage = File(image.path);
      emit(EditProfileImageSelected(selectedImage!));
    }
  }

  Future<void> saveChanges({required String name, String? password}) async {
    emit(EditProfileLoading());
    
    String? newImageUrl;
    
    // 1. Upload image if selected
    if (selectedImage != null) {
      final imageResult = await uploadProfilePictureUseCase(selectedImage!);
      imageResult.fold(
        (failure) {
          emit(EditProfileFailure(failure.message));
          return; // Stop execution if image upload fails
        },
        (url) {
          newImageUrl = url;
        },
      );
      if (state is EditProfileFailure) return;
    }

    // 2. Update profile data (name and optionally password)
    final updateResult = await updatePersonalProfileUseCase(name: name, password: password);
    
    updateResult.fold(
      (failure) => emit(EditProfileFailure(failure.message)),
      (userProfile) => emit(EditProfileSuccess(
        newProfilePictureUrl: newImageUrl,
        userProfile: userProfile,
      )),
    );
  }
}
