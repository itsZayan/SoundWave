import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/theme_provider.dart';
import '../providers/music_provider.dart';
import '../services/download_service.dart';
import '../services/audio_service.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _downloadedFiles = [];
  List<Map<String, dynamic>> _importedFiles = [];
  bool _isLoading = true;
  final DownloadService _downloadService = DownloadService();
  
  // Sorting and filtering options
  String _sortBy = 'name'; // 'name', 'artist', 'date', 'duration', 'playCount'
  bool _sortAscending = true;
  String _filterBy = 'all'; // 'all', 'audio', 'video', 'downloaded', 'imported'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLibraryData();
    // Register for download completion notifications
    _downloadService.addLibraryRefreshCallback(_refreshLibrary);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    // Unregister callback to prevent memory leaks
    _downloadService.removeLibraryRefreshCallback(_refreshLibrary);
    super.dispose();
  }
  
  void _refreshLibrary() {
    if (mounted) {
      _loadLibraryData();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when the screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadLibraryData();
      }
    });
  }

  Future<void> _loadLibraryData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load downloaded files
      final downloadService = DownloadService();
      final downloadedFiles = await downloadService.getDownloadedFiles();
      
      // Get imported songs from MusicProvider
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      final importedSongs = musicProvider.getImportedSongs();
      
      if (mounted) {
        setState(() {
          _downloadedFiles = downloadedFiles;
          _importedFiles = importedSongs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading library data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _playDownloadedSong(Map<String, dynamic> metadata) async {
    final isVideo = metadata['fileType'] == 'video' || metadata['localPath'].toString().endsWith('.mp4');
    
    if (isVideo) {
      // Open video file in external player
      await _openVideoInExternalPlayer(metadata);
    } else {
      // Open audio file in internal player
      final song = {
        'id': metadata['id'],
        'title': metadata['title'],
        'artist': metadata['author'],
        'thumbnail': metadata['thumbnail'],
        'duration': metadata['duration'],
        'url': metadata['localPath'], // Use local path for audio files
        'localPath': metadata['localPath'], // Also include localPath as backup
        'isLocal': true,
        'fileType': metadata['fileType'],
      };
      
      // Set up playlist queue for auto-play
      final audioService = Provider.of<GlobalAudioService>(context, listen: false);
      final audioFiles = _downloadedFiles.where((file) => 
        file['fileType'] == 'audio' || !file['localPath'].toString().endsWith('.mp4')
      ).toList();
      
      // Convert metadata to song format for all audio files
      final playlist = audioFiles.map((file) => {
        'id': file['id'],
        'title': file['title'],
        'artist': file['author'],
        'thumbnail': file['thumbnail'],
        'duration': file['duration'],
        'url': file['localPath'],
        'localPath': file['localPath'],
        'isLocal': true,
        'fileType': file['fileType'],
      }).toList();
      
      // Find current song index in playlist
      final currentIndex = playlist.indexWhere((s) => s['id'] == song['id']);
      
      // Set playlist queue for auto-play
      audioService.setPlaylistQueue(playlist, currentIndex);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(song: song),
        ),
      );
    }
  }
  
  Future<void> _openVideoInExternalPlayer(Map<String, dynamic> metadata) async {
    try {
      final filePath = metadata['localPath'] as String;

      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No video player found to open this file'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDownload(Map<String, dynamic> metadata) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Are you sure you want to delete "${metadata['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final downloadService = DownloadService();
      await downloadService.deleteDownload(metadata['localPath']);
      _loadLibraryData(); // Refresh the list
    }
  }

  // Sort files based on current sorting options
  List<Map<String, dynamic>> _getSortedFiles(List<Map<String, dynamic>> files) {
    final sortedFiles = List<Map<String, dynamic>>.from(files);
    
    switch (_sortBy) {
      case 'name':
        sortedFiles.sort((a, b) {
          final aTitle = (a['title'] ?? '').toString().toLowerCase();
          final bTitle = (b['title'] ?? '').toString().toLowerCase();
          return _sortAscending ? aTitle.compareTo(bTitle) : bTitle.compareTo(aTitle);
        });
        break;
      case 'artist':
        sortedFiles.sort((a, b) {
          final aArtist = (a['artist'] ?? a['author'] ?? '').toString().toLowerCase();
          final bArtist = (b['artist'] ?? b['author'] ?? '').toString().toLowerCase();
          return _sortAscending ? aArtist.compareTo(bArtist) : bArtist.compareTo(aArtist);
        });
        break;
      case 'date':
        sortedFiles.sort((a, b) {
          final aDate = DateTime.tryParse(a['addedAt'] ?? a['downloadedAt'] ?? '') ?? DateTime(1970);
          final bDate = DateTime.tryParse(b['addedAt'] ?? b['downloadedAt'] ?? '') ?? DateTime(1970);
          return _sortAscending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        });
        break;
      case 'duration':
        sortedFiles.sort((a, b) {
          final aDuration = (a['duration'] ?? 0) as int;
          final bDuration = (b['duration'] ?? 0) as int;
          return _sortAscending ? aDuration.compareTo(bDuration) : bDuration.compareTo(aDuration);
        });
        break;
      case 'playCount':
        sortedFiles.sort((a, b) {
          final aCount = (a['playCount'] ?? 0) as int;
          final bCount = (b['playCount'] ?? 0) as int;
          return _sortAscending ? aCount.compareTo(bCount) : bCount.compareTo(aCount);
        });
        break;
    }
    
    return sortedFiles;
  }

  // Filter files based on current filter options
  List<Map<String, dynamic>> _getFilteredFiles(List<Map<String, dynamic>> files) {
    switch (_filterBy) {
      case 'audio':
        return files.where((file) => 
          file['fileType'] == 'audio' || !file['localPath'].toString().endsWith('.mp4')
        ).toList();
      case 'video':
        return files.where((file) => 
          file['fileType'] == 'video' || file['localPath'].toString().endsWith('.mp4')
        ).toList();
      case 'downloaded':
        return files.where((file) => file['isDownloaded'] == true).toList();
      case 'imported':
        return files.where((file) => file['isImported'] == true).toList();
      default:
        return files;
    }
  }

  // Get library statistics
  Map<String, dynamic> _getLibraryStats() {
    final allFiles = [..._downloadedFiles, ..._importedFiles];
    final audioFiles = allFiles.where((file) => 
      file['fileType'] == 'audio' || !file['localPath'].toString().endsWith('.mp4')
    ).toList();
    final videoFiles = allFiles.where((file) => 
      file['fileType'] == 'video' || file['localPath'].toString().endsWith('.mp4')
    ).toList();
    
    int totalDuration = 0;
    int totalSize = 0;
    
    for (final file in allFiles) {
      totalDuration += (file['duration'] ?? 0) as int;
      // Note: File size calculation would require additional implementation
    }
    
    return {
      'totalFiles': allFiles.length,
      'audioFiles': audioFiles.length,
      'videoFiles': videoFiles.length,
      'totalDuration': totalDuration,
      'totalSize': totalSize,
    };
  }

  Future<void> _importSongsFromDevice() async {
    try {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      await musicProvider.importSongsFromDevice();
      _loadLibraryData(); // Refresh the library
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Songs imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import songs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show sorting and filtering options
  void _showSortingOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildSortChip('Name', 'name'),
                _buildSortChip('Artist', 'artist'),
                _buildSortChip('Date Added', 'date'),
                _buildSortChip('Duration', 'duration'),
                _buildSortChip('Play Count', 'playCount'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Order: ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('A-Z'),
                  selected: _sortAscending,
                  onSelected: (selected) {
                    setState(() {
                      _sortAscending = selected;
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Z-A'),
                  selected: !_sortAscending,
                  onSelected: (selected) {
                    setState(() {
                      _sortAscending = selected;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Show filtering options
  void _showFilteringOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter By',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Audio Only', 'audio'),
                _buildFilterChip('Video Only', 'video'),
                _buildFilterChip('Downloaded', 'downloaded'),
                _buildFilterChip('Imported', 'imported'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build sort chip
  Widget _buildSortChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _sortBy == value,
      onSelected: (selected) {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  // Build filter chip
  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filterBy == value,
      onSelected: (selected) {
        setState(() {
          _filterBy = value;
        });
        Navigator.pop(context);
      },
    );
  }

  // Format duration from seconds to MM:SS
  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0:00';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildDownloadedTab(bool isDark) {
    if (_downloadedFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Downloaded Songs',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Download music to listen offline',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    final sortedAndFilteredFiles = _getSortedFiles(_getFilteredFiles(_downloadedFiles));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedAndFilteredFiles.length,
      itemBuilder: (context, index) {
        final metadata = sortedAndFilteredFiles[index];
        return _buildSongTile(metadata, isDark, true);
      },
    );
  }

  Widget _buildImportedTab(bool isDark) {
    return Column(
      children: [
        // Always show import button at the top
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _importSongsFromDevice,
            icon: const Icon(Icons.file_upload),
            label: const Text('Import More Songs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        // Show imported songs or empty state
        Expanded(
          child: _importedFiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_android,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Imported Songs',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Import songs from your device to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Builder(
                  builder: (context) {
                    final sortedAndFilteredFiles = _getSortedFiles(_getFilteredFiles(_importedFiles));
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedAndFilteredFiles.length,
                      itemBuilder: (context, index) {
                        final song = sortedAndFilteredFiles[index];
                        return _buildSongTile(song, isDark, false);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSongTile(Map<String, dynamic> songData, bool isDark, bool isDownloaded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: songData['thumbnail'] ?? '',
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
              color: const Color(0xFF6366F1),
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Text(
          songData['title'] ?? 'Unknown Title',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              songData['artist'] ?? songData['author'] ?? 'Unknown Artist',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isDownloaded) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    songData['fileType'] == 'audio' ? Icons.music_note : Icons.video_library,
                    size: 14,
                    color: songData['fileType'] == 'audio' ? Colors.blue[600] : Colors.red[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    songData['fileType'] == 'audio' ? 'Audio' : 'Video',
                    style: TextStyle(
                      color: songData['fileType'] == 'audio' ? Colors.blue[600] : Colors.red[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.play_arrow,
                color: Color(0xFF6366F1),
              ),
              onPressed: () => isDownloaded 
                ? _playDownloadedSong(songData)
                : _playImportedSong(songData),
              tooltip: 'Play',
            ),
            if (isDownloaded)
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () => _deleteDownload(songData),
                tooltip: 'Delete',
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _playImportedSong(Map<String, dynamic> song) async {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    
    // Mark as played to add to library
    musicProvider.incrementPlayCount(song);
    
    // Prepare song data for playback with proper local file handling
    final songForPlayback = {
      'id': song['id'],
      'title': song['title'],
      'artist': song['artist'] ?? 'Unknown Artist',
      'thumbnail': song['thumbnail'] ?? '',
      'duration': song['duration'] ?? 0,
      'url': song['filePath'] ?? song['localPath'], // Use filePath for imported songs
      'localPath': song['filePath'] ?? song['localPath'],
      'isLocal': true,
      'fileType': 'audio',
      'isImported': true,
    };
    
    // Set up playlist queue for auto-play
    final audioService = Provider.of<GlobalAudioService>(context, listen: false);
    final playlistForQueue = _importedFiles.map((s) => {
      'id': s['id'],
      'title': s['title'],
      'artist': s['artist'] ?? 'Unknown Artist',
      'thumbnail': s['thumbnail'] ?? '',
      'duration': s['duration'] ?? 0,
      'url': s['filePath'] ?? s['localPath'],
      'localPath': s['filePath'] ?? s['localPath'],
      'isLocal': true,
      'fileType': 'audio',
      'isImported': true,
    }).toList();
    
    audioService.setPlaylistQueue(playlistForQueue, _importedFiles.indexOf(song));
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(song: songForPlayback),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text(
          'Your Library',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          // Library Statistics
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              final stats = _getLibraryStats();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Library Statistics'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Files: ${stats['totalFiles']}'),
                      Text('Audio Files: ${stats['audioFiles']}'),
                      Text('Video Files: ${stats['videoFiles']}'),
                      Text('Total Duration: ${_formatDuration(stats['totalDuration'])}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Library Statistics',
          ),
          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilteringOptions,
            tooltip: 'Filter Library',
          ),
          // Sort Button
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortingOptions,
            tooltip: 'Sort Library',
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadLibraryData();
            },
          ),
          // Import Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') {
                _importSongsFromDevice();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_upload),
                    SizedBox(width: 8),
                    Text('Import from Device'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
          : Column(
              children: [
                Container(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF6366F1),
                    labelColor: isDark ? Colors.white : Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.download),
                        text: 'Downloaded',
                      ),
                      Tab(
                        icon: Icon(Icons.phone_android),
                        text: 'Imported',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDownloadedTab(isDark),
                      _buildImportedTab(isDark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
