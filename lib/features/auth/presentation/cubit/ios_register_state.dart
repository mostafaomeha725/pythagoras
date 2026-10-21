import 'package:equatable/equatable.dart';
import 'package:pythagoras/features/auth/domain/entities/register_response.dart';
import 'package:pythagoras/features/courses/domain/entities/student_class.dart';

enum IosRegisterStatus { initial, loading, success, failure }

class IosRegisterState extends Equatable {
  final List<StudentClass> classes;
  final StudentClass? selectedClass;
  final bool isLoadingClasses;
  final String? classesError;
  final IosRegisterStatus status;
  final String? errorMessage;
  final RegisterResponse? registerResponse;

  const IosRegisterState({
    this.classes = const [],
    this.selectedClass,
    this.isLoadingClasses = false,
    this.classesError,
    this.status = IosRegisterStatus.initial,
    this.errorMessage,
    this.registerResponse,
  });

  IosRegisterState copyWith({
    List<StudentClass>? classes,
    StudentClass? selectedClass,
    bool clearSelectedClass = false,
    bool? isLoadingClasses,
    String? classesError,
    bool clearClassesError = false,
    IosRegisterStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    RegisterResponse? registerResponse,
  }) {
    return IosRegisterState(
      classes: classes ?? this.classes,
      selectedClass: clearSelectedClass
          ? null
          : (selectedClass ?? this.selectedClass),
      isLoadingClasses: isLoadingClasses ?? this.isLoadingClasses,
      classesError: clearClassesError
          ? null
          : (classesError ?? this.classesError),
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      registerResponse: registerResponse ?? this.registerResponse,
    );
  }

  @override
  List<Object?> get props => [
    classes,
    selectedClass,
    isLoadingClasses,
    classesError,
    status,
    errorMessage,
    registerResponse,
  ];
}
