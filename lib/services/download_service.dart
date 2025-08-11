import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final YoutubeExplode _yt = YoutubeExplode();
  
  // RapidAPI configuration
  static const String _rapidApiHost = 'youtube-video-fast-downloader-24-7.p.rapidapi.com';
  static const String _rapidApiKey = 'bee51d2e46msh26a0858d506e2c7p1db0bbjsnca589c4b1fd0';

  // Download progress callbacks
  Function(double, int, int)? onDownloadProgress;
  Function(String)? onDownloadComplete;
  Function(String)? onDownloadError;
  Function(String)? onDownloadCanceled;
  
  // Active downloads tracking
  final Map<String, Timer> _progressTimers = {};
  final Map<String, bool> _activeDownloads = {};

  Future<Map<String, dynamic>?> _getVideoDetailsFromAPI(String videoId) async {
    try {
      final response = await _dio.get(
        'https://$_rapidApiHost/v2/video/details?videoId=$videoId&urlAccess=normal&videos=auto&audios=auto',
        options: Options(
          headers: {
            'x-rapidapi-host': _rapidApiHost,
            'x-rapidapi-key': _rapidApiKey,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        print('Failed to fetch video details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching video details: $e');
      return null;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
      
      return await Permission.storage.isGranted || 
             await Permission.manageExternalStorage.isGranted;
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }

  Future<String> _getDownloadDirectory() async {
    try {
      Directory? directory;
      
      if (Platform.isAndroid) {
        // Try to get external storage directory
        directory = Directory('/storage/emulated/0/Download/SoundWave');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        directory = await getDownloadsDirectory();
      }
      
      return directory?.path ?? (await getApplicationDocumentsDirectory()).path;
    } catch (e) {
      print('Directory error: $e');
      return (await getApplicationDocumentsDirectory()).path;
    }
  }

  Future<String?> _getAudioDownloadUrl(String videoId) async {
    try {
      final response = await _dio.get(
        'https://$_rapidApiHost/download_audio/$videoId?quality=251',
        options: Options(
          headers: {
            'x-rapidapi-host': _rapidApiHost,
            'x-rapidapi-key': _rapidApiKey,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // The API returns the direct download URL
        String? url = response.data['url'] ?? response.data.toString();
        if (url != null && url.isNotEmpty && _isValidUrl(url)) {
          return url;
        }
      }
      print('Failed to get audio download URL: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error getting audio download URL: $e');
      return null;
    }
  }
  
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<String?> downloadVideo(String url, {
    String? customName,
    Function(double, int, int)? onProgress,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    // Use youtube_explode_dart method directly
    return await _downloadVideoFallback(url, customName: customName, onProgress: onProgress, onComplete: onComplete, onError: onError);
  }

  Future<String?> downloadAudio(String url, {
    String? customName,
    Function(double, int, int)? onProgress,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    // Use youtube_explode_dart method directly
    return await _downloadAudioFallback(url, customName: customName, onProgress: onProgress, onComplete: onComplete, onError: onError);
  }

  Future<String?> _downloadAudioViaRapidAPI(String url, {
    String? customName,
    Function(double, int, int)? onProgress,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    try {
      // Request permissions
      if (!await requestPermissions()) {
        onError?.call('Storage permission required');
        return null;
      }

      // Extract video ID from URL
      final videoId = _extractVideoId(url);
      if (videoId == null) {
        onError?.call('Invalid YouTube URL');
        return null;
      }

      // Get video details from new API
      final videoDetails = await _getVideoDetailsFromAPI(videoId);
      if (videoDetails == null) {
        throw Exception('Failed to get video details from API');
      }
      
      final title = customName ?? _sanitizeFileName(videoDetails['title'] ?? 'Unknown');
      final downloadDir = await _getDownloadDirectory();
      final filePath = '$downloadDir/${title}_audio.m4a';

      // Check if file already exists
      if (await File(filePath).exists()) {
        onComplete?.call();
        return filePath;
      }

      // Create cancel token for this download
      final cancelToken = CancelToken();
      _cancelTokens[videoId] = cancelToken;

      try {
        // Get the best audio stream URL
        String? downloadUrl;
        
        if (videoDetails['audios'] != null && 
            videoDetails['audios']['status'] == true && 
            videoDetails['audios']['items'] != null) {
          final audioItems = videoDetails['audios']['items'] as List;
          if (audioItems.isNotEmpty) {
            // Get the best quality audio (first item is usually the best)
            final bestAudio = audioItems.first;
            downloadUrl = bestAudio['url'];
            print('Found audio stream: ${bestAudio['mimeType']} - ${bestAudio['sizeText']}');
          }
        }
        
        if (downloadUrl == null || downloadUrl.isEmpty) {
          throw Exception('No audio streams available');
        }
        
        print('Downloading audio from: $downloadUrl');
        
        // Download the audio file
        await _dio.download(
          downloadUrl,
          filePath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              onProgress?.call(progress, received, total);
            }
          },
        );

        // Save metadata
        await _saveMetadata(filePath, {
          'id': videoId,
          'title': videoDetails['title'],
          'author': videoDetails['channel']['name'],
          'duration': videoDetails['lengthSeconds'],
          'thumbnail': videoDetails['thumbnails']?.first['url'],
          'viewCount': videoDetails['viewCount'],
          'likeCount': videoDetails['likeCount'],
        });
        
        // Remove cancel token
        _cancelTokens.remove(videoId);
        
        onComplete?.call();
        return filePath;
        
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) {
          // Download was canceled
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete(); // Clean up partial file
          }
          _cancelTokens.remove(videoId);
          return null;
        } else {
          throw e;
        }
      }

    } catch (e) {
      print('RapidAPI audio download error: $e');
      throw e; // Re-throw to trigger fallback
    }
  }

  Future<String?> _downloadVideoViaRapidAPI(String url, {
    String? customName,
    Function(double, int, int)? onProgress,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    try {
      // Request permissions
      if (!await requestPermissions()) {
        onError?.call('Storage permission required');
        return null;
      }

      // Extract video ID from URL
      final videoId = _extractVideoId(url);
      if (videoId == null) {
        onError?.call('Invalid YouTube URL');
        return null;
      }

      // Get video details from new API
      final videoDetails = await _getVideoDetailsFromAPI(videoId);
      if (videoDetails == null) {
        onError?.call('Failed to get video details. Please check the video URL or try again later.');
        return null;
      }
      
      final title = customName ?? _sanitizeFileName(videoDetails['title'] ?? 'Unknown');
      final downloadDir = await _getDownloadDirectory();
      final filePath = '$downloadDir/${title}_video.mp4';

      // Check if file already exists
      if (await File(filePath).exists()) {
        onComplete?.call();
        return filePath;
      }

      // Create cancel token for this download
      final cancelToken = CancelToken();
      _cancelTokens[videoId] = cancelToken;

      try {
        // Get the best video stream URL (that contains audio)
        String? downloadUrl;
        
        if (videoDetails['videos'] != null && 
            videoDetails['videos']['status'] == true && 
            videoDetails['videos']['items'] != null) {
          final videoItems = videoDetails['videos']['items'] as List;
          if (videoItems.isNotEmpty) {
            // Find video stream with audio (hasAudio: true)
            final videoWithAudio = videoItems.firstWhere(
              (video) => video['hasAudio'] == true,
              orElse: () => videoItems.first,
            );
            downloadUrl = videoWithAudio['url'];
            print('Found video stream: ${videoWithAudio['mimeType']} - ${videoWithAudio['quality']} - Audio: ${videoWithAudio['hasAudio']}');
          }
        }
        
        if (downloadUrl == null || downloadUrl.isEmpty) {
          throw Exception('No video streams available');
        }
        
        print('Downloading video from: $downloadUrl');
        
        // Download the video file
        await _dio.download(
          downloadUrl,
          filePath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              onProgress?.call(progress, received, total);
            }
          },
        );

        // Save metadata
        await _saveMetadata(filePath, {
          'id': videoId,
          'title': videoDetails['title'],
          'author': videoDetails['channel']['name'],
          'duration': videoDetails['lengthSeconds'],
          'thumbnail': videoDetails['thumbnails']?.first['url'],
          'viewCount': videoDetails['viewCount'],
          'likeCount': videoDetails['likeCount'],
        });
        
        // Remove cancel token
        _cancelTokens.remove(videoId);
        
        onComplete?.call();
        return filePath;
        
      } on DioException catch (e) {
        if (CancelToken.isCancel(e)) {
          // Download was canceled
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete(); // Clean up partial file
          }
          _cancelTokens.remove(videoId);
          return null;
        } else {
          throw e;
        }
      }

    } catch (e) {
      print('RapidAPI video download error: $e');
      throw e; // Re-throw to trigger fallback
    }
  }

  Future<String?> _downloadVideoFallback(String url, {
    String? customName,
    Function(double, int, int)? onProgress,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    onError?.call('Video downloads are disabled.');
    return null;
  }

  Future<String?> _downloadAudioFallback(String url, {
    String? customName,
    Function(double, int, int)? onProgress,
    Function()? onComplete,
    Function(String)? onError,
  }) async {
    try {
      // Request permissions
      if (!await requestPermissions()) {
        onError?.call('Storage permission required');
        return null;
      }

      // Extract video ID from URL
      final videoId = _extractVideoId(url);
      if (videoId == null) {
        onError?.call('Invalid YouTube URL');
        return null;
      }

      // Try using youtube_explode_dart directly for more reliable downloads
      try {
        final video = await _yt.videos.get(videoId);
        final manifest = await _yt.videos.streamsClient.getManifest(videoId);
        
        // Get the best audio stream
        final audioStream = manifest.audioOnly.withHighestBitrate();
        if (audioStream == null) {
          throw Exception('No audio streams available');
        }

        final title = customName ?? _sanitizeFileName(video.title);
        final downloadDir = await _getDownloadDirectory();
        final filePath = '$downloadDir/$title.mp3';

        // Check if file already exists
        if (await File(filePath).exists()) {
          onComplete?.call();
          return filePath;
        }

        // Create cancel token
        final cancelToken = CancelToken();
        _cancelTokens[videoId] = cancelToken;

        // Download using Dio for progress tracking
        await _dio.download(
          audioStream.url.toString(),
          filePath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final progress = received / total;
              onProgress?.call(progress, received, total);
            }
          },
        );

        // Save metadata
        await _saveMetadata(filePath, {
          'id': videoId,
          'title': video.title,
          'author': video.author,
          'duration': video.duration?.inSeconds ?? 0,
          'thumbnail': video.thumbnails.highResUrl,
          'viewCount': video.engagement.viewCount,
        });

        onComplete?.call();
        return filePath;
      } catch (youtubeError) {
        print('YouTube Explode failed: $youtubeError');
        
        // Fallback to RapidAPI
        final downloadUrl = await _getAudioDownloadUrl(videoId);
        if (downloadUrl == null || !_isValidUrl(downloadUrl)) {
          onError?.call('Failed to get valid download link');
          return null;
        }
        
        final title = customName ?? videoId;
        final downloadDir = await _getDownloadDirectory();
        final filePath = '$downloadDir/${_sanitizeFileName(title)}.mp3';

        // Create cancel token
        final cancelToken = CancelToken();
        _cancelTokens[videoId] = cancelToken;

        // Download the audio file
        await _dio.download(
          downloadUrl,
          filePath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final progress = received / total;
              onProgress?.call(progress, received, total);
            }
          },
        );

        onComplete?.call();
        return filePath;
      }
    } catch (e) {
      onError?.call('Download failed: ${e.toString()}');
      return null;
    } finally {
      if (_cancelTokens.containsKey(_extractVideoId(url))) {
        _cancelTokens.remove(_extractVideoId(url));
      }
    }
  }
  
  void cancelDownload(String videoId) {
    final cancelToken = _cancelTokens[videoId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Download cancelled by user');
      _cancelTokens.remove(videoId);
    }
  }
  
  bool isDownloading(String videoId) {
    return _cancelTokens.containsKey(videoId);
  }

  Future<void> _saveMetadata(String filePath, Map<String, dynamic> videoInfo) async {
    try {
      final extension = filePath.endsWith('.mp3') ? '.mp3' : (filePath.endsWith('.m4a') ? '.m4a' : '.mp4');
      final metadataPath = filePath.replaceAll(extension, '.json');
      final fileType = (extension == '.mp3' || extension == '.m4a') ? 'audio' : 'video';
      
      // Create unique ID by combining original video ID with file type
      final originalId = videoInfo['id'];
      final uniqueId = '${originalId}_$fileType';
      
      final metadata = {
        ...videoInfo,
        'id': uniqueId, // Override with unique ID
        'originalVideoId': originalId, // Keep original for reference
        'downloadDate': DateTime.now().toIso8601String(),
        'localPath': filePath,
        'fileType': fileType,
      };
      
      await File(metadataPath).writeAsString(jsonEncode(metadata));
    } catch (e) {
      print('Error saving metadata: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDownloadedFiles() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      final directory = Directory(downloadDir);
      
      if (!await directory.exists()) return [];

      print('Scanning directory: $downloadDir');
      final files = await directory.list().toList();
      final mediaFiles = <Map<String, dynamic>>[];
      
      print('Found ${files.length} files in download directory');

      // Process files concurrently for better performance
      final futures = <Future<Map<String, dynamic>?>>[];

      for (final file in files) {
        if (file.path.endsWith('.json')) {
          futures.add(_processMetadataFile(file.path));
        }
      }
      
      final results = await Future.wait(futures);
      
      for (final result in results) {
        if (result != null) {
          mediaFiles.add(result);
        }
      }

      // Sort by download date (newest first)
      mediaFiles.sort((a, b) {
        final dateA = DateTime.tryParse(a['downloadDate'] ?? '') ?? DateTime(1970);
        final dateB = DateTime.tryParse(b['downloadDate'] ?? '') ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

      print('Loaded ${mediaFiles.length} media files');
      return mediaFiles;
    } catch (e) {
      print('Error getting downloaded files: $e');
      return [];
    }
  }
  
  Future<Map<String, dynamic>?> _processMetadataFile(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      final metadata = jsonDecode(content) as Map<String, dynamic>;
      
      // Check if media file still exists (but don't wait too long)
      final mediaPath = metadata['localPath'] as String;
      final mediaFile = File(mediaPath);
      
      // Use synchronous exists check for better performance
      if (mediaFile.existsSync()) {
        return metadata;
      } else {
        print('Media file missing: $mediaPath');
        return null;
      }
    } catch (e) {
      print('Error reading metadata file $filePath: $e');
      return null;
    }
  }

  Future<void> deleteDownload(String filePath) async {
    try {
      final file = File(filePath);
      final extension = filePath.endsWith('.mp3') ? '.mp3' : (filePath.endsWith('.m4a') ? '.m4a' : '.mp4');
      final metadataFile = File(filePath.replaceAll(extension, '.json'));
      
      if (await file.exists()) await file.delete();
      if (await metadataFile.exists()) await metadataFile.delete();
      
      Fluttertoast.showToast(msg: 'File deleted');
    } catch (e) {
      print('Error deleting file: $e');
      Fluttertoast.showToast(msg: 'Failed to delete file');
    }
  }

  String _sanitizeFileName(String fileName) {
    // Remove invalid characters for file names
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _extractVideoId(String url) {
    // Extract video ID from various YouTube URL formats including Shorts
    final regex = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|shorts\/|\S*?[?\&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regex.firstMatch(url);
    return match?.group(1);
  }


  // Sequential download method for both audio and video
  Future<Map<String, String?>> downloadBoth(
    String url, {
    String? customName,
    Function(String, double, int, int)? onProgress,
    Function(String)? onComplete,
    Function(String, String)? onError,
  }) async {
    final results = <String, String?>{};
    
    try {
      // Download video first
      final videoPath = await downloadVideo(
        url,
        customName: customName,
        onProgress: (progress, received, total) {
          onProgress?.call('video', progress, received, total);
        },
        onComplete: () {
          onComplete?.call('video');
        },
        onError: (error) {
          onError?.call('video', error);
        },
      );
      results['video'] = videoPath;
      
      // Then download audio
      final audioPath = await downloadAudio(
        url,
        customName: customName,
        onProgress: (progress, received, total) {
          onProgress?.call('audio', progress, received, total);
        },
        onComplete: () {
          onComplete?.call('audio');
        },
        onError: (error) {
          onError?.call('audio', error);
        },
      );
      results['audio'] = audioPath;
      
    } catch (e) {
      print('Error in sequential download: $e');
    }
    
    return results;
  }

  // Background download service - tracks active downloads
  final Map<String, bool> _backgroundDownloads = {};
  
  // Library refresh callbacks
  final List<VoidCallback> _libraryRefreshCallbacks = [];
  
  void addLibraryRefreshCallback(VoidCallback callback) {
    _libraryRefreshCallbacks.add(callback);
  }
  
  void removeLibraryRefreshCallback(VoidCallback callback) {
    _libraryRefreshCallbacks.remove(callback);
  }
  
  void _notifyLibraryRefresh() {
    for (final callback in _libraryRefreshCallbacks) {
      try {
        callback();
      } catch (e) {
        print('Error in library refresh callback: $e');
      }
    }
  }
  
  bool isDownloadingInBackground(String videoId) {
    return _backgroundDownloads[videoId] ?? false;
  }
  
  void setBackgroundDownload(String videoId, bool isDownloading) {
    _backgroundDownloads[videoId] = isDownloading;
  }
  
  void removeBackgroundDownload(String videoId) {
    _backgroundDownloads.remove(videoId);
    // Notify library to refresh when download completes
    _notifyLibraryRefresh();
  }

  // Storage tracking functionality
  Future<Map<String, double>> getStorageInfo() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      final directory = Directory(downloadDir);
      
      if (!await directory.exists()) {
        return {
          'usedSpace': 0.0,
          'totalFiles': 0.0,
          'availableSpace': 0.0,
        };
      }

      double totalSize = 0;
      int fileCount = 0;
      
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File && 
            (entity.path.endsWith('.mp3') || entity.path.endsWith('.mp4') || entity.path.endsWith('.m4a'))) {
          final stat = await entity.stat();
          totalSize += stat.size;
          fileCount++;
        }
      }

      // Get available space (simplified - in real app you'd use platform-specific methods)
      final availableSpace = await _getAvailableSpace();
      
      return {
        'usedSpace': totalSize / (1024 * 1024), // Convert to MB
        'totalFiles': fileCount.toDouble(),
        'availableSpace': availableSpace,
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {
        'usedSpace': 0.0,
        'totalFiles': 0.0,
        'availableSpace': 0.0,
      };
    }
  }

  Future<double> _getAvailableSpace() async {
    try {
      // This is a simplified implementation
      // In a real app, you'd use platform-specific methods to get actual available space
      return 1000.0; // Return 1GB as placeholder
    } catch (e) {
      return 0.0;
    }
  }

  // Offline mode functionality
  bool _isOfflineMode = false;
  bool get isOfflineMode => _isOfflineMode;
  
  void setOfflineMode(bool offline) {
    _isOfflineMode = offline;
    _notifyLibraryRefresh();
  }


  // Initialize notifications
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Show download progress notification
  Future<void> showDownloadNotification({
    required String title,
    required String body,
    required int progress,
    required int id,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Download progress notifications',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      onlyAlertOnce: true,
    );
    
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Resume interrupted downloads
  Future<void> resumeInterruptedDownloads() async {
    try {
      final tasks = await FileDownloader().database.allRecords();
      
      for (final record in tasks) {
        if (record.status == TaskStatus.paused ||
            record.status == TaskStatus.waitingToRetry) {
          if (record.task is DownloadTask) {
            await FileDownloader().resume(record.task as DownloadTask);
          }
        }
      }
    } catch (e) {
      print('Error resuming downloads: $e');
    }
  }

  void dispose() {
    _yt.close();
  }
}
