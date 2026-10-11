class CourseVimeoEmbedBuilder {
  CourseVimeoEmbedBuilder._();

  static String extractVimeoId(String url) {
    final regex = RegExp(r'vimeo\.com/(?:video/)?(\d+)');
    final match = regex.firstMatch(url);
    if (match != null) {
      return match.group(1) ?? url;
    }
    return url;
  }

  static String buildHtml(String videoId) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0">
  <style>body, html { margin: 0; padding: 0; width: 100%; height: 100%; background: black; overflow: hidden; }</style>
</head>
<body>
  <iframe id="vimeo-player" src="https://player.vimeo.com/video/$videoId?controls=0&autoplay=1&playsinline=1" width="100%" height="100%" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>
  <script src="https://player.vimeo.com/api/player.js"></script>
  <script>
    var iframe = document.querySelector('iframe');
    var player = new Vimeo.Player(iframe);
    
    player.on('timeupdate', function(data) {
       window.VimeoFlutterChannel.postMessage(JSON.stringify({
          event: 'timeupdate',
          duration: data.duration,
          currentTime: data.seconds
       }));
    });
    player.on('play', function() {
       window.VimeoFlutterChannel.postMessage(JSON.stringify({ event: 'play' }));
    });
    player.on('pause', function() {
       window.VimeoFlutterChannel.postMessage(JSON.stringify({ event: 'pause' }));
    });
    
    window.flutterPlay = function() { player.play(); };
    window.flutterPause = function() { player.pause(); };
    window.flutterSeek = function(sec) { player.setCurrentTime(sec); };
    window.flutterVolume = function(vol) { player.setVolume(vol); };
    
    player.getDuration().then(function(dur) {
        window.VimeoFlutterChannel.postMessage(JSON.stringify({
          event: 'ready',
          duration: dur
       }));
    }).catch(function() {});
  </script>
</body>
</html>
''';
  }
}
