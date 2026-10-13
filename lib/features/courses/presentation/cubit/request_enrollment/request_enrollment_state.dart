abstract class RequestEnrollmentState {}

class RequestEnrollmentInitial extends RequestEnrollmentState {}

class RequestEnrollmentLoading extends RequestEnrollmentState {}

class RequestEnrollmentSuccess extends RequestEnrollmentState {
  final String whatsappUrl;
  final String? chapterTitle;
  final String? courseTitle;
  final bool isChapter;

  RequestEnrollmentSuccess(
    this.whatsappUrl, {
    this.chapterTitle,
    this.courseTitle,
    this.isChapter = false,
  });
}

class RequestEnrollmentError extends RequestEnrollmentState {
  final String message;
  RequestEnrollmentError(this.message);
}
