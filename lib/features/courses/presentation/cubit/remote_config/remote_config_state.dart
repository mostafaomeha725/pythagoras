import 'package:equatable/equatable.dart';

class RemoteConfigState extends Equatable {
  final bool iosIapEnabled;
  final bool isLoading;
  final String? errorMessage;

  const RemoteConfigState({
    this.iosIapEnabled = false,
    this.isLoading = false,
    this.errorMessage,
  });

  RemoteConfigState copyWith({
    bool? iosIapEnabled,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return RemoteConfigState(
      iosIapEnabled: iosIapEnabled ?? this.iosIapEnabled,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [iosIapEnabled, isLoading, errorMessage];
}
