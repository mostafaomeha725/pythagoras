import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pythagoras/core/widgets/bouncing_widgets.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/submit_assignment/submit_assignment_state.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_sheet.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_actions.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_file_picker.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_header.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_notes_field.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_picked_file_preview.dart';
import 'package:pythagoras/features/courses/presentation/widgets/assignments/submit_assignment_tablet_sheet.dart';

class FakeSubmitAssignmentCubit extends Cubit<SubmitAssignmentState>
    implements SubmitAssignmentCubit {
  int? submittedAssignmentId;
  String? submittedNotes;
  String? submittedFilePath;
  String? submittedFileName;

  FakeSubmitAssignmentCubit() : super(SubmitAssignmentInitial());

  @override
  Future<void> submit({
    required int assignmentId,
    String? notes,
    String? filePath,
    String? fileName,
  }) async {
    submittedAssignmentId = assignmentId;
    submittedNotes = notes;
    submittedFilePath = filePath;
    submittedFileName = fileName;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget buildTestSheet({
  required Size surfaceSize,
  required Widget child,
  EdgeInsets viewInsets = EdgeInsets.zero,
}) {
  return MediaQuery(
    data: MediaQueryData(
      size: surfaceSize,
      viewInsets: viewInsets,
    ),
    child: ScreenUtilInit(
      designSize: const Size(420, 910),
      builder: (context, _) => MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
}

void main() {
  group('SubmitAssignmentSheet - Responsive Layout Isolation Tests', () {
    testWidgets(
      'Tablet Landscape (1280x800): renders SubmitAssignmentTabletSheet with 2 columns, actions and no overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeCubit = FakeSubmitAssignmentCubit();

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(1280, 800),
            child: BlocProvider<SubmitAssignmentCubit>.value(
              value: fakeCubit,
              child: const SubmitAssignmentSheet(
                assignmentId: 101,
                assignmentTitle: 'واجب الجبر والهندسة الفراغية',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must render tablet sheet
        expect(find.byType(SubmitAssignmentTabletSheet), findsOneWidget);
        expect(find.byType(SubmitAssignmentTabletHeader), findsOneWidget);
        expect(find.byType(SubmitAssignmentTabletNotesField), findsOneWidget);
        expect(find.byType(SubmitAssignmentTabletFilePicker), findsOneWidget);
        expect(find.byType(SubmitAssignmentTabletActions), findsOneWidget);

        // Verify titles and content (header title + submit button text)
        expect(find.text('تسليم الواجب'), findsNWidgets(2));
        expect(find.text('واجب الجبر والهندسة الفراغية'), findsOneWidget);
        expect(find.text('تسليماتي'), findsOneWidget);
        expect(find.text('الملاحظات'), findsOneWidget);
        expect(find.text('رفع ملف (اختياري)'), findsOneWidget);
        expect(find.text('إلغاء'), findsOneWidget);

        // Verify no RenderFlex overflow
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Mobile Portrait (412x915): preserves original mobile layout, NOT tablet sheet',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeCubit = FakeSubmitAssignmentCubit();

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(412, 915),
            child: BlocProvider<SubmitAssignmentCubit>.value(
              value: fakeCubit,
              child: const SubmitAssignmentSheet(
                assignmentId: 101,
                assignmentTitle: 'واجب التفاضل والتكامل',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must NOT render tablet sheet
        expect(find.byType(SubmitAssignmentTabletSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Tablet Portrait (800x1280): preserves original layout, NOT tablet landscape sheet',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1280);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeCubit = FakeSubmitAssignmentCubit();

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(800, 1280),
            child: BlocProvider<SubmitAssignmentCubit>.value(
              value: fakeCubit,
              child: const SubmitAssignmentSheet(
                assignmentId: 101,
                assignmentTitle: 'واجب التفاضل والتكامل',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must NOT render tablet sheet
        expect(find.byType(SubmitAssignmentTabletSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Mobile Landscape (844x390): preserves original layout, NOT tablet sheet',
      (tester) async {
        tester.view.physicalSize = const Size(844, 390);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeCubit = FakeSubmitAssignmentCubit();

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(844, 390),
            child: BlocProvider<SubmitAssignmentCubit>.value(
              value: fakeCubit,
              child: const SubmitAssignmentSheet(
                assignmentId: 101,
                assignmentTitle: 'واجب الإحصاء',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must NOT render tablet sheet
        expect(find.byType(SubmitAssignmentTabletSheet), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('SubmitAssignmentTabletSheet - Widget Components & Keyboard Interaction', () {
    testWidgets(
      'Tablet Landscape with keyboard open (viewInsets bottom: 260) does not overflow',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 768);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final notesController = TextEditingController();
        addTearDown(notesController.dispose);

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(1024, 768),
            viewInsets: const EdgeInsets.only(bottom: 260),
            child: SubmitAssignmentTabletSheet(
              assignmentTitle: 'واجب الديناميكا',
              notesController: notesController,
              pickedFile: null,
              onPickFile: () {},
              onRemoveFile: () {},
              onMySubmissions: () {},
              onSubmit: () {},
              onClose: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SubmitAssignmentTabletSheet), findsOneWidget);
        expect(find.text('تسليم الواجب'), findsNWidgets(2));
        expect(find.text('إلغاء'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Writing notes into text field updates the controller',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final notesController = TextEditingController();
        addTearDown(notesController.dispose);

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(1280, 800),
            child: SubmitAssignmentTabletSheet(
              assignmentTitle: 'واجب الديناميكا',
              notesController: notesController,
              pickedFile: null,
              onPickFile: () {},
              onRemoveFile: () {},
              onMySubmissions: () {},
              onSubmit: () {},
              onClose: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), 'تم حل المسألة رقم 4 و 5');
        await tester.pumpAndSettle();

        expect(notesController.text, 'تم حل المسألة رقم 4 و 5');
      },
    );

    testWidgets(
      'Shows file preview card and triggers remove callback',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final notesController = TextEditingController();
        addTearDown(notesController.dispose);
        bool fileRemoved = false;

        final mockFile = PlatformFile(
          name: 'solution_sheet.pdf',
          size: 204800,
        );

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(1280, 800),
            child: SubmitAssignmentTabletSheet(
              assignmentTitle: 'واجب الديناميكا',
              notesController: notesController,
              pickedFile: mockFile,
              onPickFile: () {},
              onRemoveFile: () => fileRemoved = true,
              onMySubmissions: () {},
              onSubmit: () {},
              onClose: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SubmitAssignmentTabletPickedFilePreview), findsOneWidget);
        expect(find.text('solution_sheet.pdf'), findsOneWidget);
        expect(find.text('200.0 KB'), findsOneWidget);

        // Tap remove icon inside preview card
        final removeButtonFinder = find.descendant(
          of: find.byType(SubmitAssignmentTabletPickedFilePreview),
          matching: find.byType(IconButton),
        );
        await tester.tap(removeButtonFinder);
        await tester.pumpAndSettle();

        expect(fileRemoved, isTrue);
      },
    );

    testWidgets(
      'Cancel, Submit, Close and Submissions callbacks are triggered when buttons are pressed',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final notesController = TextEditingController();
        addTearDown(notesController.dispose);

        bool cancelled = false;
        bool mySubmissionsTapped = false;
        bool submitted = false;

        await tester.pumpWidget(
          buildTestSheet(
            surfaceSize: const Size(1280, 800),
            child: SubmitAssignmentTabletSheet(
              assignmentTitle: 'واجب الديناميكا',
              notesController: notesController,
              pickedFile: null,
              onPickFile: () {},
              onRemoveFile: () {},
              onMySubmissions: () => mySubmissionsTapped = true,
              onSubmit: () => submitted = true,
              onClose: () => cancelled = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Cancel
        await tester.tap(find.text('إلغاء'));
        await tester.pumpAndSettle();
        expect(cancelled, isTrue);

        // Tap Submit
        await tester.tap(find.descendant(
          of: find.byType(SubmitAssignmentTabletActions),
          matching: find.text('تسليم الواجب'),
        ));
        await tester.pumpAndSettle();
        expect(submitted, isTrue);

        // Tap My Submissions
        await tester.tap(find.text('تسليماتي'));
        await tester.pumpAndSettle();
        expect(mySubmissionsTapped, isTrue);

        // Tap Close icon in header
        final closeHeaderFinder = find.descendant(
          of: find.byType(SubmitAssignmentTabletHeader),
          matching: find.byType(BounceIt),
        ).first;
        await tester.tap(closeHeaderFinder);
        await tester.pumpAndSettle();
        expect(cancelled, isTrue);
      },
    );
  });
}
