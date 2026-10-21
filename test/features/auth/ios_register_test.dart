import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/core/error/failure.dart';
import 'package:pythagoras/features/auth/domain/entities/register_response.dart';
import 'package:pythagoras/features/auth/domain/repositories/auth_repository.dart';
import 'package:pythagoras/features/auth/domain/usecases/get_whatsapp_register_url_use_case.dart';
import 'package:pythagoras/features/auth/domain/usecases/register_use_case.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_state.dart';
import 'package:pythagoras/features/auth/presentation/cubit/whatsapp_register_cubit.dart';
import 'package:pythagoras/features/auth/presentation/screens/register_screen.dart';
import 'package:pythagoras/features/auth/presentation/widgets/ios_register/ios_register_screen_body.dart';
import 'package:pythagoras/features/auth/presentation/widgets/ios_register/ios_register_tablet_landscape.dart';
import 'package:pythagoras/features/auth/presentation/widgets/register_screen_body.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';
import 'package:pythagoras/features/courses/domain/repositories/courses_repository.dart';
import 'package:pythagoras/features/courses/domain/use_cases/get_classes_use_case.dart';

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
  Either<Failure, RegisterResponse>? registerResult;
  Map<String, dynamic>? lastRegisterData;

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
    lastRegisterData = {
      'name': name,
      'phone': phone,
      'password': password,
      'class_id': classId,
      'type': type,
    };
    return registerResult ??
        const Right(
          RegisterResponse(
            success: true,
            message: 'تم إنشاء الحساب بنجاح',
            token: 'test_token',
          ),
        );
  }

  @override
  Future<Either<Failure, String>> getWhatsappRegisterUrl() async {
    return const Right('https://wa.me/123456789');
  }
}

Widget createTestApp({
  required TargetPlatform platform,
  required Size surfaceSize,
}) {
  return MediaQuery(
    data: MediaQueryData(size: surfaceSize),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, _) => MaterialApp(
        theme: ThemeData(platform: platform),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: RegisterScreen(),
        ),
      ),
    ),
  );
}

void main() {
  late MockCoursesRepository mockCoursesRepo;
  late MockAuthRepository mockAuthRepo;
  late GetClassesUseCase getClassesUseCase;
  late RegisterUseCase registerUseCase;

  setUp(() {
    mockCoursesRepo = MockCoursesRepository();
    mockAuthRepo = MockAuthRepository();
    getClassesUseCase = GetClassesUseCase(mockCoursesRepo);
    registerUseCase = RegisterUseCase(mockAuthRepo);

    if (sl.isRegistered<IosRegisterCubit>()) {
      sl.unregister<IosRegisterCubit>();
    }
    if (sl.isRegistered<WhatsappRegisterCubit>()) {
      sl.unregister<WhatsappRegisterCubit>();
    }

    sl.registerFactory<IosRegisterCubit>(
      () => IosRegisterCubit(
        registerUseCase: registerUseCase,
        getClassesUseCase: getClassesUseCase,
      ),
    );

    sl.registerFactory<WhatsappRegisterCubit>(
      () => WhatsappRegisterCubit(
        getWhatsappRegisterUrlUseCase: GetWhatsappRegisterUrlUseCase(
          mockAuthRepo,
        ),
      ),
    );
  });

  tearDown(() {
    if (sl.isRegistered<IosRegisterCubit>()) {
      sl.unregister<IosRegisterCubit>();
    }
    if (sl.isRegistered<WhatsappRegisterCubit>()) {
      sl.unregister<WhatsappRegisterCubit>();
    }
  });

  group('IosRegisterCubit Unit Tests', () {
    test('loadClasses populates classes list', () async {
      final cubit = IosRegisterCubit(
        registerUseCase: registerUseCase,
        getClassesUseCase: getClassesUseCase,
      );

      await cubit.loadClasses();

      expect(cubit.state.classes.length, 2);
      expect(cubit.state.classes.first.name, 'الصف العاشر');
      expect(cubit.state.isLoadingClasses, false);
      expect(cubit.state.classesError, isNull);
    });

    test('selectClass updates selectedClass in state', () {
      final cubit = IosRegisterCubit(
        registerUseCase: registerUseCase,
        getClassesUseCase: getClassesUseCase,
      );

      const studentClass = StudentClass(id: 1, name: 'الصف العاشر');
      cubit.selectClass(studentClass);

      expect(cubit.state.selectedClass, studentClass);
    });

    test('validation fails when name is empty', () async {
      final cubit = IosRegisterCubit(
        registerUseCase: registerUseCase,
        getClassesUseCase: getClassesUseCase,
      );

      await cubit.register(
        name: '',
        phone: '99887766',
        password: 'password123',
      );

      expect(cubit.state.status, IosRegisterStatus.failure);
      expect(cubit.state.errorMessage, 'يرجى إدخال الاسم بالكامل');
    });

    test('validation fails when class is not selected', () async {
      final cubit = IosRegisterCubit(
        registerUseCase: registerUseCase,
        getClassesUseCase: getClassesUseCase,
      );

      await cubit.register(
        name: 'أحمد علي',
        phone: '99887766',
        password: 'password123',
      );

      expect(cubit.state.status, IosRegisterStatus.failure);
      expect(cubit.state.errorMessage, 'يرجى اختيار الصف الدراسي');
    });

    test('validation fails when phone is empty', () async {
      final cubit = IosRegisterCubit(
        registerUseCase: registerUseCase,
        getClassesUseCase: getClassesUseCase,
      );
      cubit.selectClass(const StudentClass(id: 1, name: 'الصف العاشر'));

      await cubit.register(
        name: 'أحمد علي',
        phone: '',
        password: 'password123',
      );

      expect(cubit.state.status, IosRegisterStatus.failure);
      expect(cubit.state.errorMessage, 'يرجى إدخال رقم الهاتف');
    });

    test('validation fails when password is short (<6 chars)', () async {
      final cubit = IosRegisterCubit(
        registerUseCase: registerUseCase,
        getClassesUseCase: getClassesUseCase,
      );
      cubit.selectClass(const StudentClass(id: 1, name: 'الصف العاشر'));

      await cubit.register(
        name: 'أحمد علي',
        phone: '99887766',
        password: '123',
      );

      expect(cubit.state.status, IosRegisterStatus.failure);
      expect(cubit.state.errorMessage, 'كلمة المرور يجب أن لا تقل عن 6 أحرف');
    });

    test('successful registration passes type=student and class_id', () async {
      final cubit = IosRegisterCubit(
        registerUseCase: registerUseCase,
        getClassesUseCase: getClassesUseCase,
      );
      cubit.selectClass(const StudentClass(id: 3, name: 'الصف الثاني عشر'));

      await cubit.register(
        name: 'محمد خالد',
        phone: '99887766',
        password: 'securePassword12',
      );

      expect(cubit.state.status, IosRegisterStatus.success);
      expect(cubit.state.registerResponse?.token, 'test_token');
      expect(mockAuthRepo.lastRegisterData, {
        'name': 'محمد خالد',
        'phone': '99887766',
        'password': 'securePassword12',
        'class_id': 3,
        'type': 'student',
      });
    });

    test('handles failure from register repository', () async {
      mockAuthRepo.registerResult = const Left(
        Failure('رقم الهاتف مسجل بالفعل'),
      );
      final cubit = IosRegisterCubit(
        registerUseCase: registerUseCase,
        getClassesUseCase: getClassesUseCase,
      );
      cubit.selectClass(const StudentClass(id: 1, name: 'الصف العاشر'));

      await cubit.register(
        name: 'محمد خالد',
        phone: '99887766',
        password: 'securePassword12',
      );

      expect(cubit.state.status, IosRegisterStatus.failure);
      expect(cubit.state.errorMessage, 'رقم الهاتف مسجل بالفعل');
    });
  });

  group('Platform Isolation & Widget Tests', () {
    testWidgets('shows IosRegisterScreenBody on iOS platform', (tester) async {
      tester.view.physicalSize = const Size(420, 910);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestApp(
          platform: TargetPlatform.iOS,
          surfaceSize: const Size(420, 910),
        ),
      );
      await tester.pump();

      expect(find.byType(IosRegisterScreenBody), findsOneWidget);
      expect(find.byType(RegisterScreenBody), findsNothing);
      expect(find.text('إنشاء حساب جديد'), findsOneWidget);
      expect(find.text('الاسم الكامل'), findsOneWidget);
      expect(find.text('الصف الدراسي'), findsOneWidget);
      expect(find.text('رقم الهاتف'), findsOneWidget);
      expect(find.text('كلمة المرور'), findsOneWidget);
    });

    testWidgets('shows original RegisterScreenBody (WhatsApp) on Android', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(420, 910);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestApp(
          platform: TargetPlatform.android,
          surfaceSize: const Size(420, 910),
        ),
      );
      await tester.pump();

      expect(find.byType(RegisterScreenBody), findsOneWidget);
      expect(find.byType(IosRegisterScreenBody), findsNothing);
      expect(find.text('إنشاء حساب عبر واتساب'), findsOneWidget);
    });

    testWidgets('renders tablet landscape layout on iPad Landscape', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        createTestApp(
          platform: TargetPlatform.iOS,
          surfaceSize: const Size(1280, 800),
        ),
      );
      await tester.pump();

      expect(find.byType(IosRegisterTabletLandscape), findsOneWidget);
      expect(
        find.byKey(const ValueKey('tablet_ios_register_form')),
        findsOneWidget,
      );
    });
  });
}
