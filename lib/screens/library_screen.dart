import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import '../providers/theme_provider.dart';
import '../services/download_service.dart';
import '../services/audio_service.dart';
import 'player_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with RouteAware {
  List<Map<String, dynamic>> _downloadedFiles = [];
  bool _isLoading = true;
  final DownloadService _downloadService = DownloadService();

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
    // Register for download completion notifications
    _downloadService.addLibraryRefreshCallback(_refreshLibrary);
  }
  
  @override
  void dispose() {
    // Unregister callback to prevent memory leaks
    _downloadService.removeLibraryRefreshCallback(_refreshLibrary);
    super.dispose();
  }
  
  void _refreshLibrary() {
    if (mounted) {
      _loadDownloadedFiles();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when the screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadDownloadedFiles();
      }
    });
  }

  Future<void> _loadDownloadedFiles() async {
    final downloadService = DownloadService();
    final files = await downloadService.getDownloadedFiles();
    
    if (mounted) {
      setState(() {
        _downloadedFiles = files;
        _isLoading = false;
      });
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
      _loadDownloadedFiles(); // Refresh the list
    }
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
              _loadDownloadedFiles();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            )
          : _downloadedFiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_music,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No downloaded music',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Download music from the search tab to listen offline',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _downloadedFiles.length,
                  itemBuilder: (context, index) {
                    final metadata = _downloadedFiles[index];
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
                            imageUrl: metadata['thumbnail'] ?? '',
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
                          metadata['title'] ?? 'Unknown Title',
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
                              metadata['author'] ?? 'Unknown Artist',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  metadata['fileType'] == 'audio' ? Icons.music_note : Icons.video_library,
                  size: 14,
                  color: metadata['fileType'] == 'audio' ? Colors.blue[600] : Colors.red[600],
                ),
                const SizedBox(width: 4),
                Text(
                  metadata['fileType'] == 'audio' ? 'Audio' : 'Video',
                  style: TextStyle(
                    color: metadata['fileType'] == 'audio' ? Colors.blue[600] : Colors.red[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
                              onPressed: () => _playDownloadedSong(metadata),
                              tooltip: 'Play',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteDownload(metadata),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
