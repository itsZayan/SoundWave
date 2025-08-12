import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionInfo {
  final String latestVersion;
  final String minimumVersion;
  final String downloadUrl;
  final String releaseNotes;
  final bool forceUpdate;
  final String releaseDate;

  VersionInfo({
    required this.latestVersion,
    required this.minimumVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.forceUpdate,
    required this.releaseDate,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      latestVersion: json['latest_version'] ?? '',
      minimumVersion: json['minimum_version'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      releaseNotes: json['release_notes'] ?? '',
      forceUpdate: json['force_update'] ?? false,
      releaseDate: json['release_date'] ?? '',
    );
  }
}

class UpdateStatus {
  final bool updateAvailable;
  final bool forceUpdate;
  final VersionInfo? versionInfo;

  UpdateStatus({
    required this.updateAvailable,
    required this.forceUpdate,
    this.versionInfo,
  });
}

class VersionCheckService {
  // Replace this with your actual GitHub raw file URL
  static const String _versionCheckUrl = 
      'https://raw.githubusercontent.com/itsZayan/SoundWave/main/version_info.json';
  
  static const String _lastCheckKey = 'last_version_check';
  static const String _skipVersionKey = 'skip_version_';
  
  /// Check if app update is available
  static Future<UpdateStatus> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Fetch version info from GitHub
      final response = await http.get(
        Uri.parse(_versionCheckUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        return UpdateStatus(updateAvailable: false, forceUpdate: false);
      }
      
      final versionInfo = VersionInfo.fromJson(json.decode(response.body));
      
      // Compare versions
      final updateAvailable = _isVersionNewer(versionInfo.latestVersion, currentVersion);
      
      // Smart force update logic:
      // - Manual force update from JSON
      // - Major version changes (x.0.0) force update
      // - Minor updates (1.x.0, 1.0.x) are optional
      final isMajorUpdate = _isMajorVersionChange(versionInfo.latestVersion, currentVersion);
      final forceUpdate = versionInfo.forceUpdate || 
                         _isVersionNewer(versionInfo.minimumVersion, currentVersion) ||
                         isMajorUpdate;
      
      // Update last check time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastCheckKey, DateTime.now().millisecondsSinceEpoch);
      
      return UpdateStatus(
        updateAvailable: updateAvailable,
        forceUpdate: forceUpdate,
        versionInfo: updateAvailable ? versionInfo : null,
      );
      
    } catch (e) {
      // If version check fails, don't block the app
      print('Version check failed: $e');
      return UpdateStatus(updateAvailable: false, forceUpdate: false);
    }
  }
  
  /// Check if we should perform version check (not too frequent)
  static Future<bool> shouldCheckVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Check once per day
    const checkInterval = 24 * 60 * 60 * 1000; // 24 hours in milliseconds
    return (now - lastCheck) > checkInterval;
  }
  
  /// Mark a version as skipped (user chose not to update)
  static Future<void> skipVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_skipVersionKey$version', true);
  }
  
  /// Check if user has already skipped this version
  static Future<bool> isVersionSkipped(String version) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_skipVersionKey$version') ?? false;
  }
  
  /// Check if this is a major version change (only x.0.0 changes)
  /// Examples:
  /// - 1.0.0 -> 2.0.0 = Major (force update)
  /// - 1.0.0 -> 1.1.0 = Minor (optional)
  /// - 1.0.0 -> 1.0.1 = Patch (optional)
  static bool _isMajorVersionChange(String newVersion, String currentVersion) {
    final newParts = newVersion.split('.').map(int.parse).toList();
    final currentParts = currentVersion.split('.').map(int.parse).toList();
    
    // Ensure both have same length
    while (newParts.length < currentParts.length) newParts.add(0);
    while (currentParts.length < newParts.length) currentParts.add(0);
    
    // Only major version changes (first number) require force update
    // 1.x.x -> 2.x.x = Major change = Force update
    // 1.0.x -> 1.1.x = Minor change = Optional
    // 1.0.0 -> 1.0.1 = Patch change = Optional
    return newParts[0] > currentParts[0];
  }
  
  /// Compare two version strings (returns true if newVersion > currentVersion)
  static bool _isVersionNewer(String newVersion, String currentVersion) {
    final newParts = newVersion.split('.').map(int.parse).toList();
    final currentParts = currentVersion.split('.').map(int.parse).toList();
    
    // Ensure both have same length
    while (newParts.length < currentParts.length) newParts.add(0);
    while (currentParts.length < newParts.length) currentParts.add(0);
    
    for (int i = 0; i < newParts.length; i++) {
      if (newParts[i] > currentParts[i]) return true;
      if (newParts[i] < currentParts[i]) return false;
    }
    
    return false; // Versions are equal
  }
}
