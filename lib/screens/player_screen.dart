import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io';
import '../providers/music_provider.dart';
import '../providers/theme_provider.dart';
import '../services/download_service.dart';
import '../services/audio_service.dart';
import '../widgets/download_progress_dialog.dart';

class PlayerScreen extends StatefulWidget {
  final Map<String, dynamic> song;

  const PlayerScreen({required this.song, super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  GlobalAudioService? _audioService;
  Timer? _timer;

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  bool get _isVideoFile {
    // Check if it's a video file based on the song metadata
    final localPath = widget.song['localPath'];
    final fileType = widget.song['fileType'];
    
    return (localPath != null && localPath.toString().endsWith('.mp4')) ||
           (fileType != null && fileType == 'video');
  }

  @override
  void initState() {
    super.initState();
    
    print('PlayerScreen: Initializing with song: ${widget.song['title']}');
    print('PlayerScreen: Is video file: $_isVideoFile');
    print('PlayerScreen: Song data: ${widget.song}');
    
    _audioService = Provider.of<GlobalAudioService>(context, listen: false);
    
    if (_isVideoFile && widget.song['isLocal'] == true) {
      print('PlayerScreen: Setting up video player');
      _setupVideoPlayer();
    } else {
      print('PlayerScreen: Setting up audio player');
      // Use global audio service for audio playback
      _setupAudioPlayer();
    }
  }
  
  Future<void> _setupAudioPlayer() async {
    try {
      print('PlayerScreen: Setting up audio player for: ${widget.song['title']}');
      
      // Listen to audio service changes first
      _audioService!.addListener(_updateAudioState);
      
      // Check if the same song is already playing
      final currentSong = _audioService!.currentSong;
      final isSameSong = currentSong != null && 
                         currentSong['id'] == widget.song['id'] &&
                         currentSong['url'] == widget.song['url'];
      
      if (isSameSong && _audioService!.hasCurrentSong) {
        print('PlayerScreen: Same song is already playing, preserving position');
        // Just update the UI state, don't restart playback
        _updateAudioState();
      } else {
        print('PlayerScreen: Starting new song playback');
        // Start playing the new song
        await _audioService!.playSong(widget.song);
      }
      
      // Set up a periodic timer to update state since listeners might not work perfectly
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _updateAudioState();
        }
      });
      
      print('PlayerScreen: Audio player setup completed');
    } catch (e) {
      print('PlayerScreen: Error setting up audio player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _updateAudioState() {
    if (mounted && !_isVideoFile) {
      setState(() {
        _isPlaying = _audioService!.isPlaying;
        _position = _audioService!.position;
        _duration = _audioService!.duration;
      });
    }
  }


  Future<void> _setupVideoPlayer() async {
    try {
      // Get the correct file path
      String filePath = widget.song['url'];
      if (filePath.startsWith('file://')) {
        filePath = filePath.replaceFirst('file://', '');
      }
      
      // Try using localPath if available
      if (widget.song['localPath'] != null) {
        filePath = widget.song['localPath'];
      }
      
      print('Setting up video player for file: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        print('Video file does not exist at path: $filePath');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video file not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      print('File exists, size: ${await file.length()} bytes');
      
      _videoPlayerController = VideoPlayerController.file(file);
      
      // Initialize the video player
      await _videoPlayerController!.initialize();
      
      print('Video initialized - Duration: ${_videoPlayerController!.value.duration}');
      print('Video aspect ratio: ${_videoPlayerController!.value.aspectRatio}');
      print('Video has error: ${_videoPlayerController!.value.hasError}');
      if (_videoPlayerController!.value.hasError) {
        print('Video error: ${_videoPlayerController!.value.errorDescription}');
      }
      
      // Set volume to maximum (1.0 = 100%)
      await _videoPlayerController!.setVolume(1.0);
      print('Video volume set to: ${_videoPlayerController!.value.volume}');
      
      // Set up listeners for video player
      _videoPlayerController!.addListener(() {
        if (mounted) {
          setState(() {
            _position = _videoPlayerController!.value.position;
            _duration = _videoPlayerController!.value.duration;
            _isPlaying = _videoPlayerController!.value.isPlaying;
          });
        }
      });
      
      setState(() {});
      
      if (mounted) {
        Provider.of<MusicProvider>(context, listen: false).setCurrentSong(widget.song);
      }
      
      // Auto-play the video
      await _videoPlayerController!.play();
      _isPlaying = true;
      
      print('Video player initialized successfully with audio support');
    } catch (e) {
      print('Error initializing video player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _audioService?.removeListener(_updateAudioState);
    super.dispose();
  }

  Future<void> _downloadSong() async {
    final downloadService = DownloadService();
    final youtubeUrl = widget.song['youtubeUrl'];
    final GlobalKey<DownloadProgressDialogState> progressKey = GlobalKey<DownloadProgressDialogState>();
    
    if (youtubeUrl != null) {
      // Show enhanced download progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return DownloadProgressDialog(
            key: progressKey,
            title: widget.song['title'] ?? 'Unknown Title',
            videoId: widget.song['id'],
            onCancel: (videoId) {
              downloadService.cancelDownload(videoId);
            },
          );
        },
      );
      
      try {
        final filePath = await downloadService.downloadAudio(
          youtubeUrl,
          onProgress: (progress, received, total) {
            progressKey.currentState?.updateProgress(progress, received, total);
          },
          onComplete: () {
            progressKey.currentState?.setCompleted();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download completed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          onError: (error) {
            progressKey.currentState?.setError(error);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Download failed: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      } catch (e) {
        progressKey.currentState?.setError(e.toString());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Consumer<GlobalAudioService>(
      builder: (context, audioService, child) {
        // Update local state from audio service for audio files
        if (!_isVideoFile && audioService.hasCurrentSong) {
          _isPlaying = audioService.isPlaying;
          _position = audioService.position;
          _duration = audioService.duration;
        }
        
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            title: Text(
              'Now Playing',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black,
            elevation: 0,
            actions: [
              // Auto-play toggle button
              Consumer<GlobalAudioService>(
                builder: (context, audioService, child) {
                  return IconButton(
                    icon: Icon(
                      audioService.isAutoPlayEnabled ? Icons.playlist_play : Icons.playlist_remove,
                      color: audioService.isAutoPlayEnabled ? const Color(0xFF6366F1) : (isDark ? Colors.white : Colors.black),
                    ),
                    onPressed: () {
                      audioService.toggleAutoPlay();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            audioService.isAutoPlayEnabled 
                                ? 'Auto-play enabled' 
                                : 'Auto-play disabled'
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    tooltip: audioService.isAutoPlayEnabled ? 'Disable Auto-play' : 'Enable Auto-play',
                  );
                },
              ),
              if (widget.song['youtubeUrl'] != null)
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _downloadSong,
                  tooltip: 'Download',
                ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // Pause audio/video but don't stop completely to allow background play
                  if (_isVideoFile && _videoPlayerController != null) {
                    _videoPlayerController!.pause();
                  } else {
                    _audioService?.pause();
                  }
                  Navigator.of(context).pop();
                },
                tooltip: 'Close',
              ),
            ],
          ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
        // Album Art / Video Player
        _isVideoFile ? _buildVideoPlayer() : _buildAlbumArt(),
                const SizedBox(height: 40),
                // Song Info
                _buildSongInfo(isDark),
                const SizedBox(height: 30),
                // Progress Bar
                _buildSeekBar(isDark),
                const SizedBox(height: 40),
                // Control Buttons
                _buildControlButtons(isDark),
                const SizedBox(height: 30),
                // Shuffle and Repeat Controls
                _buildShuffleRepeatControls(isDark),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: widget.song['thumbnail'] != null
            ? CachedNetworkImage(
                imageUrl: widget.song['thumbnail'],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF6366F1),
                  child: const Icon(
                    Icons.music_note,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              )
            : Container(
                color: const Color(0xFF6366F1),
                child: const Icon(
                  Icons.music_note,
                  size: 80,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSongInfo(bool isDark) {
    return Column(
      children: [
        Text(
          widget.song['title'] ?? 'Unknown Title',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          widget.song['artist'] ?? 'Unknown Artist',
          style: TextStyle(
            fontSize: 18,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControlButtons(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous track
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
            borderRadius: BorderRadius.circular(50),
          ),
          child: IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: _playPrevious,
            iconSize: 30,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        // Backward 10 seconds
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
            borderRadius: BorderRadius.circular(50),
          ),
          child: IconButton(
            icon: const Icon(Icons.replay_10),
            onPressed: _seekBackward,
            iconSize: 30,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        // Play/Pause
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF6366F1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: _playPause,
            iconSize: 40,
            color: Colors.white,
          ),
        ),
        // Forward 10 seconds
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
            borderRadius: BorderRadius.circular(50),
          ),
          child: IconButton(
            icon: const Icon(Icons.forward_10),
            onPressed: _seekForward,
            iconSize: 30,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        // Next track
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[200],
            borderRadius: BorderRadius.circular(50),
          ),
          child: IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _playNext,
            iconSize: 30,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

 Widget _buildVideoPlayer() {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) {
      return Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      );
    }
    
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ),
            // Video controls overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoPlayerController!.value.isPlaying) {
                      _videoPlayerController!.pause();
                      _isPlaying = false;
                    } else {
                      _videoPlayerController!.play();
                      _isPlaying = true;
                    }
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: !_isPlaying ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeekBar(bool isDark) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF6366F1),
            inactiveTrackColor: isDark ? Colors.grey[700] : Colors.grey[300],
            thumbColor: const Color(0xFF6366F1),
            overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
            onChanged: (value) {
              final newPosition = Duration(seconds: value.toInt());
              if (_isVideoFile && _videoPlayerController != null) {
                _videoPlayerController!.seekTo(newPosition);
              } else {
                _audioService?.seek(newPosition);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _playPause() {
    if (_isVideoFile && _videoPlayerController != null) {
      setState(() {
        if (_isPlaying) {
          _videoPlayerController!.pause();
          _isPlaying = false;
        } else {
          _videoPlayerController!.play();
          _isPlaying = true;
        }
      });
    } else {
      if (_audioService?.isPlaying == true) {
        _audioService?.pause();
      } else {
        _audioService?.play();
      }
    }
  }

  void _seekBackward() {
    final newPosition = _position - const Duration(seconds: 10);
    if (_isVideoFile && _videoPlayerController != null) {
      _videoPlayerController!.seekTo(newPosition.isNegative ? Duration.zero : newPosition);
    } else {
      _audioService?.seek(newPosition.isNegative ? Duration.zero : newPosition);
    }
  }

  void _seekForward() {
    final newPosition = _position + const Duration(seconds: 10);
    if (_isVideoFile && _videoPlayerController != null) {
      _videoPlayerController!.seekTo(newPosition > _duration ? _duration : newPosition);
    } else {
      _audioService?.seek(newPosition > _duration ? _duration : newPosition);
    }
  }

  void _playPrevious() {
    if (_audioService != null && !_isVideoFile) {
      _audioService!.playPrevious();
    }
  }

  void _playNext() {
    if (_audioService != null && !_isVideoFile) {
      _audioService!.playNext();
    }
  }

  Widget _buildShuffleRepeatControls(bool isDark) {
    if (_isVideoFile) {
      return const SizedBox.shrink(); // Don't show for video files
    }
    
    return Consumer<GlobalAudioService>(
      builder: (context, audioService, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Shuffle button
            Container(
              decoration: BoxDecoration(
                color: audioService.isShuffleEnabled 
                    ? const Color(0xFF6366F1).withOpacity(0.2)
                    : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: const Icon(Icons.shuffle),
                onPressed: () {
                  audioService.toggleShuffle();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        audioService.isShuffleEnabled 
                            ? 'Shuffle enabled' 
                            : 'Shuffle disabled'
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                iconSize: 24,
                color: audioService.isShuffleEnabled 
                    ? const Color(0xFF6366F1)
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
            // Repeat button
            Container(
              decoration: BoxDecoration(
                color: audioService.repeatMode != RepeatMode.off 
                    ? const Color(0xFF6366F1).withOpacity(0.2)
                    : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[200]),
                borderRadius: BorderRadius.circular(50),
              ),
              child: IconButton(
                icon: Icon(
                  audioService.repeatMode == RepeatMode.one 
                      ? Icons.repeat_one
                      : Icons.repeat,
                ),
                onPressed: () {
                  audioService.toggleRepeat();
                  String message = '';
                  switch (audioService.repeatMode) {
                    case RepeatMode.off:
                      message = 'Repeat disabled';
                      break;
                    case RepeatMode.all:
                      message = 'Repeat all enabled';
                      break;
                    case RepeatMode.one:
                      message = 'Repeat one enabled';
                      break;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                iconSize: 24,
                color: audioService.repeatMode != RepeatMode.off 
                    ? const Color(0xFF6366F1)
                    : (isDark ? Colors.white : Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
