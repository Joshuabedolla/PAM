import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';

class MiniPlayer extends StatelessWidget {
  final AudioHandler audioHandler;

  const MiniPlayer({Key? key, required this.audioHandler}) : super(key: key);

  Stream<MediaItem?> get _currentMediaItemStream => audioHandler.mediaItem;
  Stream<PlaybackState> get _playbackStateStream => audioHandler.playbackState;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: _currentMediaItemStream,
      builder: (context, mediaSnapshot) {
        final mediaItem = mediaSnapshot.data;
        if (mediaItem == null) {
          return const SizedBox(height: 0);
        }
        return StreamBuilder<PlaybackState>(
          stream: _playbackStateStream,
          builder: (context, playbackSnapshot) {
            final playbackState = playbackSnapshot.data;
            final playing = playbackState?.playing ?? false;

            return Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Artwork
                  
Padding(
  padding: const EdgeInsets.all(8.0),
  child: mediaItem.artUri != null
      ? Image.asset(
          mediaItem.artUri!.path,
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

                  // Title and artist
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mediaItem.title,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          mediaItem.artist ?? '',
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Playback controls
                  IconButton(
                    icon: Icon(
                      playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: () {
                      if (playing) {
                        audioHandler.pause();
                      } else {
                        audioHandler.play();
                      }
                    },
                  ),

                  // Stop button
                  IconButton(
                    icon: const Icon(
                      Icons.stop,
                      color: Colors.white54,
                      size: 28,
                    ),
                    onPressed: () {
                      audioHandler.stop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
