import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/course_tablet_filter_pill_content.dart';

/// Class Filter Capsule Pill for Tablet Landscape.
/// Centers the text and down-chevron together, without large gaps.
class CourseTabletClassFilter extends StatefulWidget {
  const CourseTabletClassFilter({super.key});

  @override
  State<CourseTabletClassFilter> createState() =>
      _CourseTabletClassFilterState();
}

class _CourseTabletClassFilterState extends State<CourseTabletClassFilter> {
  @override
  void initState() {
    super.initState();
    final classesCubit = context.read<ClassesCubit>();
    if (classesCubit.state is ClassesInitial) {
      classesCubit.fetchClasses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassesCubit, ClassesState>(
      builder: (context, state) {
        List<StudentClass> classes = [];
        StudentClass? selectedClass;

        if (state is ClassesLoaded) {
          classes = state.classes;
          selectedClass = state.selectedClass;
        }

        final bool hasSelection =
            selectedClass != null && selectedClass.id != 0;
        final String displayText = selectedClass != null
            ? selectedClass.name
            : 'الصف الدراسي';

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
            child: DropdownButton<StudentClass>(
              isExpanded: true,
              isDense: true,
              padding: EdgeInsets.zero,
              alignment: AlignmentDirectional.center,
              menuMaxHeight: 350,
              menuWidth: 240,
              value: selectedClass,
              icon: const SizedBox.shrink(),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(16),
              hint: CourseTabletFilterPillContent(
                text: displayText,
                isHighlighted: hasSelection,
              ),
              selectedItemBuilder: (context) {
                return classes.map((c) {
                  return CourseTabletFilterPillContent(
                    text: c.name,
                    isHighlighted: c.id != 0,
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: AppText(
                        studentClass.name,
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
                  context.read<ClassesCubit>().selectClass(value);
                  context.read<CoursesListCubit>().updateFilters(
                    classId: value.id,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
