import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:provider/provider.dart';
import 'services/playlist_repository.dart';
import 'services/audio_handler.dart';
import 'ui/home_screen.dart';

import 'models/song.dart';
import 'models/playlist.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive con Flutter
  await Hive.initFlutter();

  // Registra los adaptadores generados para tus modelos
  Hive.registerAdapter(SongAdapter());
  Hive.registerAdapter(PlaylistAdapter());

  final audioHandler = await initAudioHandler();

  final playlistRepo = PlaylistRepository();
  await playlistRepo.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PlaylistRepository>.value(value: playlistRepo),
        Provider<MusicAudioHandler>.value(value: audioHandler as MusicAudioHandler),
      ],
      child: const MyApp(),
    ),
  );
}

Future<AudioHandler> initAudioHandler() async {
  return await AudioService.init(
    builder: () => MusicAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music.channel.audio',
      androidNotificationChannelName: 'Music playback',
      androidNotificationOngoing: true,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      // Padding para no ocultar contenido debajo del mini reproductor
      Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: const HomeScreen(),
      ),
      const Center(child: Text('Buscar')),
      const Center(child: Text('Tu Biblioteca')),
    ];

    return MaterialApp(
      title: 'Music App 1',
      theme: musicAppTheme,
      home: Scaffold(
        body: Stack(
          children: [
            screens[_selectedIndex],
            const Align(
              alignment: Alignment.bottomCenter,
              child: MiniPlayer(),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (mounted) {
              setState(() => _selectedIndex = index);
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
            BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Biblioteca'),
          ],
        ),
      ),
    );
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioHandler = Provider.of<MusicAudioHandler>(context);

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        return Container(
          height: 70,
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: mediaItem.artUri != null
                    ? Image.network(
                        mediaItem.artUri!.toString(),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mediaItem.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      mediaItem.artist ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, stateSnapshot) {
                  final playing = stateSnapshot.data?.playing ?? false;
                  return IconButton(
                    icon: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () => playing ? audioHandler.pause() : audioHandler.play(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
