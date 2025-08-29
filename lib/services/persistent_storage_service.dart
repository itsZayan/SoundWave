import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersistentStorageService {
  static final PersistentStorageService _instance = PersistentStorageService._internal();
  factory PersistentStorageService() => _instance;
  PersistentStorageService._internal();

  static const String _appDataDirName = 'SoundWave';
  static const String _playlistsFileName = 'playlists.json';
  static const String _libraryFileName = 'library.json';
  static const String _settingsFileName = 'settings.json';
  static const String _downloadsDirName = 'Downloads';
  static const String _metadataFileName = 'app_metadata.json';

  // Main app data directory (external storage)
  Directory? _appDataDir;
  Directory? _downloadsDir;
  
  // Fallback to app documents directory if external storage not available
  Directory? _fallbackDir;

  /// Initialize the persistent storage service
  Future<bool> initialize() async {
    try {
      // Request necessary permissions
      if (Platform.isAndroid) {
        final storagePermission = await Permission.storage.request();
        final externalStoragePermission = await Permission.manageExternalStorage.request();
        
        if (!storagePermission.isGranted && !externalStoragePermission.isGranted) {
          print('⚠️ Storage permissions not granted, using fallback storage');
        }
      }

      // Try to get external storage directory first
      _appDataDir = await _getExternalAppDataDirectory();
      _downloadsDir = await _getExternalDownloadsDirectory();
      
      // Fallback to app documents directory
      if (_appDataDir == null) {
        _fallbackDir = await getApplicationDocumentsDirectory();
        _appDataDir = _fallbackDir;
        _downloadsDir = Directory('${_fallbackDir!.path}/$_downloadsDirName');
      }

      // Create directories if they don't exist
      await _appDataDir!.create(recursive: true);
      await _downloadsDir!.create(recursive: true);

      print('✅ Persistent storage initialized: ${_appDataDir!.path}');
      print('✅ Downloads directory: ${_downloadsDir!.path}');
      
      return true;
    } catch (e) {
      print('❌ Failed to initialize persistent storage: $e');
      // Fallback to app documents directory
      try {
        _fallbackDir = await getApplicationDocumentsDirectory();
        _appDataDir = _fallbackDir;
        _downloadsDir = Directory('${_fallbackDir!.path}/$_downloadsDirName');
        await _appDataDir!.create(recursive: true);
        await _downloadsDir!.create(recursive: true);
        return true;
      } catch (fallbackError) {
        print('❌ Fallback storage also failed: $fallbackError');
        return false;
      }
    }
  }

  /// Get external app data directory (survives app uninstall on Android)
  Future<Directory?> _getExternalAppDataDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Try to get external storage directory
        final externalDir = Directory('/storage/emulated/0/Android/data/com.soundwave.musicapp/files');
        if (await externalDir.exists()) {
          return externalDir;
        }
        
        // Alternative: use external storage root
        final externalRoot = Directory('/storage/emulated/0/$_appDataDirName');
        if (await externalRoot.exists() || await externalRoot.create(recursive: true)) {
          return externalRoot;
        }
      } catch (e) {
        print('⚠️ External storage not accessible: $e');
      }
    }
    return null;
  }

  /// Get external downloads directory
  Future<Directory?> _getExternalDownloadsDirectory() async {
    if (Platform.isAndroid) {
      try {
        // Try to get external downloads directory
        final downloadsDir = Directory('/storage/emulated/0/Download/$_appDataDirName');
        if (await downloadsDir.exists() || await downloadsDir.create(recursive: true)) {
          return downloadsDir;
        }
      } catch (e) {
        print('⚠️ External downloads directory not accessible: $e');
      }
    }
    return null;
  }

  /// Save playlists to persistent storage
  Future<bool> savePlaylists(List<Map<String, dynamic>> playlists) async {
    try {
      if (_appDataDir == null) {
        await initialize();
      }
      
      final file = File('${_appDataDir!.path}/$_playlistsFileName');
      final jsonData = jsonEncode(playlists);
      await file.writeAsString(jsonData);
      
      // Also save to SharedPreferences as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('playlists', jsonData);
      
      print('✅ Playlists saved to persistent storage: ${file.path}');
      return true;
    } catch (e) {
      print('❌ Failed to save playlists: $e');
      return false;
    }
  }

  /// Load playlists from persistent storage
  Future<List<Map<String, dynamic>>> loadPlaylists() async {
    try {
      if (_appDataDir == null) {
        await initialize();
      }
      
      final file = File('${_appDataDir!.path}/$_playlistsFileName');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final playlists = List<Map<String, dynamic>>.from(jsonDecode(jsonData));
        print('✅ Playlists loaded from persistent storage: ${playlists.length} playlists');
        return playlists;
      }
    } catch (e) {
      print('⚠️ Failed to load playlists from persistent storage: $e');
    }
    
    // Fallback to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsString = prefs.getString('playlists');
      if (playlistsString != null) {
        final playlists = List<Map<String, dynamic>>.from(jsonDecode(playlistsString));
        print('✅ Playlists loaded from SharedPreferences fallback: ${playlists.length} playlists');
        return playlists;
      }
    } catch (e) {
      print('❌ Failed to load playlists from SharedPreferences: $e');
    }
    
    return [];
  }

  /// Save library to persistent storage
  Future<bool> saveLibrary(List<Map<String, dynamic>> library) async {
    try {
      if (_appDataDir == null) {
        await initialize();
      }
      
      final file = File('${_appDataDir!.path}/$_libraryFileName');
      final jsonData = jsonEncode(library);
      await file.writeAsString(jsonData);
      
      // Also save to SharedPreferences as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('library', jsonData);
      
      print('✅ Library saved to persistent storage: ${file.path}');
      return true;
    } catch (e) {
      print('❌ Failed to save library: $e');
      return false;
    }
  }

  /// Load library from persistent storage
  Future<List<Map<String, dynamic>>> loadLibrary() async {
    try {
      if (_appDataDir == null) {
        await initialize();
      }
      
      final file = File('${_appDataDir!.path}/$_libraryFileName');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final library = List<Map<String, dynamic>>.from(jsonDecode(jsonData));
        print('✅ Library loaded from persistent storage: ${library.length} songs');
        return library;
      }
    } catch (e) {
      print('⚠️ Failed to load library from persistent storage: $e');
    }
    
    // Fallback to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final libraryString = prefs.getString('library');
      if (libraryString != null) {
        final library = List<Map<String, dynamic>>.from(jsonDecode(libraryString));
        print('✅ Library loaded from SharedPreferences fallback: ${library.length} songs');
        return library;
      }
    } catch (e) {
      print('❌ Failed to load library from SharedPreferences: $e');
    }
    
    return [];
  }

  /// Save app settings to persistent storage
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      if (_appDataDir == null) {
        await initialize();
      }
      
      final file = File('${_appDataDir!.path}/$_settingsFileName');
      final jsonData = jsonEncode(settings);
      await file.writeAsString(jsonData);
      
      print('✅ Settings saved to persistent storage: ${file.path}');
      return true;
    } catch (e) {
      print('❌ Failed to save settings: $e');
      return false;
    }
  }

  /// Load app settings from persistent storage
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      if (_appDataDir == null) {
        await initialize();
      }
      
      final file = File('${_appDataDir!.path}/$_settingsFileName');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final settings = Map<String, dynamic>.from(jsonDecode(jsonData));
        print('✅ Settings loaded from persistent storage');
        return settings;
      }
    } catch (e) {
      print('⚠️ Failed to load settings from persistent storage: $e');
    }
    
    return {};
  }

  /// Save downloaded audio file to persistent storage
  Future<String?> saveDownloadedAudio(File sourceFile, String fileName) async {
    try {
      if (_downloadsDir == null) {
        await initialize();
      }
      
      final destinationFile = File('${_downloadsDir!.path}/$fileName');
      
      // Copy file to persistent storage
      await sourceFile.copy(destinationFile.path);
      
      print('✅ Audio saved to persistent storage: ${destinationFile.path}');
      return destinationFile.path;
    } catch (e) {
      print('❌ Failed to save downloaded audio: $e');
      return null;
    }
  }

  /// Get path for downloaded audio
  String? getDownloadedAudioPath(String fileName) {
    if (_downloadsDir == null) return null;
    final file = File('${_downloadsDir!.path}/$fileName');
    return file.existsSync() ? file.path : null;
  }

  /// Check if downloaded audio exists
  bool downloadedAudioExists(String fileName) {
    if (_downloadsDir == null) return false;
    final file = File('${_downloadsDir!.path}/$fileName');
    return file.existsSync();
  }

  /// Get all downloaded audio files
  List<File> getAllDownloadedAudios() {
    if (_downloadsDir == null) return [];
    
    try {
      return _downloadsDir!
          .listSync()
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.mp3') || 
                          file.path.toLowerCase().endsWith('.m4a') ||
                          file.path.toLowerCase().endsWith('.wav'))
          .toList();
    } catch (e) {
      print('❌ Failed to get downloaded audios: $e');
      return [];
    }
  }

  /// Save app metadata (version, last update, etc.)
  Future<bool> saveAppMetadata(Map<String, dynamic> metadata) async {
    try {
      if (_appDataDir == null) {
        await initialize();
      }
      
      final file = File('${_appDataDir!.path}/$_metadataFileName');
      final jsonData = jsonEncode(metadata);
      await file.writeAsString(jsonData);
      
      print('✅ App metadata saved to persistent storage');
      return true;
    } catch (e) {
      print('❌ Failed to save app metadata: $e');
      return false;
    }
  }

  /// Load app metadata
  Future<Map<String, dynamic>> loadAppMetadata() async {
    try {
      if (_appDataDir == null) {
        await initialize();
      }
      
      final file = File('${_appDataDir!.path}/$_metadataFileName');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final metadata = Map<String, dynamic>.from(jsonDecode(jsonData));
        print('✅ App metadata loaded from persistent storage');
        return metadata;
      }
    } catch (e) {
      print('⚠️ Failed to load app metadata: $e');
    }
    
    return {};
  }

  /// Check if this is a fresh install or update
  Future<bool> isFreshInstall() async {
    try {
      final metadata = await loadAppMetadata();
      return metadata.isEmpty;
    } catch (e) {
      return true;
    }
  }

  /// Get storage info
  Map<String, dynamic> getStorageInfo() {
    return {
      'appDataDir': _appDataDir?.path,
      'downloadsDir': _downloadsDir?.path,
      'isExternalStorage': _appDataDir != _fallbackDir,
      'fallbackDir': _fallbackDir?.path,
    };
  }

  /// Clear all persistent data (for testing)
  Future<bool> clearAllData() async {
    try {
      if (_appDataDir != null) {
        final files = _appDataDir!.listSync();
        for (var entity in files) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
      
      if (_downloadsDir != null) {
        final files = _downloadsDir!.listSync();
        for (var entity in files) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
      
      print('✅ All persistent data cleared');
      return true;
    } catch (e) {
      print('❌ Failed to clear persistent data: $e');
      return false;
    }
  }
}
