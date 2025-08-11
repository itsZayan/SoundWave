import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/audio_service.dart';
import '../providers/theme_provider.dart';
import '../screens/player_screen.dart';
import '../screens/queue_screen.dart';

class BottomMusicPlayer extends StatefulWidget {
  const BottomMusicPlayer({super.key});

  @override
  State<BottomMusicPlayer> createState() => _BottomMusicPlayerState();
}

class _BottomMusicPlayerState extends State<BottomMusicPlayer> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GlobalAudioService, ThemeProvider>(
      builder: (context, audioService, themeProvider, child) {
        // Only show if there's a current song
        if (!audioService.hasCurrentSong) {
          return const SizedBox.shrink();
        }

        final currentSong = audioService.currentSong;
        final isDark = themeProvider.isDarkMode;
        final progress = audioService.duration.inMilliseconds > 0 
            ? audioService.position.inMilliseconds / audioService.duration.inMilliseconds 
            : 0.0;

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! < -10 && !_isExpanded) {
              // Swipe up - expand player
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlayerScreen(song: currentSong!),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Bar
                Container(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
                
                // Main Player Content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(song: currentSong!),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          // Album Art
                          Hero(
                            tag: 'album-art-${currentSong!['id']}',
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: currentSong['thumbnail'] != null
                                    ? CachedNetworkImage(
                                        imageUrl: currentSong['thumbnail'],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: const Color(0xFF6366F1),
                                          child: const Icon(
                                            Icons.music_note,
                                            size: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: const Color(0xFF6366F1),
                                        child: const Icon(
                                          Icons.music_note,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Song Info with Time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentSong['title'] ?? 'Unknown Title',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currentSong['artist'] ?? 'Unknown Artist',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${_formatDuration(audioService.position)} / ${_formatDuration(audioService.duration)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Control Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Previous Track
                              IconButton(
                                icon: const Icon(Icons.skip_previous),
                                onPressed: () {
                                  audioService.playPrevious();
                                },
                                iconSize: 24,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              
                              // Play/Pause
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6366F1),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                                  ),
                                  onPressed: () {
                                    if (audioService.isPlaying) {
                                      audioService.pause();
                                    } else {
                                      audioService.play();
                                    }
                                  },
                                  iconSize: 24,
                                  color: Colors.white,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              
                              // Next Track
                              IconButton(
                                icon: const Icon(Icons.skip_next),
                                onPressed: () {
                                  audioService.playNext();
                                },
                                iconSize: 24,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              
                              // Queue Button
                              IconButton(
                                icon: const Icon(Icons.queue_music),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const QueueScreen(),
                                    ),
                                  );
                                },
                                iconSize: 20,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
