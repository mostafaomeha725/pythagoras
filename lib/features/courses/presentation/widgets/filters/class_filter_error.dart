import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';

class ClassFilterError extends StatelessWidget {
  const ClassFilterError({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ClassesCubit>().fetchClasses(),
      child: Container(
        height: 38.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.red, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          'إعادة المحاولة',
          style: font12w500.copyWith(color: Colors.red),
        ),
      ),
    );
  }
}
