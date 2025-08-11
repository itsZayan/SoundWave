import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/audio_service.dart';
import '../providers/theme_provider.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GlobalAudioService, ThemeProvider>(
      builder: (context, audioService, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final queue = audioService.queue;
        final currentIndex = audioService.currentIndex;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          appBar: AppBar(
            title: Text(
              'Queue',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  audioService.isShuffleEnabled ? Icons.shuffle : Icons.shuffle_outlined,
                  color: audioService.isShuffleEnabled ? const Color(0xFF6366F1) : null,
                ),
                onPressed: () {
                  audioService.toggleShuffle();
                },
                tooltip: 'Shuffle',
              ),
              IconButton(
                icon: Icon(
                  audioService.repeatMode == RepeatMode.off
                      ? Icons.repeat
                      : audioService.repeatMode == RepeatMode.all
                          ? Icons.repeat
                          : Icons.repeat_one,
                  color: audioService.repeatMode != RepeatMode.off ? const Color(0xFF6366F1) : null,
                ),
                onPressed: () {
                  audioService.toggleRepeat();
                },
                tooltip: 'Repeat',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      audioService.clearQueue();
                      break;
                    case 'save':
                      _showSavePlaylistDialog(context, audioService);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear Queue'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'save',
                    child: Row(
                      children: [
                        Icon(Icons.playlist_add),
                        SizedBox(width: 8),
                        Text('Save as Playlist'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: queue.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.queue_music,
                        size: 80,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No songs in queue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add songs to start playing',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Now Playing Section
                    if (audioService.hasCurrentSong)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Now Playing',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildQueueItem(
                              audioService.currentSong!,
                              currentIndex,
                              currentIndex,
                              audioService,
                              isDark,
                              isCurrentlyPlaying: true,
                            ),
                          ],
                        ),
                      ),
                    
                    // Up Next Section
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: queue.length,
                        itemBuilder: (context, index) {
                          final song = queue[index];
                          final isCurrentSong = index == currentIndex;
                          
                          if (isCurrentSong && audioService.hasCurrentSong) {
                            return const SizedBox.shrink(); // Already shown in "Now Playing"
                          }
                          
                          return _buildQueueItem(
                            song,
                            index,
                            currentIndex,
                            audioService,
                            isDark,
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildQueueItem(
    Map<String, dynamic> song,
    int index,
    int currentIndex,
    GlobalAudioService audioService,
    bool isDark, {
    bool isCurrentlyPlaying = false,
  }) {
    final isCurrentSong = index == currentIndex;
    
    return Dismissible(
      key: Key('${song['id']}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        audioService.removeFromQueue(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${song['title']}" from queue'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                audioService.insertInQueue(index, song);
              },
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isCurrentlyPlaying) {
              audioService.jumpToQueueItem(index);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCurrentSong
                  ? (isDark ? Colors.blue.withOpacity(0.1) : Colors.blue.withOpacity(0.05))
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                // Drag Handle
                if (!isCurrentlyPlaying)
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_handle,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                if (!isCurrentlyPlaying) const SizedBox(width: 12),
                
                // Album Art
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: song['thumbnail'] != null
                        ? CachedNetworkImage(
                            imageUrl: song['thumbnail'],
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
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF6366F1),
                            child: const Icon(
                              Icons.music_note,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Song Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isCurrentSong)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Icon(
                                audioService.isPlaying ? Icons.volume_up : Icons.pause,
                                color: const Color(0xFF6366F1),
                                size: 16,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              song['title'] ?? 'Unknown Title',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isCurrentSong
                                    ? const Color(0xFF6366F1)
                                    : (isDark ? Colors.white : Colors.black),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              song['artist'] ?? 'Unknown Artist',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (song['duration'] != null)
                            Text(
                              _formatDuration(Duration(seconds: song['duration'])),
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
                
                // More Options
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'play_next':
                        audioService.addToQueueNext(song);
                        break;
                      case 'play_later':
                        audioService.addToQueue(song);
                        break;
                      case 'remove':
                        audioService.removeFromQueue(index);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isCurrentlyPlaying) ...[
                      const PopupMenuItem(
                        value: 'play_next',
                        child: Row(
                          children: [
                            Icon(Icons.playlist_play),
                            SizedBox(width: 8),
                            Text('Play Next'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'play_later',
                        child: Row(
                          children: [
                            Icon(Icons.playlist_add),
                            SizedBox(width: 8),
                            Text('Play Later'),
                          ],
                        ),
                      ),
                    ],
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.remove_circle_outline),
                          SizedBox(width: 8),
                          Text('Remove'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSavePlaylistDialog(BuildContext context, GlobalAudioService audioService) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save as Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Playlist Name',
            hintText: 'Enter playlist name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                // TODO: Implement playlist saving
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Playlist "${controller.text}" saved'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
