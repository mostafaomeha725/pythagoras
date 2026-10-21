import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_state.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';

class IosRegisterClassDropdown extends StatefulWidget {
  final bool tabletLandscape;
  final ValueChanged<StudentClass?>? onChanged;

  const IosRegisterClassDropdown({
    super.key,
    this.tabletLandscape = false,
    this.onChanged,
  });

  @override
  State<IosRegisterClassDropdown> createState() =>
      _IosRegisterClassDropdownState();
}

class _IosRegisterClassDropdownState extends State<IosRegisterClassDropdown> {
  late final ValueNotifier<StudentClass?> _selectedClassNotifier;

  @override
  void initState() {
    super.initState();
    _selectedClassNotifier = ValueNotifier<StudentClass?>(
      context.read<IosRegisterCubit>().state.selectedClass,
    );
  }

  @override
  void dispose() {
    _selectedClassNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabletLandscape = widget.tabletLandscape;

    return BlocConsumer<IosRegisterCubit, IosRegisterState>(
      listenWhen: (previous, current) =>
          previous.selectedClass != current.selectedClass,
      listener: (context, state) {
        _selectedClassNotifier.value = state.selectedClass;
      },
      builder: (context, state) {
        if (state.selectedClass != null &&
            _selectedClassNotifier.value != state.selectedClass) {
          _selectedClassNotifier.value = state.selectedClass;
        }

        if (state.classesError != null && state.classes.isEmpty) {
          return InkWell(
            onTap: () => context.read<IosRegisterCubit>().loadClasses(),
            borderRadius: BorderRadius.circular(tabletLandscape ? 12 : 12.r),
            child: Container(
              height: tabletLandscape ? 60 : 54.h,
              padding: EdgeInsets.symmetric(
                horizontal: tabletLandscape ? 16 : 14.w,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(
                  tabletLandscape ? 12 : 12.r,
                ),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.refresh,
                    color: Colors.redAccent,
                    size: tabletLandscape ? 22 : 18.sp,
                  ),
                  SizedBox(width: tabletLandscape ? 10 : 8.w),
                  Expanded(
                    child: AppText(
                      "فشل تحميل الصفوف، اضغط لإعادة المحاولة",
                      style: font14w500.copyWith(color: Colors.redAccent),
                      alignment: AlignmentDirectional.centerStart,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final double buttonHeight = tabletLandscape ? 60.0 : 54.h;
        final double itemHeight = tabletLandscape ? 52.0 : 46.h;
        final double maxMenuHeight = tabletLandscape ? 280.0 : 260.h;
        final double menuHeight = state.classes.isEmpty
            ? (tabletLandscape ? 120.0 : 120.h)
            : (state.classes.length * itemHeight + 16.0).clamp(
                itemHeight + 16.0,
                maxMenuHeight,
              );
        final double dyOffset = buttonHeight + menuHeight + 8.0;

        return DropdownButtonHideUnderline(
          child: DropdownButton2<StudentClass>(
            isExpanded: true,
            hint: Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: const Color(0xFF6B7280),
                  size: tabletLandscape ? 22 : 18.sp,
                ),
                SizedBox(width: tabletLandscape ? 10 : 8.w),
                Expanded(
                  child: AppText(
                    state.isLoadingClasses
                        ? "جاري تحميل الصفوف..."
                        : "اختر الصف الدراسي",
                    style: tabletLandscape
                        ? font14w600.copyWith(color: Colors.grey, fontSize: 17)
                        : font14w500.copyWith(color: Colors.grey),
                    alignment: AlignmentDirectional.centerStart,
                  ),
                ),
              ],
            ),
            valueListenable: _selectedClassNotifier,
            selectedItemBuilder: (context) {
              return state.classes.map((studentClass) {
                return Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      color: AppLightColors.primary,
                      size: tabletLandscape ? 22 : 18.sp,
                    ),
                    SizedBox(width: tabletLandscape ? 10 : 8.w),
                    Expanded(
                      child: AppText(
                        studentClass.name,
                        style: tabletLandscape
                            ? font14w600.copyWith(
                                color: const Color(0xFF1E1E2D),
                                fontSize: 17,
                              )
                            : font14w500.copyWith(
                                color: const Color(0xFF1E1E2D),
                              ),
                        alignment: AlignmentDirectional.centerStart,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
            items: state.classes.map((studentClass) {
              return DropdownItem<StudentClass>(
                value: studentClass,
                height: itemHeight,
                child: AppText(
                  studentClass.name,
                  style: tabletLandscape
                      ? font14w600.copyWith(
                          color: const Color(0xFF1E1E2D),
                          fontSize: 17,
                        )
                      : font14w500.copyWith(color: const Color(0xFF1E1E2D)),
                  alignment: AlignmentDirectional.centerStart,
                ),
              );
            }).toList(),
            onChanged: state.isLoadingClasses
                ? null
                : (StudentClass? value) {
                    _selectedClassNotifier.value = value;
                    widget.onChanged?.call(value);
                    context.read<IosRegisterCubit>().selectClass(value);
                  },
            buttonStyleData: ButtonStyleData(
              height: buttonHeight,
              padding: EdgeInsets.symmetric(
                horizontal: tabletLandscape ? 16 : 14.w,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(
                  tabletLandscape ? 12 : 12.r,
                ),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
              ),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: const Color(0xFF6B7280),
                size: tabletLandscape ? 24 : 20.sp,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: maxMenuHeight,
              offset: Offset(0, dyOffset),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: EdgeInsets.symmetric(
                horizontal: tabletLandscape ? 16 : 14.w,
              ),
            ),
          ),
        );
      },
    );
  }
}
