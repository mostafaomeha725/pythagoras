import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/core/utils/validators.dart';
import 'package:pythagoras/features/auth/domain/usecases/register_use_case.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_classes_use_case.dart';

import 'ios_register_state.dart';

class IosRegisterCubit extends Cubit<IosRegisterState> {
  final RegisterUseCase registerUseCase;
  final GetClassesUseCase getClassesUseCase;

  IosRegisterCubit({
    required this.registerUseCase,
    required this.getClassesUseCase,
  }) : super(const IosRegisterState());

  Future<void> loadClasses() async {
    emit(state.copyWith(isLoadingClasses: true, clearClassesError: true));

    final cacheResult = await getClassesUseCase(fromCache: true);
    if (!isClosed) {
      cacheResult.fold((_) {}, (cachedClasses) {
        if (cachedClasses.isNotEmpty) {
          emit(state.copyWith(classes: cachedClasses, isLoadingClasses: false));
        }
      });
    }

    final remoteResult = await getClassesUseCase(fromCache: false);
    if (isClosed) return;

    remoteResult.fold(
      (failure) {
        if (state.classes.isEmpty) {
          emit(
            state.copyWith(
              isLoadingClasses: false,
              classesError: failure.message,
            ),
          );
        } else {
          emit(state.copyWith(isLoadingClasses: false));
        }
      },
      (remoteClasses) {
        StudentClass? currentSelected = state.selectedClass;
        if (currentSelected != null) {
          try {
            currentSelected = remoteClasses.firstWhere(
              (c) => c.id == currentSelected!.id,
              orElse: () => currentSelected!,
            );
          } catch (_) {}
        }
        emit(
          state.copyWith(
            classes: remoteClasses,
            selectedClass: currentSelected,
            isLoadingClasses: false,
            clearClassesError: true,
          ),
        );
      },
    );
  }

  void selectClass(StudentClass? studentClass) {
    emit(
      state.copyWith(
        selectedClass: studentClass,
        clearSelectedClass: studentClass == null,
        // Reset any previous validation error so the BlocConsumer
        // listener doesn't re-fire the old error when the user
        // selects a class after a failed submit attempt.
        status: state.status == IosRegisterStatus.failure
            ? IosRegisterStatus.initial
            : null,
        clearErrorMessage: state.status == IosRegisterStatus.failure,
      ),
    );
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    StudentClass? selectedClass,
  }) async {
    final effectiveClass = selectedClass ?? state.selectedClass;

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      emit(
        state.copyWith(
          status: IosRegisterStatus.failure,
          errorMessage: 'يرجى إدخال الاسم بالكامل',
        ),
      );
      return;
    }

    if (effectiveClass == null) {
      emit(
        state.copyWith(
          status: IosRegisterStatus.failure,
          errorMessage: 'يرجى اختيار الصف الدراسي',
        ),
      );
      return;
    }

    if (state.selectedClass != effectiveClass) {
      emit(state.copyWith(selectedClass: effectiveClass));
    }

    final phoneError = Validators.phone(phone);
    if (phoneError != null) {
      emit(
        state.copyWith(
          status: IosRegisterStatus.failure,
          errorMessage: phoneError,
        ),
      );
      return;
    }

    final passwordError = Validators.password(
      password,
      minLength: 6,
      emptyMessage: 'يرجى إدخال كلمة المرور',
      minLengthMessage: 'كلمة المرور يجب أن لا تقل عن 6 أحرف',
    );
    if (passwordError != null) {
      emit(
        state.copyWith(
          status: IosRegisterStatus.failure,
          errorMessage: passwordError,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: IosRegisterStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final result = await registerUseCase(
      name: trimmedName,
      phone: phone.trim(),
      password: password,
      classId: effectiveClass.id,
      type: 'student',
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: IosRegisterStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          status: IosRegisterStatus.success,
          registerResponse: response,
        ),
      ),
    );
  }
}
