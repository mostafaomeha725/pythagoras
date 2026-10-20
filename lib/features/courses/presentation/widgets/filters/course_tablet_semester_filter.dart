import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/semester_option.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/course_tablet_filter_pill_content.dart';

/// Semester Filter Capsule Pill for Tablet Landscape.
/// Centers the label and down-chevron together, matching class filter styling.
class CourseTabletSemesterFilter extends StatefulWidget {
  const CourseTabletSemesterFilter({super.key});

  @override
  State<CourseTabletSemesterFilter> createState() =>
      _CourseTabletSemesterFilterState();
}

class _CourseTabletSemesterFilterState
    extends State<CourseTabletSemesterFilter> {
  final List<SemesterOption> semesters = const [
    SemesterOption(id: 0, name: 'الكل'),
    SemesterOption(id: 1, name: 'الفصل الدراسي الأول'),
    SemesterOption(id: 2, name: 'الفصل الدراسي الثاني'),
  ];

  SemesterOption? selectedSemester;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection =
        selectedSemester != null && selectedSemester!.id != 0;
    final String displayText = selectedSemester != null
        ? selectedSemester!.name
        : 'الفصل الدراسي';

    return Container(
      width: 225,
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: hasSelection
              ? const Color(0xFF832561).withValues(alpha: 0.5)
              : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SemesterOption>(
          isExpanded: true,
          isDense: true,
          padding: EdgeInsets.zero,
          alignment: AlignmentDirectional.center,
          menuMaxHeight: 350,
          menuWidth: 200,
          value: selectedSemester,
          icon: const SizedBox.shrink(),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          hint: CourseTabletFilterPillContent(
            text: displayText,
            isHighlighted: hasSelection,
          ),
          selectedItemBuilder: (context) {
            return semesters.map((s) {
              return CourseTabletFilterPillContent(
                text: s.name,
                isHighlighted: s.id != 0,
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
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: AppText(
                    semester.name,
                    style: font14w600.copyWith(
                      color: isSelected
                          ? const Color(0xFF832561)
                          : const Color(0xFF1E1E2D),
                      fontSize: 13.5,
                    ),
                    alignment: AlignmentDirectional.centerStart,
                    textAlign: TextAlign.right,
                  ),
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
