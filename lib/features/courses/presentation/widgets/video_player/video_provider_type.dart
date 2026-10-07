enum VideoProviderType {
  youtube,
  bunny,
  vimeo,
  viewlock,
  unknown,
}

VideoProviderType determineVideoProvider(String? url, String? explicitType) {
  if (explicitType != null) {
    switch (explicitType.toLowerCase()) {
      case 'youtube':
        return VideoProviderType.youtube;
      case 'bunny':
        return VideoProviderType.bunny;
      case 'vimeo':
        return VideoProviderType.vimeo;
      case 'viewlock':
        return VideoProviderType.viewlock;
    }
  }

  if (url == null || url.isEmpty) return VideoProviderType.unknown;

  final lowerUrl = url.toLowerCase();
  if (lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be')) {
    return VideoProviderType.youtube;
  }
  if (lowerUrl.contains('bunny.net') || lowerUrl.contains('b-cdn.net')) {
    return VideoProviderType.bunny;
  }
  if (lowerUrl.contains('vimeo.com')) {
    return VideoProviderType.vimeo;
  }
  if (lowerUrl.contains('viewlock')) {
    return VideoProviderType.viewlock;
  }
  
  // Default fallback for mp4/m3u8 if unknown
  if (lowerUrl.endsWith('.mp4') || lowerUrl.endsWith('.m3u8')) {
    return VideoProviderType.bunny; // Use native player for standard streams
  }

  return VideoProviderType.unknown;
}

String formatEmbedUrl(String url, VideoProviderType type) {
  if (type == VideoProviderType.vimeo) {
    // Convert https://vimeo.com/123456 to https://player.vimeo.com/video/123456
    final regex = RegExp(r'vimeo\.com/(?:video/)?(\d+)');
    final match = regex.firstMatch(url);
    if (match != null) {
      final videoId = match.group(1);
      return 'https://player.vimeo.com/video/$videoId?autoplay=0&title=0&byline=0&portrait=0';
    }
  }
  
  // Return as-is for Viewlock and others which are likely already embed links
  return url;
}
