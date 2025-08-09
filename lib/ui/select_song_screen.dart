import 'package:flutter/material.dart';
import '../models/song.dart';

class SelectSongScreen extends StatelessWidget {
  final List<Song> allSongs;

  const SelectSongScreen({Key? key, required this.allSongs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona una canción'),
      ),
      body: ListView.separated(
        itemCount: allSongs.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final song = allSongs[index];
          return ListTile(
            leading: song.artUri.isNotEmpty
                ? Image.asset(
                    song.artUri,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.music_note),
            title: Text(song.title, style: theme.textTheme.titleMedium),
            subtitle: Text(song.artist, style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.of(context).pop(song);
            },
          );
        },
      ),
    );
  }
}
