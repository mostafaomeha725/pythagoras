import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/di/services_locator.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/ios_register_state.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_cubit.dart';
import 'package:pythagoras/features/auth/presentation/cubit/login_state.dart';
import 'package:pythagoras/features/auth/presentation/widgets/ios_register/ios_register_default_layout.dart';
import 'package:pythagoras/features/auth/presentation/widgets/login_default_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FakeLoginCubit extends Cubit<LoginState> implements LoginCubit {
  FakeLoginCubit() : super(LoginInitial());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> login(String phone, String password) async {}
}

class FakeIosRegisterCubit extends Cubit<IosRegisterState>
    implements IosRegisterCubit {
  FakeIosRegisterCubit() : super(const IosRegisterState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    if (sl.isRegistered<LoginCubit>()) {
      sl.unregister<LoginCubit>();
    }
    if (sl.isRegistered<IosRegisterCubit>()) {
      sl.unregister<IosRegisterCubit>();
    }
    sl.registerFactory<LoginCubit>(() => FakeLoginCubit());
    sl.registerFactory<IosRegisterCubit>(() => FakeIosRegisterCubit());
  });

  tearDown(() {
    if (sl.isRegistered<LoginCubit>()) {
      sl.unregister<LoginCubit>();
    }
    if (sl.isRegistered<IosRegisterCubit>()) {
      sl.unregister<IosRegisterCubit>();
    }
  });

  testWidgets('LoginDefaultLayout renders all expected components', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 910);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(420, 910),
        builder:
            (context, _) => MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: BlocProvider<LoginCubit>(
                  create: (_) => FakeLoginCubit(),
                  child: const Scaffold(body: LoginDefaultLayout()),
                ),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginDefaultLayout), findsOneWidget);
    expect(find.byKey(const ValueKey('default_login_form')), findsOneWidget);
    expect(find.text('مرحباً بك مجدداً'), findsOneWidget);
  });

  testWidgets('IosRegisterDefaultLayout renders all expected components', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 910);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(420, 910),
        builder:
            (context, _) => MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: BlocProvider<IosRegisterCubit>(
                  create: (_) => FakeIosRegisterCubit(),
                  child: const Scaffold(body: IosRegisterDefaultLayout()),
                ),
              ),
            ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(IosRegisterDefaultLayout), findsOneWidget);
    expect(
      find.byKey(const ValueKey('default_ios_register_form')),
      findsOneWidget,
    );
    expect(find.text('إنشاء حساب جديد'), findsOneWidget);
  });
}
