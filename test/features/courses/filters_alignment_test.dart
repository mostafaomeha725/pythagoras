import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/domain/entities/semester_option.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/classes/classes_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/courses_list/courses_list_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/filters/course_tablet_filter_bar.dart';

class FakeClassesCubit extends Cubit<ClassesState> implements ClassesCubit {
  int? selectedClassId;
  FakeClassesCubit()
    : super(
        const ClassesLoaded(
          classes: [
            StudentClass(id: 0, name: 'الكل'),
            StudentClass(id: 1, name: 'الصف العاشر'),
            StudentClass(id: 2, name: 'الصف الحادي عشر - علمي'),
            StudentClass(id: 3, name: 'الصف الحادي عشر - أدبي'),
            StudentClass(id: 4, name: 'الصف الثاني عشر - علمي'),
            StudentClass(id: 5, name: 'الصف الثاني عشر - أدبي'),
          ],
          selectedClass: StudentClass(id: 4, name: 'الصف الثاني عشر - علمي'),
        ),
      );

  @override
  void selectClass(StudentClass studentClass) {
    selectedClassId = studentClass.id;
    emit(
      ClassesLoaded(
        classes: const [
          StudentClass(id: 0, name: 'الكل'),
          StudentClass(id: 1, name: 'الصف العاشر'),
          StudentClass(id: 2, name: 'الصف الحادي عشر - علمي'),
          StudentClass(id: 3, name: 'الصف الحادي عشر - أدبي'),
          StudentClass(id: 4, name: 'الصف الثاني عشر - علمي'),
          StudentClass(id: 5, name: 'الصف الثاني عشر - أدبي'),
        ],
        selectedClass: studentClass,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCoursesListCubit extends Cubit<CoursesListState>
    implements CoursesListCubit {
  int? updatedClassId;
  int? updatedSemester;

  FakeCoursesListCubit() : super(CoursesListInitial());

  @override
  void updateFilters({int? classId, int? semester, bool fetch = true}) {
    if (classId != null) updatedClassId = classId;
    if (semester != null) updatedSemester = semester;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'Verify course tablet filter pills vertical centering, RTL alignment, and dropdown selection',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final classesCubit = FakeClassesCubit();
      final coursesListCubit = FakeCoursesListCubit();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ClassesCubit>.value(value: classesCubit),
            BlocProvider<CoursesListCubit>.value(value: coursesListCubit),
          ],
          child: ScreenUtilInit(
            designSize: const Size(420, 910),
            builder: (context, _) => const MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(body: Center(child: CourseTabletFilterBar())),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final classFilterFinder = find.text('الصف الثاني عشر - علمي');
      expect(classFilterFinder, findsOneWidget);
      final renderParagraph = tester.renderObject<RenderParagraph>(
        classFilterFinder,
      );
      expect(renderParagraph.didExceedMaxLines, isFalse);
      final classFilterRect = tester.getRect(classFilterFinder);

      final semesterFilterFinder = find.text('الفصل الدراسي');
      expect(semesterFilterFinder, findsOneWidget);
      final semesterFilterRect = tester.getRect(semesterFilterFinder);

      final icons = find.byIcon(Icons.keyboard_arrow_down_rounded);
      expect(icons, findsNWidgets(2));
      final icon1Rect = tester.getRect(icons.at(0));
      final icon2Rect = tester.getRect(icons.at(1));

      // Verify Pill containers are 42px in height and find their centerY
      final containers = find.byType(Container);
      final pillCenterYs = <double>[];
      for (final element in containers.evaluate()) {
        final renderBox = element.renderObject as RenderBox?;
        if (renderBox != null &&
            renderBox.hasSize &&
            (renderBox.size.height == 42.0)) {
          final position = renderBox.localToGlobal(Offset.zero);
          pillCenterYs.add(position.dy + 21.0);
        }
      }
      expect(pillCenterYs.isNotEmpty, isTrue);
      final expectedCenterY = pillCenterYs.first;

      // 2. Exact vertical centering assertions
      // The text centers and icon centers must align with expectedCenterY
      expect(
        (classFilterRect.center.dy - expectedCenterY).abs(),
        lessThan(0.5),
      );
      expect((icon1Rect.center.dy - expectedCenterY).abs(), lessThan(0.5));
      expect(
        (semesterFilterRect.center.dy - expectedCenterY).abs(),
        lessThan(0.5),
      );
      expect((icon2Rect.center.dy - expectedCenterY).abs(), lessThan(0.5));

      // 3. Test opening Class filter dropdown and selecting an option
      final classDropdownFinder = find.byType(DropdownButton<StudentClass>);
      await tester.tap(classDropdownFinder);
      await tester.pumpAndSettle();

      final longClassOptionFinder = find.text('الصف الثاني عشر - أدبي');
      expect(longClassOptionFinder, findsOneWidget);
      final itemRenderParagraph = tester.renderObject<RenderParagraph>(
        longClassOptionFinder,
      );
      expect(itemRenderParagraph.didExceedMaxLines, isFalse);

      final classOptionFinder = find.text('الصف العاشر');
      expect(classOptionFinder, findsOneWidget);
      await tester.tap(classOptionFinder);
      await tester.pumpAndSettle();

      expect(classesCubit.selectedClassId, equals(1));
      expect(coursesListCubit.updatedClassId, equals(1));

      // 4. Test opening Semester filter dropdown and selecting an option
      final semesterDropdownFinder = find.byType(
        DropdownButton<SemesterOption>,
      );
      await tester.tap(semesterDropdownFinder);
      await tester.pumpAndSettle();

      final semesterOptionFinder = find.text('الفصل الدراسي الثاني');
      expect(semesterOptionFinder, findsOneWidget);
      await tester.tap(semesterOptionFinder);
      await tester.pumpAndSettle();

      expect(coursesListCubit.updatedSemester, equals(2));
    },
  );
}
