import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataPersistenceService {
  static const String _backupFileName = 'soundwave_backup.json';
  static const String _backupVersion = '1.0';
  
  // External storage directory that survives app uninstall
  static Future<Directory> get _externalDataDir async {
    if (Platform.isAndroid) {
      // Use external storage directory that survives app uninstall
      final externalDir = Directory('/storage/emulated/0/SoundWave');
      if (!await externalDir.exists()) {
        await externalDir.create(recursive: true);
      }
      return externalDir;
    } else {
      // For other platforms, use documents directory
      return await getApplicationDocumentsDirectory();
    }
  }
  
  // Internal app data directory (gets deleted on uninstall)
  static Future<Directory> get _internalDataDir async {
    return await getApplicationDocumentsDirectory();
  }
  
  /// Create a complete backup of all app data
  static Future<bool> createBackup({
    required Map<String, dynamic> library,
    required Map<String, dynamic> playlists,
    required Map<String, dynamic> settings,
    required Map<String, dynamic> downloadHistory,
  }) async {
    try {
      final backupData = {
        'version': _backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'library': library,
        'playlists': playlists,
        'settings': settings,
        'downloadHistory': downloadHistory,
      };
      
      final backupFile = File('${await _externalDataDir}/$_backupFileName');
      await backupFile.writeAsString(jsonEncode(backupData));
      
      print('✅ Data backup created successfully at: ${backupFile.path}');
      return true;
    } catch (e) {
      print('❌ Failed to create backup: $e');
      return false;
    }
  }
  
  /// Restore app data from backup
  static Future<Map<String, dynamic>?> restoreBackup() async {
    try {
      final backupFile = File('${await _externalDataDir}/$_backupFileName');
      
      if (!await backupFile.exists()) {
        print('ℹ️ No backup file found');
        return null;
      }
      
      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;
      
      // Validate backup version
      final backupVersion = backupData['version'] as String?;
      if (backupVersion != _backupVersion) {
        print('⚠️ Backup version mismatch: expected $_backupVersion, got $backupVersion');
        // Could implement version migration here
      }
      
      print('✅ Data backup restored successfully');
      return backupData;
    } catch (e) {
      print('❌ Failed to restore backup: $e');
      return null;
    }
  }
  
  /// Check if backup exists
  static Future<bool> backupExists() async {
    try {
      final backupFile = File('${await _externalDataDir}/$_backupFileName');
      return await backupFile.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Get backup file info
  static Future<Map<String, dynamic>?> getBackupInfo() async {
    try {
      final backupFile = File('${await _externalDataDir}/$_backupFileName');
      
      if (!await backupFile.exists()) {
        return null;
      }
      
      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;
      
      return {
        'version': backupData['version'],
        'timestamp': backupData['timestamp'],
        'fileSize': await backupFile.length(),
        'filePath': backupFile.path,
      };
    } catch (e) {
      print('❌ Failed to get backup info: $e');
      return null;
    }
  }
  
  /// Delete backup file
  static Future<bool> deleteBackup() async {
    try {
      final backupFile = File('${await _externalDataDir}/$_backupFileName');
      if (await backupFile.exists()) {
        await backupFile.delete();
        print('✅ Backup file deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Failed to delete backup: $e');
      return false;
    }
  }
  
  /// Migrate data from internal storage to external storage
  static Future<bool> migrateDataToExternal() async {
    try {
      final internalPrefs = await SharedPreferences.getInstance();
      
      // Get all data from internal storage
      final library = internalPrefs.getString('library');
      final playlists = internalPrefs.getString('playlists');
      final settings = internalPrefs.getString('settings');
      final downloadHistory = internalPrefs.getString('downloadHistory');
      
      // Create backup in external storage
      final success = await createBackup(
        library: library != null ? jsonDecode(library) : {},
        playlists: playlists != null ? jsonDecode(playlists) : {},
        settings: settings != null ? jsonDecode(settings) : {},
        downloadHistory: downloadHistory != null ? jsonDecode(downloadHistory) : {},
      );
      
      if (success) {
        print('✅ Data migration to external storage completed');
        return true;
      } else {
        print('❌ Data migration failed');
        return false;
      }
    } catch (e) {
      print('❌ Data migration error: $e');
      return false;
    }
  }
  
  /// Check if data exists in external storage
  static Future<bool> hasExternalData() async {
    try {
      final backupFile = File('${await _externalDataDir}/$_backupFileName');
      return await backupFile.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Get external data directory path
  static Future<String> getExternalDataPath() async {
    final dir = await _externalDataDir;
    return dir.path;
  }
  
  /// Get internal data directory path
  static Future<String> getInternalDataPath() async {
    final dir = await _internalDataDir;
    return dir.path;
  }
}
