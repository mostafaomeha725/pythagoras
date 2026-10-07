import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_classes_use_case.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_state.dart';

class ClassesCubit extends Cubit<ClassesState> {
  final GetClassesUseCase getClassesUseCase;

  bool _isFetchingRemote = false;

  ClassesCubit(this.getClassesUseCase) : super(ClassesInitial());

  Future<void> fetchClasses() async {
    // 1. Load from cache first
    final cacheResult = await getClassesUseCase(fromCache: true);
    cacheResult.fold(
      (failure) {
        if (state is! ClassesLoaded && !isClosed) {
          emit(ClassesLoading());
        }
      },
      (cachedClasses) {
        if (isClosed) return;
        final List<StudentClass> withAll = [
          const StudentClass(id: 0, name: 'الكل'),
          ...cachedClasses,
        ];

        StudentClass? currentSelected;
        if (state is ClassesLoaded) {
          currentSelected = (state as ClassesLoaded).selectedClass;
        }

        emit(ClassesLoaded(classes: withAll, selectedClass: currentSelected));
      },
    );

    // 2. Fetch from remote in background
    if (_isFetchingRemote || isClosed) return;
    _isFetchingRemote = true;

    final result = await getClassesUseCase(fromCache: false);

    _isFetchingRemote = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        if (state is! ClassesLoaded) {
          emit(ClassesError(failure.message));
        }
      },
      (remoteClasses) {
        final List<StudentClass> withAll = [
          const StudentClass(id: 0, name: 'الكل'),
          ...remoteClasses,
        ];

        StudentClass? currentSelected;
        if (state is ClassesLoaded) {
          currentSelected = (state as ClassesLoaded).selectedClass;
        }

        emit(ClassesLoaded(classes: withAll, selectedClass: currentSelected));
      },
    );
  }

  void selectClass(StudentClass newClass) {
    if (state is ClassesLoaded) {
      final currentState = state as ClassesLoaded;
      emit(
        ClassesLoaded(classes: currentState.classes, selectedClass: newClass),
      );
      // Later on we can trigger fetching courses using this new class ID
    }
  }

  void resetClasses() {
    emit(ClassesInitial());
  }
}
