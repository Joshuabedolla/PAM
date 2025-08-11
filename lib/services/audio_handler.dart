
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class MusicAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  MusicAudioHandler() {
    _player.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.play,
          MediaControl.pause,
          MediaControl.stop,
        ],
        playing: _player.playing,
        processingState: AudioProcessingState.ready,
      ));
    });
  }

  Future<void> setQueueFromSongs(List<Song> songs) async {
    final mediaItems = songs.map((song) => MediaItem(
          id: song.url,
          album: song.album,
          title: song.title,
          artist: song.artist,
          duration: Duration(seconds: song.duration),
          artUri: Uri.tryParse(song.artUri),
        )).toList();

    queue.add(mediaItems);

    final audioSources = mediaItems.map((item) {
      if (item.id.startsWith('http')) {
        // Canción desde internet
        return AudioSource.uri(Uri.parse(item.id));
      } else if (item.id.startsWith('/')) {
        // Ruta absoluta en disco local
        return AudioSource.uri(Uri.file(item.id));
      } else {
        // Asset interno de Flutter
        return AudioSource.asset(item.id);
      }
    }).toList();

    await _player.setAudioSource(ConcatenatingAudioSource(children: audioSources));
    await _player.play();
  }

  Future<void> playSample() async {
    await _player.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
    _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }
}
