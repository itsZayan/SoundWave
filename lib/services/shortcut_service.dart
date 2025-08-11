import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ShortcutService {
  static final ShortcutService _instance = ShortcutService._internal();
  factory ShortcutService() => _instance;
  ShortcutService._internal();

  final QuickActions _quickActions = const QuickActions();
  static const String _shortcutsKey = 'playlist_shortcuts';

  // Callback for when a shortcut is pressed
  Function(String playlistId)? onShortcutPressed;

  Future<void> initialize() async {
    if (kIsWeb) return; // Quick actions not supported on web

    // Set up shortcut listener
    _quickActions.initialize((String shortcutType) {
      print('ShortcutService: Shortcut pressed: $shortcutType');
      
      // Extract playlist ID from shortcut type
      if (shortcutType.startsWith('playlist_')) {
        final playlistId = shortcutType.replaceFirst('playlist_', '');
        onShortcutPressed?.call(playlistId);
      }
    });

    // Load and set existing shortcuts
    await _loadExistingShortcuts();
  }

  Future<void> addPlaylistShortcut({
    required String playlistId,
    required String playlistName,
    String? iconPath,
  }) async {
    if (kIsWeb) return; // Quick actions not supported on web

    try {
      // Get existing shortcuts
      final shortcuts = await _getStoredShortcuts();
      
      // Add new shortcut to storage
      shortcuts[playlistId] = {
        'name': playlistName,
        'iconPath': iconPath,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Save to storage
      await _saveShortcuts(shortcuts);

      // Update quick actions
      await _updateQuickActions(shortcuts);

      print('ShortcutService: Added shortcut for playlist: $playlistName');
    } catch (e) {
      print('ShortcutService: Error adding shortcut: $e');
      rethrow;
    }
  }

  Future<void> removePlaylistShortcut(String playlistId) async {
    if (kIsWeb) return;

    try {
      final shortcuts = await _getStoredShortcuts();
      shortcuts.remove(playlistId);

      await _saveShortcuts(shortcuts);
      await _updateQuickActions(shortcuts);

      print('ShortcutService: Removed shortcut for playlist: $playlistId');
    } catch (e) {
      print('ShortcutService: Error removing shortcut: $e');
    }
  }

  Future<bool> hasPlaylistShortcut(String playlistId) async {
    if (kIsWeb) return false;

    final shortcuts = await _getStoredShortcuts();
    return shortcuts.containsKey(playlistId);
  }

  Future<List<String>> getShortcutPlaylistIds() async {
    if (kIsWeb) return [];

    final shortcuts = await _getStoredShortcuts();
    return shortcuts.keys.toList();
  }

  Future<Map<String, dynamic>> _getStoredShortcuts() async {
    final prefs = await SharedPreferences.getInstance();
    final shortcutsJson = prefs.getString(_shortcutsKey);
    
    if (shortcutsJson != null) {
      try {
        return Map<String, dynamic>.from(json.decode(shortcutsJson));
      } catch (e) {
        print('ShortcutService: Error parsing stored shortcuts: $e');
        return {};
      }
    }
    
    return {};
  }

  Future<void> _saveShortcuts(Map<String, dynamic> shortcuts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shortcutsKey, json.encode(shortcuts));
  }

  Future<void> _loadExistingShortcuts() async {
    final shortcuts = await _getStoredShortcuts();
    await _updateQuickActions(shortcuts);
  }

  Future<void> _updateQuickActions(Map<String, dynamic> shortcuts) async {
    final List<ShortcutItem> shortcutItems = [];

    // Limit to 4 shortcuts (Android limitation)
    final sortedEntries = shortcuts.entries.toList()
      ..sort((a, b) {
        final aDate = DateTime.tryParse(a.value['createdAt'] ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b.value['createdAt'] ?? '') ?? DateTime.now();
        return bDate.compareTo(aDate); // Most recent first
      });

    for (int i = 0; i < sortedEntries.length && i < 4; i++) {
      final entry = sortedEntries[i];
      final playlistId = entry.key;
      final playlistData = entry.value;

      shortcutItems.add(
        ShortcutItem(
          type: 'playlist_$playlistId',
          localizedTitle: playlistData['name'] ?? 'Playlist',
          icon: 'ic_playlist', // You'll need to add this icon to android/app/src/main/res/drawable/
        ),
      );
    }

    await _quickActions.setShortcutItems(shortcutItems);
  }

  Future<void> clearAllShortcuts() async {
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shortcutsKey);
    await _quickActions.setShortcutItems([]);
  }

  // Helper method to create a shortcut icon (you might want to generate this dynamically)
  Future<String?> generateShortcutIcon(String playlistName) async {
    // For now, return null. In a real implementation, you might:
    // 1. Generate an icon with the playlist name
    // 2. Use the first song's thumbnail
    // 3. Create a custom icon based on the playlist
    return null;
  }
}
