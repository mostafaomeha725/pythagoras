import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/domain/entities/semester_option.dart';

class SemesterFilterDropdown extends StatefulWidget {
  const SemesterFilterDropdown({super.key});

  @override
  State<SemesterFilterDropdown> createState() => _SemesterFilterDropdownState();
}

class _SemesterFilterDropdownState extends State<SemesterFilterDropdown> {
  final List<SemesterOption> semesters = const [
    SemesterOption(id: 0, name: 'الكل'),
    SemesterOption(id: 1, name: 'الفصل الدراسي الأول'),
    SemesterOption(id: 2, name: 'الفصل الدراسي الثاني'),
  ];

  SemesterOption? selectedSemester;

  @override
  void initState() {
    super.initState();
    selectedSemester = null; // Default is null to show "الفصل الدراسي"
  }

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
        child: DropdownButton<SemesterOption>(
          isExpanded: true,
          isDense: true,
          alignment: AlignmentDirectional.center,
          style: font14w600.copyWith(color: const Color(0xFF1E1E2D)),
          value: selectedSemester,
          icon: const SizedBox.shrink(), // Hide default icon
          dropdownColor: Colors.white,
          menuMaxHeight: 350.h,
          itemHeight:
              null, // Allow items to have dynamic height for multiline text
          borderRadius: BorderRadius.circular(16.r),
          hint: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF6B7280), // Grey icon
                    size: 20.sp,
                  ),
                  SizedBox(width: 6.w),
                  AppText(
                    'الفصل الدراسي',
                    style: font14w600.copyWith(color: const Color(0xFF1E1E2D)),
                  ),
                ],
              ),
            ),
          ),
          selectedItemBuilder: (context) {
            return semesters.map((semester) {
              return Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF6B7280), // Grey icon
                        size: 20.sp,
                      ),
                      SizedBox(width: 6.w),
                      AppText(
                        semester.name,
                        style: font14w600.copyWith(
                          color: const Color(0xFF1E1E2D),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          items: semesters.map((semester) {
            final isSelected = selectedSemester?.id == semester.id;
            return DropdownMenuItem<SemesterOption>(
              value: semester,
              child: Container(
                width: double.infinity,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: AppText(
                  semester.name,
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
              setState(() {
                selectedSemester = value;
              });
              context.read<CoursesListCubit>().updateFilters(
                semester: value.id,
              );
            }
          },
        ),
      ),
    );
  }
}
