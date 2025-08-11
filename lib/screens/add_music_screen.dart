import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/music_provider.dart';
import '../services/youtube_service.dart';
import '../services/download_service.dart';
import '../services/floating_download_manager.dart';
import '../widgets/download_progress_dialog.dart';
import 'player_screen.dart';

class AddMusicScreen extends StatefulWidget {
  const AddMusicScreen({super.key});

  @override
  State<AddMusicScreen> createState() => _AddMusicScreenState();
}

class _AddMusicScreenState extends State<AddMusicScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  int _downloadProgress = 0;
  Map<String, dynamic>? _videoInfo;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleLinkChange(String link) async {
    final videoId = YouTubeService.extractVideoId(link);
    
    if (videoId != null) {
      try {
        final info = await YouTubeService.getVideoInfo(link);
        setState(() {
          _videoInfo = info;
        });
      } catch (error) {
        // Even if we can't get info from API, create basic info
        setState(() {
          _videoInfo = {
            'id': videoId,
            'title': 'YouTube Video $videoId',
            'artist': 'Unknown Artist',
            'thumbnail': 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
            'duration': '0:00',
          };
        });
      }
    } else {
      setState(() {
        _videoInfo = null;
      });
    }
  }


  Future<void> _updateProgress(int progress) async {
    if (mounted) {
      setState(() {
        _downloadProgress = progress;
      });
    }
  }

  Future<void> _playVideo() async {
    if (_videoInfo == null) return;
    
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get audio stream URL
      final audioUrl = await YouTubeService.getAudioStreamUrl(_urlController.text.trim());
      if (audioUrl != null) {
        final song = {
          'id': _videoInfo!['id'],
          'title': _videoInfo!['title'],
          'artist': _videoInfo!['channel'] ?? _videoInfo!['artist'],
          'thumbnail': _videoInfo!['thumbnail'],
          'duration': _videoInfo!['duration'] ?? 0,
          'url': audioUrl,
          'youtubeUrl': _urlController.text.trim(),
        };
        
        musicProvider.playSong(song);
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerScreen(song: song),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDownloadOptions() async {
    if (_videoInfo == null) return;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Video thumbnail and details
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(_videoInfo!['thumbnail'] ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _videoInfo!['title'] ?? 'Unknown Title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _videoInfo!['channel'] ?? _videoInfo!['artist'] ?? 'Unknown Channel',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Download Audio (MP3)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'High quality audio will be downloaded to your device.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startDownload();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Download Audio'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startDownload() async {
    if (_videoInfo == null) return;

    final downloadService = DownloadService();
    final GlobalKey<DownloadProgressDialogState> progressKey = GlobalKey<DownloadProgressDialogState>();
    final url = _urlController.text.trim();
    final videoId = _videoInfo!['id'];
    final title = _videoInfo!['title'] ?? 'Unknown Title';
    final thumbnail = _videoInfo!['thumbnail'] ?? '';
    
    // Add to floating download manager
    final floatingDownloadManager = Provider.of<FloatingDownloadManager>(context, listen: false);
    final downloadItem = DownloadItem(
      id: videoId,
      title: title,
      thumbnail: thumbnail,
      onCancel: () => downloadService.cancelDownload(videoId),
    );
    floatingDownloadManager.addDownload(downloadItem);
    
    // Show enhanced download progress dialog that can be dismissed
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (context) {
        return DownloadProgressDialog(
          key: progressKey,
          title: title,
          videoId: videoId,
          onCancel: (videoId) {
            downloadService.cancelDownload(videoId);
            floatingDownloadManager.removeDownload(videoId);
          },
        );
      },
    );
    
    try {
      await downloadService.downloadAudio(
        url,
        onProgress: (progress, received, total) {
          // Update both dialog and floating download
          progressKey.currentState?.updateProgress(progress, received, total);
          floatingDownloadManager.updateDownload(videoId, progress: progress * 100);
        },
        onComplete: () {
          progressKey.currentState?.setCompleted();
          floatingDownloadManager.updateDownload(videoId, isCompleted: true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Audio download completed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        onError: (error) {
          progressKey.currentState?.setError(error);
          floatingDownloadManager.updateDownload(videoId, isError: true, errorMessage: error);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Audio download failed: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );

      // Clear the form after successful download
      if (mounted) {
        setState(() {
          _urlController.clear();
          _videoInfo = null;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Music'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add from YouTube Link',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        hintText: 'Enter YouTube video link',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                      onChanged: _handleLinkChange,
                      maxLines: 1,
                      textInputAction: TextInputAction.done,
                    ),
                    
                    if (_videoInfo != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _videoInfo!['title'] ?? 'Unknown Title',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _videoInfo!['artist'] ?? 'Unknown Artist',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.labelMedium?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading || _videoInfo == null ? null : _playVideo,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    
                    ElevatedButton.icon(
                      onPressed: _isLoading || _videoInfo == null ? null : _showDownloadOptions,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(
                        _isLoading 
                            ? 'Downloading... $_downloadProgress%' 
                            : 'Download',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _downloadProgress / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
