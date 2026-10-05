abstract class RequestEnrollmentState {}

class RequestEnrollmentInitial extends RequestEnrollmentState {}

class RequestEnrollmentLoading extends RequestEnrollmentState {}

class RequestEnrollmentSuccess extends RequestEnrollmentState {
  final String whatsappUrl;
  RequestEnrollmentSuccess(this.whatsappUrl);
}

class RequestEnrollmentError extends RequestEnrollmentState {
  final String message;
  RequestEnrollmentError(this.message);
}
