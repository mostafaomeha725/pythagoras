import 'package:equatable/equatable.dart';

class RemoteConfigState extends Equatable {
  final bool iosIapEnabled;
  final bool courseLessonRequestsEnabled;
  final bool isLoading;
  final String? errorMessage;

  const RemoteConfigState({
    this.iosIapEnabled = false,
    this.courseLessonRequestsEnabled = true,
    this.isLoading = false,
    this.errorMessage,
  });

  RemoteConfigState copyWith({
    bool? iosIapEnabled,
    bool? courseLessonRequestsEnabled,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return RemoteConfigState(
      iosIapEnabled: iosIapEnabled ?? this.iosIapEnabled,
      courseLessonRequestsEnabled:
          courseLessonRequestsEnabled ?? this.courseLessonRequestsEnabled,
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
    isLoading,
    errorMessage,
  ];
}
