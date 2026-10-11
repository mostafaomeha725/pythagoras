class CourseVideoUrlHelper {
  CourseVideoUrlHelper._();

  static bool isDirectVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.m3u8') ||
        lower.contains('.mp4?') ||
        lower.contains('.m3u8?');
  }
}
