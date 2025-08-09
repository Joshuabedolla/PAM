import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import '../models/playlist.dart';
import '../services/playlist_repository.dart';
import '../services/audio_handler.dart';
import 'player_screen.dart';
import 'mini_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<PlaylistRepository>().getAllPlaylists();
    final audioHandler = Provider.of<AudioHandler>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Music_App 🎵"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: playlists.isEmpty
                ? const Center(child: Text("No hay playlists aún"))
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        "Tus Playlists",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: playlists.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final playlist = playlists[index];
                            return GestureDetector(
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
                              child: Container(
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: Image.asset(
                                            playlist.songs.isNotEmpty
                                                ? playlist.songs.first.artUri
                                                : 'assets/images/default_cover.jpg',
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 8,
                                          bottom: 8,
                                          child: CircleAvatar(
                                            backgroundColor: theme.colorScheme.secondary.withOpacity(0.9),
                                            child: const Icon(Icons.play_arrow, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        playlist.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        "${playlist.songs.length} canciones",
                                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          // MiniPlayer fijo abajo
          MiniPlayer(audioHandler: audioHandler),
        ],
      ),
    );
  }
}
