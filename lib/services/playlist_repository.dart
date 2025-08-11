import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistRepository extends ChangeNotifier {
  static const String _boxName = 'playlistsBox';
  late Box<Playlist> _box;
  List<Playlist> _playlists = [];

  PlaylistRepository();

  // Este método debe llamarse después de inicializar Hive (Hive.initFlutter())
  Future<void> init() async {
    _box = await Hive.openBox<Playlist>(_boxName);
    _playlists = _box.values.toList();
    notifyListeners();

    // Opcional: escuchar cambios en la caja para actualizar la lista automáticamente
    _box.watch().listen((event) {
      _playlists = _box.values.toList();
      notifyListeners();
    });
  }

  // Devuelve lista inmutable para evitar modificaciones externas
  List<Playlist> get playlists => List.unmodifiable(_playlists);

  List<Playlist> getAllPlaylists() => playlists;

  Future<void> addPlaylist(Playlist playlist) async {
    await _box.put(playlist.id, playlist);
    // _playlists y notifyListeners se actualizan automáticamente por listener
  }

  Future<void> removePlaylist(Playlist playlist) async {
    await _box.delete(playlist.id);
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final playlist = _box.get(playlistId);
    if (playlist != null) {
      playlist.songs.add(song);
      await _box.put(playlistId, playlist);
    }
  }
}
