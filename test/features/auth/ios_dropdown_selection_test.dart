import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/auth/domain/entities/register_response.dart';
import 'package:pythagoras/features/auth/domain/repositories/auth_repository.dart';
import 'package:pythagoras/features/auth/domain/usecases/register_use_case.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_state.dart';
import 'package:pythagoras/features/auth/presentation/widgets/ios_register/ios_register_class_dropdown.dart';
import 'package:pythagoras/features/auth/presentation/widgets/ios_register/ios_register_form.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_classes_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockCoursesRepository implements CoursesRepository {
  List<StudentClass> mockClasses = [
    const StudentClass(id: 1, name: 'الصف العاشر'),
    const StudentClass(id: 2, name: 'الصف الحادي عشر'),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Either<Failure, List<StudentClass>>> getClasses({
    bool fromCache = false,
  }) async {
    return Right(mockClasses);
  }
}

class MockAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Either<Failure, RegisterResponse>> register({
    required String name,
    required String phone,
    required String password,
    required int classId,
    String type = 'student',
  }) async {
    return const Right(
      RegisterResponse(
        success: true,
        message: 'تم إنشاء الحساب بنجاح',
        token: 'token',
      ),
    );
  }
}

void main() {
  testWidgets('Dropdown menu opens ABOVE the button', (tester) async {
    tester.view.physicalSize = const Size(420, 910);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockCoursesRepo = MockCoursesRepository();
    final mockAuthRepo = MockAuthRepository();
    final cubit = IosRegisterCubit(
      registerUseCase: RegisterUseCase(mockAuthRepo),
      getClassesUseCase: GetClassesUseCase(mockCoursesRepo),
    );

    await cubit.loadClasses();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(420, 910),
        builder: (context, _) => MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: BlocProvider<IosRegisterCubit>.value(
                    value: cubit,
                    child: const IosRegisterClassDropdown(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dropdownButtonFinder = find.byType(DropdownButton2<StudentClass>);
    expect(dropdownButtonFinder, findsOneWidget);
    final buttonRect = tester.getRect(dropdownButtonFinder);

    // Tap dropdown to open menu
    await tester.tap(dropdownButtonFinder);
    await tester.pumpAndSettle();

    // Check position of opened menu item
    final itemFinder = find.text('الصف العاشر');
    expect(itemFinder, findsWidgets);
    final itemRect = tester.getRect(itemFinder.last);

    // The item should be strictly above or equal to the top of the button
    expect(itemRect.top, lessThan(buttonRect.top));
  });

  testWidgets(
    'Selecting a class in IosRegisterForm properly registers without error',
    (tester) async {
      tester.view.physicalSize = const Size(420, 910);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockCoursesRepo = MockCoursesRepository();
      final mockAuthRepo = MockAuthRepository();
      final cubit = IosRegisterCubit(
        registerUseCase: RegisterUseCase(mockAuthRepo),
        getClassesUseCase: GetClassesUseCase(mockCoursesRepo),
      );

      await cubit.loadClasses();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(420, 910),
          builder: (context, _) => MaterialApp(
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: BlocProvider<IosRegisterCubit>.value(
                  value: cubit,
                  child: const SingleChildScrollView(child: IosRegisterForm()),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Enter Name
      await tester.enterText(find.byType(TextFormField).at(0), 'أحمد علي');
      await tester.pumpAndSettle();

      // Enter Phone
      await tester.enterText(find.byType(TextFormField).at(1), '99887766');
      await tester.pumpAndSettle();

      // Enter Password
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.pumpAndSettle();

      // Open Dropdown
      final dropdownFinder = find.byType(DropdownButton2<StudentClass>);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Tap on 'الصف العاشر'
      final classItem = find.text('الصف العاشر').last;
      await tester.tap(classItem);
      await tester.pumpAndSettle();

      // Verify selected class shows
      expect(find.text('الصف العاشر'), findsOneWidget);

      // Tap Register
      await tester.tap(find.text('إنشاء حساب'));
      await tester.pumpAndSettle();

      // Verify no failure with 'يرجى اختيار الصف الدراسي'
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.status, IosRegisterStatus.success);
    },
  );

  test(
    'selectClass after failed submit resets status to initial and clears error',
    () async {
      // Arrange
      final cubit = IosRegisterCubit(
        registerUseCase: RegisterUseCase(MockAuthRepository()),
        getClassesUseCase: GetClassesUseCase(MockCoursesRepository()),
      );
      await cubit.loadClasses();

      // Simulate failed submit (no class selected)
      await cubit.register(
        name: 'أحمد',
        phone: '99887766',
        password: 'pass123',
      );
      expect(cubit.state.status, IosRegisterStatus.failure);
      expect(cubit.state.errorMessage, 'يرجى اختيار الصف الدراسي');

      // Act: user selects class after seeing the error
      cubit.selectClass(const StudentClass(id: 1, name: 'الصف العاشر'));

      // Assert: BlocConsumer won't re-fire the old error
      expect(cubit.state.status, IosRegisterStatus.initial);
      expect(cubit.state.errorMessage, isNull);
      expect(cubit.state.selectedClass?.id, 1);
    },
  );
}
