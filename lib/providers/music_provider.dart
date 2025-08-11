import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MusicProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _library = [];
  final List<Map<String, dynamic>> _playlists = [];
  Map<String, dynamic>? _currentSong;
  bool _isPlaying = false;
  bool _loading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  List<Map<String, dynamic>> get library => _library;
  List<Map<String, dynamic>> get playlists => _playlists;
  Map<String, dynamic>? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get loading => _loading;
  Duration get position => _position;
  Duration get duration => _duration;
  
  String get positionText {
    final minutes = _position.inMinutes;
    final seconds = _position.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  String get durationText {
    final minutes = _duration.inMinutes;
    final seconds = _duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  MusicProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final libraryString = prefs.getString('library');
      final playlistsString = prefs.getString('playlists');
      
      if (libraryString != null) {
        final List<dynamic> libraryJson = jsonDecode(libraryString);
        _library.addAll(List<Map<String, dynamic>>.from(libraryJson));
      }
      
      if (playlistsString != null) {
        final List<dynamic> playlistsJson = jsonDecode(playlistsString);
        _playlists.addAll(List<Map<String, dynamic>>.from(playlistsJson));
      }
    } catch (error) {
      debugPrint('Error loading initial data: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToLibrary(Map<String, dynamic> song) async {
    song['addedAt'] = DateTime.now().toIso8601String();
    _library.add(song);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('library', jsonEncode(_library));
      notifyListeners();
    } catch (error) {
      debugPrint('Error adding to library: $error');
    }
  }

  Future<void> removeFromLibrary(String songId) async {
    _library.removeWhere((song) => song['id'] == songId);
    if (_currentSong != null && _currentSong!['id'] == songId) {
      stopPlaying();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('library', jsonEncode(_library));
      notifyListeners();
    } catch (error) {
      debugPrint('Error removing from library: $error');
    }
  }

  Future<void> createPlaylist(String name) async {
    final newPlaylist = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'songs': [],
      'createdAt': DateTime.now().toIso8601String(),
    };
    _playlists.add(newPlaylist);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('playlists', jsonEncode(_playlists));
      notifyListeners();
    } catch (error) {
      debugPrint('Error creating playlist: $error');
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((playlist) => playlist['id'] == playlistId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('playlists', jsonEncode(_playlists));
      notifyListeners();
    } catch (error) {
      debugPrint('Error deleting playlist: $error');
    }
  }

  Future<void> updatePlaylistName(String playlistId, String newName) async {
    final playlistIndex = _playlists.indexWhere((playlist) => playlist['id'] == playlistId);
    if (playlistIndex != -1) {
      _playlists[playlistIndex]['name'] = newName;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('playlists', jsonEncode(_playlists));
        notifyListeners();
      } catch (error) {
        debugPrint('Error updating playlist name: $error');
      }
    }
  }

  Future<void> updatePlaylist(String playlistId, Map<String, dynamic> updatedPlaylist) async {
    final playlistIndex = _playlists.indexWhere((playlist) => playlist['id'] == playlistId);
    if (playlistIndex != -1) {
      _playlists[playlistIndex] = updatedPlaylist;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('playlists', jsonEncode(_playlists));
        notifyListeners();
      } catch (error) {
        debugPrint('Error updating playlist: $error');
      }
    }
  }

  Future<void> addSongToPlaylist(String playlistId, Map<String, dynamic> song) async {
    final playlistIndex = _playlists.indexWhere((playlist) => playlist['id'] == playlistId);
    if (playlistIndex != -1) {
      (_playlists[playlistIndex]['songs'] as List).add(song);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('playlists', jsonEncode(_playlists));
        notifyListeners();
      } catch (error) {
        debugPrint('Error adding song to playlist: $error');
      }
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlistIndex = _playlists.indexWhere((playlist) => playlist['id'] == playlistId);
    if (playlistIndex != -1) {
      (_playlists[playlistIndex]['songs'] as List).removeWhere((song) => song['id'] == songId);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('playlists', jsonEncode(_playlists));
        notifyListeners();
      } catch (error) {
        debugPrint('Error removing song from playlist: $error');
      }
    }
  }

  void setCurrentSong(Map<String, dynamic>? song) {
    _currentSong = song;
    notifyListeners();
  }

  void playSong(Map<String, dynamic> song) {
    _currentSong = song;
    _isPlaying = true;
    notifyListeners();
  }

  void play() {
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  void stopPlaying() {
    _isPlaying = false;
    _currentSong = null;
    notifyListeners();
  }

  void seek(Duration position) {
    _position = position;
    notifyListeners();
  }
  
  void rewind() {
    final newPosition = _position - const Duration(seconds: 10);
    _position = newPosition.isNegative ? Duration.zero : newPosition;
    notifyListeners();
  }
  
  void forward() {
    final newPosition = _position + const Duration(seconds: 10);
    _position = newPosition > _duration ? _duration : newPosition;
    notifyListeners();
  }
  
  void updatePosition(Duration position) {
    _position = position;
    notifyListeners();
  }
  
  void updateDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }
}
