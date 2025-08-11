import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/playlist_repository.dart';
import '../services/audio_handler.dart';
import 'select_song_screen.dart';

class PlayerScreen extends StatelessWidget {
  final Playlist playlist;

  const PlayerScreen({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioHandler = Provider.of<MusicAudioHandler>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.title),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 2,
      ),
      body: playlist.songs.isEmpty
          ? const Center(
              child: Text('No hay canciones en esta playlist'),
            )
          : ListView.separated(
              itemCount: playlist.songs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final song = playlist.songs[index];
                return ListTile(
                  title: Text(song.title, style: theme.textTheme.titleMedium),
                  subtitle: Text(song.artist, style: theme.textTheme.bodyMedium),
                  trailing: Icon(Icons.play_arrow, color: theme.colorScheme.primary),
                  onTap: () async {
                    // Reproducir lista completa desde esta canción
                    final startIndex = index;
                    await audioHandler.setQueueFromSongs(playlist.songs.sublist(startIndex));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final selectedSong = await Navigator.push<Song>(
            context,
            MaterialPageRoute(
              builder: (_) => SelectSongScreen(
                allSongs: getAllAvailableSongs(),
              ),
            ),
          );

          if (selectedSong != null) {
            final playlistRepo = context.read<PlaylistRepository>();
            await playlistRepo.addSongToPlaylist(playlist.id, selectedSong);
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar canción',
      ),
    );
  }

  List<Song> getAllAvailableSongs() {
    // Esto idealmente vendría de un repositorio o base de datos
    return [
      Song(
        id: '1',
        title: 'Ketu TE Cre',
        artist: 'Bad Bunny',
        album: 'Debi tirar mas fotos',
        url: 'assets/audio/08 Bad Bunny - KETU TeCRE.mp3',
        duration: 410,
        artUri: 'assets/images/debi-tirar-mas-fotos.jpg',
      ),
      Song(
        id: '2',
        title: 'Museo',
        artist: 'Rauw Alejandro',
        album: 'Trap Cake Vol.2',
        url: 'assets/audio/01-Rauw-Alejandro-Museo (1).mp3',
        duration: 419,
        artUri: 'assets/images/trap-cake-vol.2-a8e91cd2.jpg',
      ),
      Song(
        id: '3',
        title: 'La Inocente',
        artist: 'Mora',
        album: 'Microdosis',
        url: 'assets/audio/Mora Ft. Feid - La Inocente.mp3',
        duration: 322,
        artUri: 'assets/images/Microdosis.jpg',
      ),
    ];
  }
}
