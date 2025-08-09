import 'package:flutter/foundation.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistRepository extends ChangeNotifier {
  final List<Playlist> _playlists = [];

  List<Playlist> getAllPlaylists() => List.unmodifiable(_playlists);

  void addPlaylist(Playlist playlist) {
    _playlists.add(playlist);
    notifyListeners();
  }

  void removePlaylist(Playlist playlist) {
    _playlists.remove(playlist);
    notifyListeners();
  }

  // Nuevo método para agregar canción a una playlist por id
  void addSongToPlaylist(String playlistId, Song song) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index].songs.add(song);
      notifyListeners();
    }
  }
}