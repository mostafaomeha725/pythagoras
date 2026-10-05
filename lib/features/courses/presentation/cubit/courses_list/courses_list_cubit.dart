import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_courses_use_case.dart';
import 'courses_list_state.dart';

class CoursesListCubit extends Cubit<CoursesListState> {
  final GetCoursesUseCase getCoursesUseCase;

  int? selectedClassId;
  int? selectedSemester;

  CoursesListCubit(this.getCoursesUseCase) : super(CoursesListInitial());

  Future<void> fetchCourses() async {
    // 1. Try Cache (SWR Pattern)
    final cacheResult = await getCoursesUseCase(
      classId: selectedClassId,
      semester: selectedSemester,
      fromCache: true,
    );

    bool hasCache = false;
    cacheResult.fold(
      (failure) {
        // Always emit loading if there's no cache for the new filter
        // to clear old data and show skeleton
        if (!isClosed) {
          emit(CoursesListLoading());
        }
      },
      (courses) {
        hasCache = true;
        if (!isClosed) {
          emit(CoursesListLoaded(courses));
        }
      },
    );

    // 2. Fetch Remote (Background revalidate)
    final result = await getCoursesUseCase(
      classId: selectedClassId,
      semester: selectedSemester,
      fromCache: false,
    );

    result.fold(
      (failure) {
        // Only show error if we don't have cache to display
        if (!hasCache && state is! CoursesListLoaded) {
          if (!isClosed) emit(CoursesListError(failure.message));
        }
      },
      (courses) {
        if (!isClosed) emit(CoursesListLoaded(courses));
      },
    );
  }

  void updateFilters({int? classId, int? semester, bool fetch = true}) {
    // Treat 0 as null (الكل) for classId
    if (classId != null) selectedClassId = classId == 0 ? null : classId;
    // Treat 0 as null (الكل) for semester
    if (semester != null) selectedSemester = semester == 0 ? null : semester;
    
    if (fetch) {
      fetchCourses();
    }
  }
}
