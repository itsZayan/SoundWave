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
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _downloadedFiles.length,
      itemBuilder: (context, index) {
        final metadata = _downloadedFiles[index];
        return _buildSongTile(metadata, isDark, true);
      },
    );
  }

  Widget _buildImportedTab(bool isDark) {
    if (_importedFiles.isEmpty) {
      return Center(
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
              'Import songs from your device',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _importSongsFromDevice,
              icon: const Icon(Icons.file_upload),
              label: const Text('Import Songs'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _importedFiles.length,
      itemBuilder: (context, index) {
        final song = _importedFiles[index];
        return _buildSongTile(song, isDark, false);
      },
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
    
    // Set up playlist queue for auto-play
    final audioService = Provider.of<GlobalAudioService>(context, listen: false);
    audioService.setPlaylistQueue(_importedFiles, _importedFiles.indexOf(song));
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(song: song),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadLibraryData();
            },
          ),
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
