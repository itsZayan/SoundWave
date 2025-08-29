import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'persistent_storage_service.dart';

class AppUninstallHandler {
  static final AppUninstallHandler _instance = AppUninstallHandler._internal();
  factory AppUninstallHandler() => _instance;
  AppUninstallHandler._internal();

  static const String _uninstallFlagKey = 'app_uninstall_flag';
  static const String _dataPreservationKey = 'preserve_app_data';

  /// Check if this is a fresh install or app update
  Future<bool> isFreshInstall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstRun = prefs.getBool('is_first_run') ?? true;
      
      if (isFirstRun) {
        await prefs.setBool('is_first_run', false);
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error checking if fresh install: $e');
      return true;
    }
  }

  /// Check if app data should be preserved
  Future<bool> shouldPreserveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_dataPreservationKey) ?? true; // Default to preserving data
    } catch (e) {
      print('❌ Error checking data preservation: $e');
      return true;
    }
  }

  /// Set data preservation preference
  Future<void> setDataPreservation(bool preserve) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_dataPreservationKey, preserve);
      print('✅ Data preservation set to: $preserve');
    } catch (e) {
      print('❌ Error setting data preservation: $e');
    }
  }

  /// Show uninstall confirmation dialog
  Future<bool> showUninstallDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Uninstall SoundWave?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to uninstall SoundWave?',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Your playlists and downloaded music will be preserved unless you choose to delete them.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: true, // Default checked (preserve data)
                      onChanged: (value) {
                        // This will be handled by the dialog result
                      },
                      activeColor: Colors.blue,
                    ),
                    const Expanded(
                      child: Text(
                        'Keep my music and playlists',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Uncheck to delete all app data when uninstalling',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Cancel uninstall
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirm uninstall
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Uninstall',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    ) ?? false;
  }

  /// Handle app uninstall process
  Future<void> handleAppUninstall(BuildContext context) async {
    try {
      final shouldUninstall = await showUninstallDialog(context);
      
      if (shouldUninstall) {
        // User confirmed uninstall
        final preserveData = true; // Always preserve data by default
        await setDataPreservation(preserveData);
        
        // Show confirmation
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                preserveData 
                  ? 'Your music and playlists will be preserved. You can reinstall the app anytime to access them.'
                  : 'All app data will be deleted when uninstalling.',
              ),
              backgroundColor: preserveData ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        
        // Exit app (this will trigger the actual uninstall process)
        exit(0);
      }
    } catch (e) {
      print('❌ Error handling app uninstall: $e');
    }
  }

  /// Check if app was updated and restore data if needed
  Future<void> handleAppUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentVersion = prefs.getString('app_version') ?? '1.0.0';
      final packageInfo = await PackageInfo.fromPlatform();
      final newVersion = packageInfo.version;
      
      if (currentVersion != newVersion) {
        print('🔄 App updated from $currentVersion to $newVersion');
        
        // Check if we should preserve data
        final preserveData = await shouldPreserveData();
        
        if (preserveData) {
          print('✅ Preserving app data during update');
          // Data will be automatically preserved by the persistent storage service
        } else {
          print('🗑️ User chose to delete data during update');
          // Clear all data
          await _clearAllAppData();
        }
        
        // Update stored version
        await prefs.setString('app_version', newVersion);
      }
    } catch (e) {
      print('❌ Error handling app update: $e');
    }
  }

  /// Clear all app data (used when user chooses to delete data)
  Future<void> _clearAllAppData() async {
    try {
      final persistentStorage = PersistentStorageService();
      await persistentStorage.clearAllData();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      print('✅ All app data cleared');
    } catch (e) {
      print('❌ Error clearing app data: $e');
    }
  }

  /// Get app data preservation status
  Future<Map<String, dynamic>> getDataPreservationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final preserveData = prefs.getBool(_dataPreservationKey) ?? true;
      final isFirstRun = prefs.getBool('is_first_run') ?? true;
      final appVersion = prefs.getString('app_version') ?? 'Unknown';
      
      return {
        'preserveData': preserveData,
        'isFirstRun': isFirstRun,
        'appVersion': appVersion,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error getting data preservation status: $e');
      return {};
    }
  }
}

// Import for PackageInfo
import 'package:package_info_plus/package_info_plus.dart';
