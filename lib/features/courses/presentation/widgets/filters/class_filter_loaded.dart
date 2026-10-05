import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';

class ClassFilterLoaded extends StatelessWidget {
  final List<StudentClass> classes;
  final StudentClass? selectedClass;

  const ClassFilterLoaded({
    super.key,
    required this.classes,
    this.selectedClass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<StudentClass>(
          isExpanded: true,
          isDense: true,
          value: selectedClass,
          icon: const SizedBox.shrink(), // Hide default icon
          dropdownColor: Colors.white,
          menuMaxHeight: 350.h,
          itemHeight: null, // Allow items to have dynamic height for multiline text
          borderRadius: BorderRadius.circular(16.r),
          hint: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF6B7280), // Grey icon
                size: 20.sp,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AppText(
                    'الصف الدراسي',
                    style: font14w600.copyWith(
                      color: const Color(0xFF1E1E2D),
                    ),
                  ),
                ),
              ),
            ],
          ),
          selectedItemBuilder: (context) {
            return classes.map((studentClass) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF6B7280), // Grey icon
                    size: 20.sp,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: AppText(
                        studentClass.name,
                        style: font14w600.copyWith(
                          color: const Color(0xFF1E1E2D),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: classes.map((studentClass) {
            final isSelected = selectedClass?.id == studentClass.id;
            return DropdownMenuItem<StudentClass>(
              value: studentClass,
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(
                  vertical: 10.h,
                  horizontal: 12.w,
                ),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: AppText(
                  studentClass.name,
                  style: font12w700.copyWith(
                    color: isSelected
                        ? const Color(0xFF4B5563) // Dark grey text
                        : const Color(0xFF1E1E2D),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<ClassesCubit>().selectClass(value);
              context.read<CoursesListCubit>().updateFilters(classId: value.id);
            }
          },
        ),
      ),
    );
  }
}
