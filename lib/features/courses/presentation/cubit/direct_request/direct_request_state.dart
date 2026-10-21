abstract class DirectRequestState {}

class DirectRequestInitial extends DirectRequestState {}

class DirectRequestLoading extends DirectRequestState {}

class DirectRequestSuccess extends DirectRequestState {
  final String message;
  DirectRequestSuccess(this.message);
}

class DirectRequestError extends DirectRequestState {
  final String message;
  DirectRequestError(this.message);
}
