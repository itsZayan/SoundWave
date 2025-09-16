import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final Set<String> _downloadingVideos = {}; // Track downloading videos
  
  // Search history and suggestions
  List<String> _searchHistory = [];
  List<String> _recentArtists = [];
  List<String> _popularSearches = ['music', 'songs', 'latest', 'trending', 'pop', 'rock', 'hip hop'];

  @override
  void initState() {
    super.initState();
    _loadTrendingVideos();
    _loadSearchHistory();
    _loadRecentArtists();
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

  // Load search history from SharedPreferences
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('search_history') ?? [];
      setState(() {
        _searchHistory = history.take(10).toList(); // Keep last 10 searches
      });
    } catch (e) {
      print('Error loading search history: $e');
    }
  }

  // Save search to history
  Future<void> _saveSearchToHistory(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = List<String>.from(_searchHistory);
      
      // Remove if already exists and add to front
      history.remove(query);
      history.insert(0, query);
      
      // Keep only last 10 searches
      if (history.length > 10) {
        history.removeRange(10, history.length);
      }
      
      await prefs.setStringList('search_history', history);
      setState(() {
        _searchHistory = history;
      });
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  // Load recent artists from library
  Future<void> _loadRecentArtists() async {
    try {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      final library = musicProvider.library;
      
      // Extract unique artists from library
      final artists = <String>{};
      for (final song in library) {
        final artist = song['artist'] ?? song['author'];
        if (artist != null && artist != 'Unknown Artist') {
          artists.add(artist);
        }
      }
      
      setState(() {
        _recentArtists = artists.take(8).toList(); // Keep top 8 artists
      });
    } catch (e) {
      print('Error loading recent artists: $e');
    }
  }

  // Clear search history
  Future<void> _clearSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_history');
      setState(() {
        _searchHistory.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search history cleared'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Save search to history
    await _saveSearchToHistory(query);

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
        
        // Add song to library if not already present
        if (!musicProvider.library.any((s) => s['id'] == song['id'])) {
          await musicProvider.addToLibrary(song);
        }
        
        // Create a queue from current search results or trending videos
        final currentQueue = _showTrending ? _trendingVideos : _searchResults;
        if (currentQueue.isNotEmpty) {
          // Convert to song format and create queue
          final songQueue = currentQueue.map((v) => {
            'id': v['id'],
            'title': v['title'],
            'artist': v['channel'],
            'thumbnail': v['thumbnail'],
            'duration': v['duration'] ?? 0,
            'url': v['url'],
            'youtubeUrl': v['url'],
          }).toList();
          
          // Find the index of current song in queue
          final songIndex = songQueue.indexWhere((s) => s['id'] == song['id']);
          if (songIndex != -1) {
            musicProvider.playQueue(songQueue, songIndex);
          } else {
            musicProvider.playSong(song);
          }
        } else {
        musicProvider.playSong(song);
        }
        
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
                  'Download as Audio (MP3)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
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
                          _startDownload(video);
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

  Future<void> _startDownload(Map<String, dynamic> video) async {
    final downloadService = DownloadService();
    final videoId = video['id'];
    
    // Check if already downloading
    if (_downloadingVideos.contains(videoId)) {
      return; // Already downloading, don't start another
    }
    
    // Mark as downloading
    setState(() {
      _downloadingVideos.add(videoId);
    });
    
    // Mark as background download
    downloadService.setBackgroundDownload(videoId, true);
    
    // Download audio only
    await _startSingleDownload(video, downloadService);
  }
  

  
  Future<void> _startSingleDownload(Map<String, dynamic> video, DownloadService downloadService) async {
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
      // Download audio only
        await downloadService.downloadAudio(
          video['url'],
          onProgress: (progress, received, total) {
            progressKey.currentState?.updateProgress(progress, received, total);
          },
          onComplete: () {
            progressKey.currentState?.setCompleted();
            downloadService.removeBackgroundDownload(videoId);
            if (mounted) {
            setState(() {
              _downloadingVideos.remove(videoId);
            });
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
          if (mounted) {
            setState(() {
              _downloadingVideos.remove(videoId);
            });
          }
          },
        );
    } catch (e) {
      progressKey.currentState?.setError(e.toString());
      downloadService.removeBackgroundDownload(videoId);
      if (mounted) {
        setState(() {
          _downloadingVideos.remove(videoId);
        });
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
      body: SingleChildScrollView(
        child: Column(
          children: [
          // Enhanced Search Bar with Suggestions
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for music on YouTube...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _showTrending = true;
                                _searchResults.clear();
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _performSearch,
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                  ),
                  onSubmitted: (_) => _performSearch(),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _showTrending = true;
                        _searchResults.clear();
                      }
                    });
                  },
                ),
                
                // Search Suggestions (when trending is shown)
                if (_showTrending && _searchController.text.isEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSearchSuggestions(isDark),
                ],
              ],
            ),
          ),
          
          // Content
          _isLoading
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SpinKitWave(
                      color: const Color(0xFF6366F1),
                      size: 30,
                    ),
                  ),
                )
              : _showTrending
                  ? _buildTrendingSection(isDark)
                  : _buildSearchResults(isDark),
          const SizedBox(height: 16),
        ],
        ),
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
        _trendingVideos.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SpinKitWave(
                    color: const Color(0xFF6366F1),
                    size: 30,
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _trendingVideos.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final video = _trendingVideos[index];
                  return _buildVideoTile(video, isDark);
                },
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
            _downloadingVideos.contains(video['id'])
                ? Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.download, color: Colors.green),
                    onPressed: () => _showDownloadOptions(video),
                    tooltip: 'Download',
            ),
          ],
        ),
      ),
    );
  }

  // Build search suggestions widget
  Widget _buildSearchSuggestions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search History
        if (_searchHistory.isNotEmpty) ...[
          _buildSuggestionSection(
            'Recent Searches',
            _searchHistory,
            Icons.history,
            isDark,
            onTap: (query) {
              _searchController.text = query;
              _performSearch();
            },
            onClear: _clearSearchHistory,
          ),
          const SizedBox(height: 16),
        ],
        
        // Recent Artists
        if (_recentArtists.isNotEmpty) ...[
          _buildSuggestionSection(
            'Recent Artists',
            _recentArtists,
            Icons.person,
            isDark,
            onTap: (artist) {
              _searchController.text = artist;
              _performSearch();
            },
          ),
          const SizedBox(height: 16),
        ],
        
        // Popular Searches
        _buildSuggestionSection(
          'Popular Searches',
          _popularSearches,
          Icons.trending_up,
          isDark,
          onTap: (query) {
            _searchController.text = query;
            _performSearch();
          },
        ),
      ],
    );
  }

  // Build suggestion section
  Widget _buildSuggestionSection(
    String title,
    List<String> items,
    IconData icon,
    bool isDark, {
    required Function(String) onTap,
    VoidCallback? onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (onClear != null)
              TextButton(
                onPressed: onClear,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => _buildSuggestionChip(item, isDark, onTap)).toList(),
        ),
      ],
    );
  }

  // Build suggestion chip
  Widget _buildSuggestionChip(String text, bool isDark, Function(String) onTap) {
    return GestureDetector(
      onTap: () => onTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
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
