import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:uuid/uuid.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/playlist_repository.dart';
import '../services/audio_handler.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> getAllAvailableSongs() {
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

  @override
  Widget build(BuildContext context) {
    final playlistRepo = context.watch<PlaylistRepository>();
    final playlists = playlistRepo.getAllPlaylists();
    final audioHandler = Provider.of<AudioHandler>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🎧 Mis Playlists',
          style: theme.textTheme.headlineLarge,
        ),
        centerTitle: true,
      ),
      body: playlists.isEmpty
          ? Center(
              child: Text(
                'No hay playlists aún',
                style: theme.textTheme.titleMedium,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () async {
                      if (audioHandler is MusicAudioHandler) {
                        await audioHandler.setQueueFromSongs(playlist.songs);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerScreen(playlist: playlist),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          playlist.songs.isNotEmpty
                              ? playlist.songs.first.artUri
                              : 'assets/images/default_cover.jpg',
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist.title,
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${playlist.songs.length} canciones',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.play_circle_fill,
                          color: theme.colorScheme.secondary,
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final nuevoTitulo = await showDialog<String>(
            context: context,
            builder: (context) {
              String input = '';
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text('Nueva Playlist'),
                content: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Nombre de la playlist',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  onChanged: (value) => input = value,
                  onSubmitted: (_) => Navigator.of(context).pop(input),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(input),
                    child: const Text('Crear'),
                  ),
                ],
              );
            },
          );

          if (nuevoTitulo != null && nuevoTitulo.trim().isNotEmpty) {
            final todasLasCanciones = getAllAvailableSongs();
            final nuevaPlaylist = Playlist(
              id: const Uuid().v4(),
              title: nuevoTitulo.trim(),
              songs: todasLasCanciones,
            );
            playlistRepo.addPlaylist(nuevaPlaylist);
          }
        },
        label: const Text("Agregar Playlist"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
