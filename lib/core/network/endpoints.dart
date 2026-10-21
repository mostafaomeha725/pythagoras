class EndPoints {
  static const String apiSecret = 'kJ5kHX2vCfiy0zc2mWulKgZy0TFo6pTF';

  static const String login = 'api/login';
  static const String register = 'api/register';
  static const String registerWhatsapp = 'api/register/whatsapp';
  static const String logout = 'api/logout';
  static const String refreshToken = 'Authentication/refresh-token';

  /// Profile endpoints
  static const String profile = 'profile';
  static const String account = 'api/account';
  static const String uploadProfilePicture = 'api/account/profilepicture';
  static const String updatePersonalProfile = 'api/account/personal';
  static const String myCourses = 'api/my-courses';
  static const String contact = 'api/contact';

  /// Courses endpoints
  static const String classes = 'api/classes';
  static const String courses = 'api/courses';
  static String courseDetails(int id) => 'api/courses/$id';
  static String courseCurriculum(int id) => 'api/courses/$id/curriculum';
  static String courseAssignments(int id) => 'api/courses/$id/assignments';
  static String assignmentDetails(int id) => 'api/assignments/$id';
  static String submitAssignment(int id) => 'api/assignments/$id/submit';
  static String assignmentSubmissions(int id) =>
      'api/assignments/$id/submissions';
  static String courseLiveSessions(int id) => 'api/live-sessions?course_id=$id';
  static String courseResources(int id) => 'api/courses/$id/resources';
  static String courseReviews(int id) => 'api/courses/$id/reviews';
  static String downloadResource(int id) => 'api/resources/$id/download';

  /// Quizzes endpoints
  static String courseQuizzes(int id) => 'api/courses/$id/quizzes';
  static String quizDetails(int id) => 'api/quizzes/$id';
  static String quizQuestions(int id) => 'api/quizzes/$id/questions';
  static String startQuizAttempt(int id) => 'api/quizzes/$id/start';
  static String submitAnswer(int id) => 'api/quizzes/$id/answer';
  static String submitQuiz(int id) => 'api/quizzes/$id/submit';
  static const String requestCourse = 'api/request/course';
  static const String requestChapter = 'api/request/chapter';

  /// iOS-only: direct enrollment — no WhatsApp redirect
  static const String requestCourseDirect = 'api/request/course/direct';
  static const String requestChapterDirect = 'api/request/chapter/direct';

  /// Videos endpoints
  static String chapterVideos(int chapterId) =>
      'api/chapters/$chapterId/videos';
  static String completeVideo(int videoId) => 'api/videos/$videoId/complete';
  static String completeLesson(int lessonId) =>
      'api/lessons/$lessonId/complete';
}
