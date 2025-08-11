import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import '../providers/music_provider.dart';
import '../providers/theme_provider.dart';
import '../services/download_service.dart';
import '../services/shortcut_service.dart';
import 'player_screen.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Map<String, dynamic> playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final playlistSongs = widget.playlist['songs'] as List;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          widget.playlist['name'] ?? 'Unknown Playlist',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'add_to_home',
                child: Row(
                  children: [
                    Icon(Icons.home_outlined),
                    SizedBox(width: 12),
                    Text('Add to Home Screen'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 12),
                    Text('Rename Playlist'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete Playlist', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: playlistSongs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.playlist_add,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No songs in this playlist',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add songs',
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
              itemCount: playlistSongs.length,
              itemBuilder: (context, index) {
                final song = playlistSongs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: song['thumbnail'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                song['thumbnail'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 24,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                    title: Text(
                      song['title'] ?? 'Unknown Title',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song['artist'] ?? 'Unknown Artist',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getFileTypeIcon(song),
                              size: 14,
                              color: _getFileTypeColor(song),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getFileTypeLabel(song),
                              style: TextStyle(
                                color: _getFileTypeColor(song),
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
                          icon: const Icon(Icons.play_arrow, color: Color(0xFF6366F1)),
                          onPressed: () => _playSong(song),
                          tooltip: 'Play',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmRemoveSong(song),
                          tooltip: 'Remove from playlist',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Logic to add new songs to the playlist
          // This could open a dialog to search and select songs to add

          final selectedSong = await _showAddSongDialog();
          if (selectedSong != null) {
            setState(() {
              widget.playlist['songs'].add(selectedSong);
            });
            musicProvider.updatePlaylist(widget.playlist['id'], widget.playlist);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showAddSongDialog() async {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    
    // Get all available songs from library that are not already in this playlist
    final playlistSongIds = Set<String>.from(
      widget.playlist['songs'].map((song) => song['id'].toString())
    );
    
    // Get both audio and video files from downloaded library
    final downloadService = DownloadService();
    final downloadedFiles = await downloadService.getDownloadedFiles();
    
    // Convert downloaded files to song format and filter out those already in playlist
    final availableSongs = downloadedFiles
        .where((file) => !playlistSongIds.contains(file['id'].toString()))
        .map((file) => {
          'id': file['id'],
          'title': file['title'],
          'artist': file['author'] ?? file['artist'],
          'thumbnail': file['thumbnail'],
          'duration': file['duration'],
          'url': 'file://${file['localPath']}',
          'isLocal': true,
          'fileType': file['fileType'], // 'audio' or 'video'
          'localPath': file['localPath'],
        })
        .toList();
    
    if (availableSongs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No songs available to add. All library songs are already in this playlist.'),
          backgroundColor: Colors.orange,
        ),
      );
      return null;
    }
    
    return showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Song to Playlist',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select a song from your library:',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableSongs.length,
                    itemBuilder: (context, index) {
                      final song = availableSongs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: song['thumbnail'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      song['thumbnail'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.music_note,
                                          color: Colors.white,
                                          size: 24,
                                        );
                                      },
                                    ),
                                  )
                                : const Icon(
                                    Icons.music_note,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                          ),
                          title: Text(
                            song['title'] ?? 'Unknown Title',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song['artist'] ?? 'Unknown Artist',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    _getFileTypeIcon(song),
                                    size: 14,
                                    color: _getFileTypeColor(song),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getFileTypeLabel(song),
                                    style: TextStyle(
                                      color: _getFileTypeColor(song),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).pop(song);
                          },
                        ),
                      );
                    },
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
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _playSong(Map<String, dynamic> song) {
    final isVideo = song['fileType'] == 'video' || 
                   (song['localPath'] != null && song['localPath'].toString().endsWith('.mp4'));
    
    if (isVideo) {
      // Open video file in external player
      _openVideoInExternalPlayer(song);
    } else {
      // Open audio file in internal player
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      musicProvider.playSong(song);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(song: song),
        ),
      );
    }
  }
  
  Future<void> _openVideoInExternalPlayer(Map<String, dynamic> song) async {
    try {
      final filePath = song['localPath'] ?? song['url'];
      if (filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video file path not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Clean file path - remove file:// prefix if present
      final cleanPath = filePath.toString().replaceFirst('file://', '');

      final result = await OpenFile.open(cleanPath);
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
  
  void _confirmRemoveSong(Map<String, dynamic> song) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Song'),
          content: Text(
            'Are you sure you want to remove "${song['title']}" from this playlist?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removeSongFromPlaylist(song['id'], widget.playlist);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${song['title']}" removed from playlist'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeSongFromPlaylist(String songId, Map<String, dynamic> playlist) {
    setState(() {
      playlist['songs'].removeWhere((song) => song['id'] == songId);
    });
    Provider.of<MusicProvider>(context, listen: false).updatePlaylist(
      playlist['id'],
      playlist,
    );
  }
  
  void _handleMenuAction(String action) async {
    switch (action) {
      case 'add_to_home':
        await _addToHomeScreen();
        break;
      case 'rename':
        await _renamePlaylist();
        break;
      case 'delete':
        await _deletePlaylist();
        break;
    }
  }
  
  Future<void> _addToHomeScreen() async {
    try {
      final shortcutService = ShortcutService();
      final playlistId = widget.playlist['id'];
      final playlistName = widget.playlist['name'] ?? 'Playlist';
      
      // Check if shortcut already exists
      final hasShortcut = await shortcutService.hasPlaylistShortcut(playlistId);
      
      if (hasShortcut) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This playlist is already on your home screen'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // Add shortcut
      await shortcutService.addPlaylistShortcut(
        playlistId: playlistId,
        playlistName: playlistName,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$playlistName" added to home screen'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () async {
                await shortcutService.removePlaylistShortcut(playlistId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Shortcut removed from home screen'),
                      backgroundColor: Colors.grey,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error adding to home screen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to home screen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _renamePlaylist() async {
    final controller = TextEditingController(text: widget.playlist['name']);
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Playlist'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Playlist Name',
              border: OutlineInputBorder(),
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
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(name);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    
    if (newName != null && newName != widget.playlist['name']) {
      setState(() {
        widget.playlist['name'] = newName;
      });
      
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      musicProvider.updatePlaylist(widget.playlist['id'], widget.playlist);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playlist renamed to "$newName"'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  Future<void> _deletePlaylist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Playlist'),
          content: Text(
            'Are you sure you want to delete "${widget.playlist['name']}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    
    if (confirmed == true) {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      musicProvider.deletePlaylist(widget.playlist['id']);
      
      // Also remove from home screen if it exists
      final shortcutService = ShortcutService();
      await shortcutService.removePlaylistShortcut(widget.playlist['id']);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${widget.playlist['name']}" deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Helper methods for file type detection
  IconData _getFileTypeIcon(Map<String, dynamic> song) {
    final fileType = song['fileType'];
    final url = song['url']?.toString() ?? '';
    final localPath = song['localPath']?.toString() ?? '';
    
    if (fileType == 'video' || url.endsWith('.mp4') || localPath.endsWith('.mp4')) {
      return Icons.video_library;
    } else {
      return Icons.music_note;
    }
  }
  
  Color _getFileTypeColor(Map<String, dynamic> song) {
    final fileType = song['fileType'];
    final url = song['url']?.toString() ?? '';
    final localPath = song['localPath']?.toString() ?? '';
    
    if (fileType == 'video' || url.endsWith('.mp4') || localPath.endsWith('.mp4')) {
      return Colors.red[600] ?? Colors.red;
    } else {
      return Colors.blue[600] ?? Colors.blue;
    }
  }
  
  String _getFileTypeLabel(Map<String, dynamic> song) {
    final fileType = song['fileType'];
    final url = song['url']?.toString() ?? '';
    final localPath = song['localPath']?.toString() ?? '';
    
    if (fileType == 'video' || url.endsWith('.mp4') || localPath.endsWith('.mp4')) {
      return 'Video';
    } else {
      return 'Audio';
    }
  }
}
