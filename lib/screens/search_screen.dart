import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/theme_provider.dart';
import '../providers/music_provider.dart';
import '../services/youtube_service.dart';
import '../services/download_service.dart';
import '../widgets/download_progress_dialog.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _trendingVideos = [];
  bool _isLoading = false;
  bool _showTrending = true;
  String? _loadingVideoId;

  @override
  void initState() {
    super.initState();
    _loadTrendingVideos();
  }

  Future<void> _loadTrendingVideos() async {
    try {
      final trending = await YouTubeService.getTrendingVideos(maxResults: 15);
      if (mounted) {
        setState(() {
          _trendingVideos = trending;
        });
      }
    } catch (e) {
      print('Error loading trending videos: $e');
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _showTrending = false;
    });

    try {
      final results = await YouTubeService.searchVideos(query, maxResults: 20);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playVideo(Map<String, dynamic> video) async {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    
    setState(() {
      _loadingVideoId = video['id'];
    });
    
    try {
      // Get audio stream URL
      final audioUrl = await YouTubeService.getAudioStreamUrl(video['url']);
      if (audioUrl != null) {
        final song = {
          'id': video['id'],
          'title': video['title'],
          'artist': video['channel'],
          'thumbnail': video['thumbnail'],
          'duration': video['duration'] ?? 0,
          'url': audioUrl,
          'youtubeUrl': video['url'],
        };
        
        musicProvider.playSong(song);
        
        if (mounted) {
          setState(() {
            _loadingVideoId = null;
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
          _loadingVideoId = null;
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

  Future<void> _showDownloadOptions(Map<String, dynamic> video) async {
    bool downloadAudio = true;
    bool downloadVideo = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                          image: NetworkImage(video['thumbnail']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      video['title'] ?? 'Unknown Title',
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
                      video['channel'] ?? 'Unknown Channel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Select download options:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Audio (MP3)'),
                      value: downloadAudio,
                      onChanged: (bool? value) {
                        setState(() {
                          downloadAudio = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Video (MP4)'),
                      value: downloadVideo,
                      onChanged: (bool? value) {
                        setState(() {
                          downloadVideo = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
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
                            onPressed: (downloadAudio || downloadVideo) ? () {
                              Navigator.of(context).pop();
                              _startDownload(video, downloadAudio, downloadVideo);
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Download'),
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
      },
    );
  }

  Future<void> _startDownload(Map<String, dynamic> video, bool downloadAudio, bool downloadVideo) async {
    final downloadService = DownloadService();
    final videoId = video['id'];
    
    // Mark as background download
    downloadService.setBackgroundDownload(videoId, true);
    
    if (downloadVideo && downloadAudio) {
      // Sequential download for both
      await _startSequentialDownload(video, downloadService);
    } else if (downloadVideo) {
      // Video only
      await _startSingleDownload(video, downloadService, 'video');
    } else if (downloadAudio) {
      // Audio only
      await _startSingleDownload(video, downloadService, 'audio');
    }
  }
  
  Future<void> _startSequentialDownload(Map<String, dynamic> video, DownloadService downloadService) async {
    final GlobalKey<DownloadProgressDialogState> progressKey = GlobalKey<DownloadProgressDialogState>();
    final videoId = video['id'];
    String currentType = 'video';
    
    // Show enhanced download progress dialog
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (context) {
        return DownloadProgressDialog(
          key: progressKey,
          title: video['title'] ?? 'Unknown Title',
          videoId: videoId,
          onCancel: (videoId) {
            downloadService.cancelDownload(videoId);
            downloadService.removeBackgroundDownload(videoId);
          },
        );
      },
    ).then((_) {
      // Dialog was dismissed - downloads continue in background
      print('Download dialog dismissed for: ${video['title']}');
    });
    
    try {
      // First download video
      progressKey.currentState?.updateProgress(0.0, 0, 100);
      await downloadService.downloadVideo(
        video['url'],
        onProgress: (progress, received, total) {
          // Show video progress as 0-50%
          final adjustedProgress = progress * 0.5;
          progressKey.currentState?.updateProgress(adjustedProgress, received, total);
        },
        onComplete: () {
          currentType = 'audio';
          progressKey.currentState?.updateProgress(0.5, 50, 100);
        },
        onError: (error) {
          progressKey.currentState?.setError('Video download failed: $error');
          downloadService.removeBackgroundDownload(videoId);
        },
      );
      
      // Then download audio
      await downloadService.downloadAudio(
        video['url'],
        onProgress: (progress, received, total) {
          // Show audio progress as 50-100%
          final adjustedProgress = 0.5 + (progress * 0.5);
          progressKey.currentState?.updateProgress(adjustedProgress, received, total);
        },
        onComplete: () {
          progressKey.currentState?.setCompleted();
          downloadService.removeBackgroundDownload(videoId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Both video and audio downloaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh library if it's visible
            _refreshLibraryIfVisible();
          }
        },
        onError: (error) {
          progressKey.currentState?.setError('Audio download failed: $error');
          downloadService.removeBackgroundDownload(videoId);
        },
      );
    } catch (e) {
      progressKey.currentState?.setError(e.toString());
      downloadService.removeBackgroundDownload(videoId);
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
  
  Future<void> _startSingleDownload(Map<String, dynamic> video, DownloadService downloadService, String type) async {
    final GlobalKey<DownloadProgressDialogState> progressKey = GlobalKey<DownloadProgressDialogState>();
    final videoId = video['id'];
    
    // Show enhanced download progress dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return DownloadProgressDialog(
          key: progressKey,
          title: video['title'] ?? 'Unknown Title',
          videoId: videoId,
          onCancel: (videoId) {
            downloadService.cancelDownload(videoId);
            downloadService.removeBackgroundDownload(videoId);
          },
        );
      },
    );
    
    try {
      if (type == 'video') {
        await downloadService.downloadVideo(
          video['url'],
          onProgress: (progress, received, total) {
            progressKey.currentState?.updateProgress(progress, received, total);
          },
          onComplete: () {
            progressKey.currentState?.setCompleted();
            downloadService.removeBackgroundDownload(videoId);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Video download completed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              _refreshLibraryIfVisible();
            }
          },
          onError: (error) {
            progressKey.currentState?.setError(error);
            downloadService.removeBackgroundDownload(videoId);
          },
        );
      } else {
        await downloadService.downloadAudio(
          video['url'],
          onProgress: (progress, received, total) {
            progressKey.currentState?.updateProgress(progress, received, total);
          },
          onComplete: () {
            progressKey.currentState?.setCompleted();
            downloadService.removeBackgroundDownload(videoId);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Audio download completed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              _refreshLibraryIfVisible();
            }
          },
          onError: (error) {
            progressKey.currentState?.setError(error);
            downloadService.removeBackgroundDownload(videoId);
          },
        );
      }
    } catch (e) {
      progressKey.currentState?.setError(e.toString());
      downloadService.removeBackgroundDownload(videoId);
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
  
  void _refreshLibraryIfVisible() {
    // This will help refresh the library automatically
    // by notifying any listening widgets
    try {
      // We can use a simple approach by posting a frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // The library screen will automatically refresh when it becomes visible again
        // due to its lifecycle methods
      });
    } catch (e) {
      print('Error refreshing library: $e');
    }
  }

  // Removed duplicate _downloadVideo method - functionality is handled by _startDownload

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text(
          'Search Music',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for music on YouTube...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: SpinKitWave(
                      color: const Color(0xFF6366F1),
                      size: 30,
                    ),
                  )
                : _showTrending
                    ? _buildTrendingSection(isDark)
                    : _buildSearchResults(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Trending Music',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        Expanded(
          child: _trendingVideos.isEmpty
              ? Center(
                  child: SpinKitWave(
                    color: const Color(0xFF6366F1),
                    size: 30,
                  ),
                )
              : ListView.builder(
                  itemCount: _trendingVideos.length,
                  itemBuilder: (context, index) {
                    final video = _trendingVideos[index];
                    return _buildVideoTile(video, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(bool isDark) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final video = _searchResults[index];
        return _buildVideoTile(video, isDark);
      },
    );
  }

  Widget _buildVideoTile(Map<String, dynamic> video, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: video['thumbnail'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Icon(Icons.music_note),
            ),
            errorWidget: (context, url, error) => Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
        ),
        title: Text(
          video['title'] ?? 'Unknown Title',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              video['channel'] ?? 'Unknown Channel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (video['viewCount'] != null)
              Text(
                '${YouTubeService.formatNumber(video['viewCount'])} views',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _loadingVideoId == video['id']
                ? Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.play_arrow, color: Color(0xFF6366F1)),
                    onPressed: () => _playVideo(video),
                    tooltip: 'Play',
                  ),
            IconButton(
                    icon: const Icon(Icons.download, color: Colors.green),
                    onPressed: () => _showDownloadOptions(video),
                    tooltip: 'Download',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
