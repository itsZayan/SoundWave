import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/theme_provider.dart';
import '../services/shortcut_service.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  Future<void> _showCreatePlaylistDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Playlist'),
          content: TextField(
            controller: _playlistNameController,
            decoration: const InputDecoration(
              hintText: 'Enter playlist name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _playlistNameController.text.trim();
                if (name.isNotEmpty) {
                  Provider.of<MusicProvider>(context, listen: false)
                      .createPlaylist(name);
                  _playlistNameController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _viewPlaylist(Map<String, dynamic> playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  void _editPlaylist(Map<String, dynamic> playlist) {
    _playlistNameController.text = playlist['name'] ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Playlist'),
          content: TextField(
            controller: _playlistNameController,
            decoration: const InputDecoration(
              hintText: 'Enter playlist name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _playlistNameController.text.trim();
                if (name.isNotEmpty) {
                  Provider.of<MusicProvider>(context, listen: false)
                      .updatePlaylistName(playlist['id'], name);
                  _playlistNameController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _deletePlaylist(Map<String, dynamic> playlist, MusicProvider musicProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Playlist'),
          content: Text(
            'Are you sure you want to delete "${playlist['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                musicProvider.deletePlaylist(playlist['id']);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _addToHomeScreen(Map<String, dynamic> playlist) async {
    try {
      final shortcutService = ShortcutService();
      final playlistId = playlist['id'];
      final playlistName = playlist['name'] ?? 'Playlist';
      
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text(
          'Playlists',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreatePlaylistDialog,
            tooltip: 'Create Playlist',
          ),
        ],
      ),
      body: musicProvider.playlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.playlist_play,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No playlists yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to create your first playlist',
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
              itemCount: musicProvider.playlists.length,
              itemBuilder: (context, index) {
                final playlist = musicProvider.playlists[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.playlist_play,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      playlist['name'] ?? 'Unknown Playlist',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${(playlist['songs'] as List).length} songs',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => _viewPlaylist(playlist),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'view') {
                              _viewPlaylist(playlist);
                            } else if (value == 'add_to_home') {
                              _addToHomeScreen(playlist);
                            } else if (value == 'edit') {
                              _editPlaylist(playlist);
                            } else if (value == 'delete') {
                              _deletePlaylist(playlist, musicProvider);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 20),
                                  SizedBox(width: 8),
                                  Text('View Songs'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'add_to_home',
                              child: Row(
                                children: [
                                  Icon(Icons.home_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Add to Home Screen'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit Name'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
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
