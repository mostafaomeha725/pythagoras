import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/features/profile/presentation/cubit/edit_profile/edit_profile_cubit.dart';
import 'package:pythagoras/features/profile/presentation/cubit/edit_profile/edit_profile_state.dart';

class EditProfileAvatar extends StatelessWidget {
  final String? profilePictureUrl;

  const EditProfileAvatar({super.key, this.profilePictureUrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileCubit, EditProfileState>(
      builder: (context, state) {
        final cubit = context.read<EditProfileCubit>();
        final selectedImage = cubit.selectedImage;

        return Center(
          child: Stack(
            children: [
              Container(
                width: 110.w,
                height: 110.h,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppLightColors.primary,
                    width: 2.5,
                  ),
                ),
                child: Container(
                  width: 110.w,
                  height: 110.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF9FAFB),
                  ),
                  child: ClipOval(
                    child: selectedImage != null
                        ? Image.file(
                            selectedImage,
                            fit: BoxFit.cover,
                          )
                        : (profilePictureUrl != null && profilePictureUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: profilePictureUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Center(
                                  child: Text('👨‍🎓', style: TextStyle(fontSize: 50.sp)),
                                ),
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                      color: AppLightColors.primary, strokeWidth: 2.w),
                                ),
                              )
                            : Center(
                                child: Text('👨‍🎓', style: TextStyle(fontSize: 50.sp)),
                              ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => cubit.pickImage(),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                      color: AppLightColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

