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
          id: song.url,  // Por ejemplo: 'assets/audio/archivo.mp3'
          album: song.album,
          title: song.title,
          artist: song.artist,
          duration: Duration(seconds: song.duration),
          artUri: Uri.tryParse(song.artUri),
        )).toList();

    queue.add(mediaItems);

    // Aquí cambia para usar AudioSource.asset en lugar de AudioSource.uri
    final audioSources = mediaItems
        .map((item) => AudioSource.asset(item.id))  // <-- Cambiado a asset
        .toList();

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
