import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

class MusicProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _library = [];
  final List<Map<String, dynamic>> _playlists = [];
  final List<Map<String, dynamic>> _downloadedSongs = [];
  final List<Map<String, dynamic>> _importedSongs = [];
  final List<Map<String, dynamic>> _currentQueue = [];
  
  Map<String, dynamic>? _currentSong;
  bool _isPlaying = false;
  bool _loading = false;
  bool _isShuffled = false;
  bool _isAutoPlayEnabled = true;
  bool _isRepeatEnabled = false;
  int _currentQueueIndex = 0;
  
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  List<Map<String, dynamic>> get library => _library;
  List<Map<String, dynamic>> get playlists => _playlists;
  List<Map<String, dynamic>> get downloadedSongs => _downloadedSongs;
  List<Map<String, dynamic>> get importedSongs => _importedSongs;
  List<Map<String, dynamic>> get currentQueue => _currentQueue;
  List<Map<String, dynamic>> get recentSongs => _library.where((song) => song['playCount'] != null && song['playCount'] > 0).take(10).toList();
  
  Map<String, dynamic>? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get loading => _loading;
  bool get isShuffled => _isShuffled;
  bool get isAutoPlayEnabled => _isAutoPlayEnabled;
  bool get isRepeatEnabled => _isRepeatEnabled;
  int get currentQueueIndex => _currentQueueIndex;
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

  // ========== NEW COMPREHENSIVE FEATURES ==========

  // Auto-play and shuffle functionality
  void toggleAutoPlay() {
    _isAutoPlayEnabled = !_isAutoPlayEnabled;
    _saveSettings();
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    if (_isShuffled) {
      _shuffleQueue();
    } else {
      // Restore original order
      _currentQueue.sort((a, b) => a['originalIndex'].compareTo(b['originalIndex']));
    }
    _saveSettings();
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeatEnabled = !_isRepeatEnabled;
    _saveSettings();
    notifyListeners();
  }

  void _shuffleQueue() {
    if (_currentQueue.isNotEmpty) {
      final random = Random();
      for (int i = _currentQueue.length - 1; i > 0; i--) {
        int j = random.nextInt(i + 1);
        var temp = _currentQueue[i];
        _currentQueue[i] = _currentQueue[j];
        _currentQueue[j] = temp;
      }
    }
  }

  // Queue management
  void playQueue(List<Map<String, dynamic>> songs, int startIndex) {
    _currentQueue.clear();
    _currentQueue.addAll(songs.asMap().entries.map((entry) {
      final song = Map<String, dynamic>.from(entry.value);
      song['originalIndex'] = entry.key;
      return song;
    }));
    _currentQueueIndex = startIndex;
    
    if (_isShuffled) {
      _shuffleQueue();
    }
    
    if (_currentQueue.isNotEmpty) {
      playSong(_currentQueue[_currentQueueIndex]);
    }
  }

  void shuffleAll() {
    if (_library.isNotEmpty) {
      _isShuffled = true;
      playQueue(_library, 0);
    }
  }

  // Next/Previous functionality
  void playNext() {
    if (_currentQueue.isEmpty) return;
    
    if (_isRepeatEnabled && _currentQueueIndex == _currentQueue.length - 1) {
      _currentQueueIndex = 0;
    } else if (_currentQueueIndex < _currentQueue.length - 1) {
      _currentQueueIndex++;
    } else {
      return; // End of queue
    }
    
    playSong(_currentQueue[_currentQueueIndex]);
  }

  void playPrevious() {
    if (_currentQueue.isEmpty) return;
    
    if (_currentQueueIndex > 0) {
      _currentQueueIndex--;
    } else if (_isRepeatEnabled) {
      _currentQueueIndex = _currentQueue.length - 1;
    } else {
      return; // Beginning of queue
    }
    
    playSong(_currentQueue[_currentQueueIndex]);
  }

  // Song completion handler for auto-play
  void onSongComplete() {
    if (_isAutoPlayEnabled) {
      playNext();
    }
  }

  // Import songs from device
  Future<void> importSongsFromDevice() async {
    try {
      // Request storage permission
      if (await Permission.storage.request().isGranted) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: true,
        );
        
        if (result != null) {
          for (PlatformFile file in result.files) {
            if (file.path != null) {
              final song = {
                'id': DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString(),
                'title': file.name.split('.').first,
                'artist': 'Unknown Artist',
                'filePath': file.path,
                'isImported': true,
                'isDownloaded': false,
                'duration': 0,
                'addedAt': DateTime.now().toIso8601String(),
                'playCount': 0,
              };
              
              _importedSongs.add(song);
              _library.add(song);
            }
          }
          
          await _saveLibrary();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error importing songs: $e');
    }
  }

  // Mark song as downloaded
  void markSongAsDownloaded(Map<String, dynamic> song, String localPath) {
    song['isDownloaded'] = true;
    song['localPath'] = localPath;
    song['downloadedAt'] = DateTime.now().toIso8601String();
    
    if (!_downloadedSongs.any((s) => s['id'] == song['id'])) {
      _downloadedSongs.add(song);
    }
    
    _saveLibrary();
    notifyListeners();
  }

  // Track play count and history
  void incrementPlayCount(Map<String, dynamic> song) {
    song['playCount'] = (song['playCount'] ?? 0) + 1;
    song['lastPlayedAt'] = DateTime.now().toIso8601String();
    
    // Add to imported songs if it's an imported file and played for first time
    if (song['isImported'] == true && !_importedSongs.any((s) => s['id'] == song['id'])) {
      _importedSongs.add(song);
    }
    
    _saveLibrary();
    notifyListeners();
  }

  // Reorder playlist songs
  Future<void> reorderPlaylistSongs(String playlistId, int oldIndex, int newIndex) async {
    final playlistIndex = _playlists.indexWhere((playlist) => playlist['id'] == playlistId);
    if (playlistIndex != -1) {
      final songs = List<Map<String, dynamic>>.from(_playlists[playlistIndex]['songs']);
      
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final song = songs.removeAt(oldIndex);
      songs.insert(newIndex, song);
      
      _playlists[playlistIndex]['songs'] = songs;
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('playlists', jsonEncode(_playlists));
        notifyListeners();
      } catch (error) {
        debugPrint('Error reordering playlist songs: $error');
      }
    }
  }

  // Get playlist thumbnail (first song's thumbnail)
  String? getPlaylistThumbnail(Map<String, dynamic> playlist) {
    final songs = playlist['songs'] as List;
    if (songs.isNotEmpty) {
      return songs.first['thumbnail'] ?? songs.first['albumArt'];
    }
    return null;
  }

  // Advanced seeking with duration
  void seekToSeconds(int seconds) {
    final newPosition = Duration(seconds: seconds);
    seek(newPosition);
  }

  void seekForward30() {
    final newPosition = _position + const Duration(seconds: 30);
    _position = newPosition > _duration ? _duration : newPosition;
    notifyListeners();
  }

  void seekBackward30() {
    final newPosition = _position - const Duration(seconds: 30);
    _position = newPosition.isNegative ? Duration.zero : newPosition;
    notifyListeners();
  }

  // Filter methods for library
  List<Map<String, dynamic>> getDownloadedSongs() {
    return _library.where((song) => song['isDownloaded'] == true).toList();
  }

  List<Map<String, dynamic>> getImportedSongs() {
    return _library.where((song) => song['isImported'] == true).toList();
  }

  List<Map<String, dynamic>> getRecentlyPlayed() {
    return _library
        .where((song) => song['lastPlayedAt'] != null)
        .toList()
        ..sort((a, b) => DateTime.parse(b['lastPlayedAt'])
            .compareTo(DateTime.parse(a['lastPlayedAt'])))
        ..take(20);
  }

  // Persistence helpers
  Future<void> _saveLibrary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('library', jsonEncode(_library));
    } catch (error) {
      debugPrint('Error saving library: $error');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAutoPlayEnabled', _isAutoPlayEnabled);
      await prefs.setBool('isShuffled', _isShuffled);
      await prefs.setBool('isRepeatEnabled', _isRepeatEnabled);
    } catch (error) {
      debugPrint('Error saving settings: $error');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAutoPlayEnabled = prefs.getBool('isAutoPlayEnabled') ?? true;
      _isShuffled = prefs.getBool('isShuffled') ?? false;
      _isRepeatEnabled = prefs.getBool('isRepeatEnabled') ?? false;
    } catch (error) {
      debugPrint('Error loading settings: $error');
    }
  }

  // Search functionality
  List<Map<String, dynamic>> searchSongs(String query) {
    if (query.isEmpty) return _library;
    
    final lowerQuery = query.toLowerCase();
    return _library.where((song) {
      final title = (song['title'] ?? '').toString().toLowerCase();
      final artist = (song['artist'] ?? '').toString().toLowerCase();
      return title.contains(lowerQuery) || artist.contains(lowerQuery);
    }).toList();
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    _library.clear();
    _playlists.clear();
    _downloadedSongs.clear();
    _importedSongs.clear();
    _currentQueue.clear();
    _currentSong = null;
    _isPlaying = false;
    _currentQueueIndex = 0;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('library');
      await prefs.remove('playlists');
      notifyListeners();
    } catch (error) {
      debugPrint('Error clearing data: $error');
    }
  }
}
