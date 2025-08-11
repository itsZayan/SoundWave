import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File, Platform;
import 'package:audio_service/audio_service.dart';
import 'audio_handler.dart';

enum RepeatMode {
  off,
  all,
  one,
}

class GlobalAudioService extends ChangeNotifier {
  static final GlobalAudioService _instance = GlobalAudioService._internal();
  factory GlobalAudioService() => _instance;
  GlobalAudioService._internal();

  AudioPlayer? _audioPlayer;
  Map<String, dynamic>? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isVideo = false; // Track if current playback is video
  
  // Queue management
  List<Map<String, dynamic>> _queue = [];
  List<Map<String, dynamic>> _originalQueue = []; // For shuffle
  int _currentIndex = -1;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;
  bool _isAutoPlayEnabled = true; // Auto-play enabled by default
  List<Map<String, dynamic>> _playlistQueue = []; // Current playlist for auto-play
  int _currentPlaylistIndex = -1;
  final Random _random = Random();

  // Getters
  AudioPlayer? get audioPlayer => _audioPlayer;
  Map<String, dynamic>? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get hasCurrentSong => _currentSong != null;

  String get positionText {
    final minutes = _position.inMinutes;
    final seconds = _position.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  bool get isShuffleEnabled => _isShuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;
  bool get isAutoPlayEnabled => _isAutoPlayEnabled;
  List<Map<String, dynamic>> get playlistQueue => List.unmodifiable(_playlistQueue);
  int get currentPlaylistIndex => _currentPlaylistIndex;

  String get durationText {
    final minutes = _duration.inMinutes;
    final seconds = _duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> playSong(Map<String, dynamic> song, {bool isVideo = false}) async {
    try {
      print('AudioService: Starting to play song: ${song['title']}');
      print('AudioService: Song data: $song');
      
      _currentSong = song;
      _isVideo = isVideo;
      _isPlaying = false;
      _position = Duration.zero;
      _duration = Duration.zero;

      // Update audio service notification if available
      await _updateAudioServiceNotification(song, isVideo);

      // Use direct AudioPlayer (simplified for reliability)
      print('AudioService: Using direct AudioPlayer');
      
      // Dispose existing player
      if (_audioPlayer != null) {
        await _audioPlayer!.dispose();
      }

      _audioPlayer = AudioPlayer();

      // Set up listeners
      _audioPlayer!.durationStream.listen((duration) {
        print('AudioService: Duration updated: $duration');
        _duration = duration ?? Duration.zero;
        notifyListeners();
      });

      _audioPlayer!.positionStream.listen((position) {
        _position = position;
        notifyListeners();
      });

      _audioPlayer!.playingStream.listen((isPlaying) {
        print('AudioService: Playing state changed: $isPlaying');
        _isPlaying = isPlaying;
        notifyListeners();
      });
      
      _audioPlayer!.playerStateStream.listen((state) {
        print('AudioService: Player state: $state');
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _position = _duration;
          _handleSongCompletion();
          notifyListeners();
        }
      });

      // Load and play the audio
      if (song['isLocal'] == true && !kIsWeb) {
        // Load from file if it's a local download (not supported on web)
        String? filePath;
        
        // Try localPath first, then url
        if (song['localPath'] != null) {
          filePath = song['localPath'].toString();
        } else if (song['url'] != null) {
          filePath = song['url'].toString();
          if (filePath.startsWith('file://')) {
            filePath = filePath.replaceFirst('file://', '');
          }
        }
        
        if (filePath == null) {
          throw Exception('No file path provided for local audio file');
        }
        
        print('AudioService: Attempting to load local file: $filePath');
        
        // Check if file exists (only on non-web platforms)
        if (!kIsWeb) {
          final file = File(filePath);
          if (await file.exists()) {
            print('AudioService: File exists, loading...');
            await _audioPlayer!.setFilePath(filePath);
          } else {
            throw Exception('Audio file not found at: $filePath');
          }
        }
      } else {
        // Stream from network (works on all platforms)
        String url = song['url'] ?? '';
        if (url.isEmpty) {
          throw Exception('No URL provided for audio streaming');
        }
        print('AudioService: Loading network URL: $url');
        await _audioPlayer!.setUrl(url);
      }

      // Start playback
      print('AudioService: Starting playback...');
      await _audioPlayer!.play();
      
      print('AudioService: Playback started successfully');
      notifyListeners();
    } catch (e) {
      print('AudioService: Error playing song: $e');
      _isPlaying = false;
      _currentSong = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> play() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.play();
    }
  }

  Future<void> pause() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.pause();
    }
  }

  Future<void> stop() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
      await _audioPlayer!.dispose();
      _audioPlayer = null;
    }
    _currentSong = null;
    _isPlaying = false;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_queue.isEmpty) return;

    if (_isShuffleEnabled) {
      _currentIndex = _random.nextInt(_queue.length);
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }

    await playSong(_queue[_currentIndex]);
  }

  Future<void> playPrevious() async {
    if (_queue.isEmpty) return;

    if (_isShuffleEnabled) {
      _currentIndex = _random.nextInt(_queue.length);
    } else {
      _currentIndex = (_currentIndex - 1) % _queue.length;
    }

    await playSong(_queue[_currentIndex]);
  }

  void addToQueue(Map<String, dynamic> song) {
    _queue.add(song);
    _originalQueue.add(song);
    notifyListeners();
  }

  void addToQueueNext(Map<String, dynamic> song) {
    _queue.insert(_currentIndex + 1, song);
    _originalQueue.insert(_currentIndex + 1, song);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    _queue.removeAt(index);
    _originalQueue.removeAt(index);
    if (index == _currentIndex) {
      stop();
    }
    notifyListeners();
  }

  void insertInQueue(int index, Map<String, dynamic> song) {
    _queue.insert(index, song);
    _originalQueue.insert(index, song);
    notifyListeners();
  }

  void jumpToQueueItem(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      playSong(_queue[_currentIndex]);
    }
  }

  void clearQueue() {
    _queue.clear();
    _originalQueue.clear();
    stop();
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    if (_isShuffleEnabled) {
      _queue.shuffle(_random);
    } else {
      _queue = List.from(_originalQueue);
    }
    notifyListeners();
  }

  void toggleRepeat() {
    if (_repeatMode == RepeatMode.off) {
      _repeatMode = RepeatMode.all;
    } else if (_repeatMode == RepeatMode.all) {
      _repeatMode = RepeatMode.one;
    } else {
      _repeatMode = RepeatMode.off;
    }
    notifyListeners();
  }

  void _handleSongCompletion() {
    if (_repeatMode == RepeatMode.one) {
      playSong(_currentSong!);
    } else if (_isAutoPlayEnabled && _playlistQueue.isNotEmpty) {
      _playNextInPlaylist();
    } else if (_queue.isNotEmpty) {
      playNext();
    }
  }

  // Auto-play functionality
  void toggleAutoPlay() {
    _isAutoPlayEnabled = !_isAutoPlayEnabled;
    notifyListeners();
  }

  void setPlaylistQueue(List<Map<String, dynamic>> playlist, int startIndex) {
    _playlistQueue = List.from(playlist);
    _currentPlaylistIndex = startIndex;
    notifyListeners();
  }

  void _playNextInPlaylist() {
    if (_playlistQueue.isEmpty || !_isAutoPlayEnabled) return;
    
    _currentPlaylistIndex++;
    if (_currentPlaylistIndex >= _playlistQueue.length) {
      // Reached end of playlist
      if (_repeatMode == RepeatMode.all) {
        _currentPlaylistIndex = 0; // Loop back to start
      } else {
        // Stop auto-play at end
        return;
      }
    }
    
    final nextSong = _playlistQueue[_currentPlaylistIndex];
    playSong(nextSong);
  }

  void playNextInPlaylist() {
    if (_playlistQueue.isEmpty) return;
    _playNextInPlaylist();
  }

  void playPreviousInPlaylist() {
    if (_playlistQueue.isEmpty) return;
    
    _currentPlaylistIndex--;
    if (_currentPlaylistIndex < 0) {
      _currentPlaylistIndex = _playlistQueue.length - 1; // Loop to end
    }
    
    final previousSong = _playlistQueue[_currentPlaylistIndex];
    playSong(previousSong);
  }

  Future<void> seek(Duration position) async {
    if (_audioPlayer != null) {
      await _audioPlayer!.seek(position);
    }
  }

  Future<void> seekBackward() async {
    final newPosition = _position - const Duration(seconds: 10);
    await seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  Future<void> seekForward() async {
    final newPosition = _position + const Duration(seconds: 10);
    await seek(newPosition > _duration ? _duration : newPosition);
  }

  // Simplified audio service integration
  Future<void> _updateAudioServiceNotification(Map<String, dynamic> song, bool isVideo) async {
    // Skip audio service integration for now to focus on core functionality
    print('AudioService: Notification update skipped for: ${song['title']}');
  }

  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }
}
