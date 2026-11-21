import 'package:equatable/equatable.dart';

class RemoteConfigState extends Equatable {
  final bool iosIapEnabled;
  final bool courseLessonRequestsEnabled;
  final bool deleteAccountEnabled;
  final bool isLoading;
  final String? errorMessage;

  const RemoteConfigState({
    this.iosIapEnabled = false,
    this.courseLessonRequestsEnabled = true,
    this.deleteAccountEnabled = true,
    this.isLoading = false,
    this.errorMessage,
  });

  RemoteConfigState copyWith({
    bool? iosIapEnabled,
    bool? courseLessonRequestsEnabled,
    bool? deleteAccountEnabled,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return RemoteConfigState(
      iosIapEnabled: iosIapEnabled ?? this.iosIapEnabled,
      courseLessonRequestsEnabled:
          courseLessonRequestsEnabled ?? this.courseLessonRequestsEnabled,
      deleteAccountEnabled: deleteAccountEnabled ?? this.deleteAccountEnabled,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    iosIapEnabled,
    courseLessonRequestsEnabled,
    deleteAccountEnabled,
    isLoading,
    errorMessage,
  ];
}
