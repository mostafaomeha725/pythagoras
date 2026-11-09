class CourseWebViewScripts {
  CourseWebViewScripts._();

  static const String videoStateSyncScript = '''
    (function() {
      var videos = document.getElementsByTagName('video');
      var v = null;
      var maxDur = 0;
      for (var i = 0; i < videos.length; i++) {
        if (videos[i].duration && !isNaN(videos[i].duration) && videos[i].duration > maxDur) {
          maxDur = videos[i].duration;
          v = videos[i];
        }
      }
      if (!v && videos.length > 0) v = videos[0];
      
      var iframe = document.querySelector('iframe');
      var ifSrc = iframe ? iframe.src : 'none';
      
      var hasPlyr = document.querySelector('.plyr') !== null;
      var hasPoster = document.querySelector('.plyr__poster') !== null;
      var posterHidden = false;
      if (hasPoster) {
        var poster = document.querySelector('.plyr__poster');
        posterHidden = window.getComputedStyle(poster).opacity === '0' || window.getComputedStyle(poster).display === 'none';
      }

      var vWidth = v ? v.clientWidth : 0;
      var vHeight = v ? v.clientHeight : 0;
      
      if (!v) {
        return JSON.stringify({ error: 'No video element found', iframe: ifSrc, hasPlyr: hasPlyr });
      }
      
      return JSON.stringify({
        paused: v.paused,
        currentTime: v.currentTime,
        duration: v.duration,
        volume: v.volume,
        muted: v.muted,
        videos_count: videos.length,
        iframe: ifSrc,
        hasPlyr: hasPlyr,
        hasPoster: hasPoster,
        posterHidden: posterHidden,
        vWidth: vWidth,
        vHeight: vHeight,
        readyState: v.readyState,
        networkState: v.networkState
      });
    })();
  ''';

  static String playScript({required bool isVimeo}) {
    if (isVimeo) {
      return 'if(window.flutterPlay) window.flutterPlay();';
    }
    return "document.querySelector('video')?.play();";
  }

  static String pauseScript({required bool isVimeo}) {
    if (isVimeo) {
      return 'if(window.flutterPause) window.flutterPause();';
    }
    return "document.querySelector('video')?.pause();";
  }

  static String seekScript(double seconds, {required bool isVimeo}) {
    if (isVimeo) {
      return 'if(window.flutterSeek) window.flutterSeek($seconds);';
    }
    return 'var v = document.querySelector(\'video\'); if (v) v.currentTime = $seconds;';
  }

  static String setVolumeScript(double vol, {required bool isVimeo}) {
    if (isVimeo) {
      return 'if(window.flutterVolume) window.flutterVolume($vol);';
    }
    return 'var v = document.querySelector(\'video\'); if (v) v.volume = $vol;';
  }

  static String setPlaybackSpeedScript(double speed, {required bool isVimeo}) {
    if (isVimeo) {
      return 'if(window.flutterPlaybackSpeed) window.flutterPlaybackSpeed($speed);';
    }
    return 'var v = document.querySelector(\'video\'); if (v) v.playbackRate = $speed;';
  }

  static String toggleMuteScript(bool newMuted, {required bool isVimeo}) {
    if (isVimeo) {
      return 'if(window.flutterVolume) window.flutterVolume(${newMuted ? 0.0 : 1.0});';
    }
    return 'var v = document.querySelector(\'video\'); if (v) v.muted = $newMuted;';
  }
}
