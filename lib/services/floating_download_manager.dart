import 'package:flutter/material.dart';

class DownloadItem {
  final String id;
  final String title;
  final String thumbnail;
  double progress;
  bool isCompleted;
  bool isPaused;
  bool isError;
  String? errorMessage;
  VoidCallback? onCancel;
  VoidCallback? onRetry;

  DownloadItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isPaused = false,
    this.isError = false,
    this.errorMessage,
    this.onCancel,
    this.onRetry,
  });
}

class FloatingDownloadManager extends ChangeNotifier {
  static final FloatingDownloadManager _instance = FloatingDownloadManager._internal();
  factory FloatingDownloadManager() => _instance;
  FloatingDownloadManager._internal();

  final List<DownloadItem> _downloads = [];
  final Map<String, Offset> _positions = {};
  bool _isVisible = true;

  List<DownloadItem> get downloads => List.unmodifiable(_downloads);
  bool get hasActiveDownloads => _downloads.any((d) => !d.isCompleted && !d.isError);
  bool get isVisible => _isVisible && _downloads.isNotEmpty;

  void addDownload(DownloadItem download) {
    _downloads.add(download);
    // Position new downloads in a stack on the right side
    final screenHeight = 800.0; // Will be updated with actual screen height
    final startY = 100.0 + (_downloads.length - 1) * 80.0;
    _positions[download.id] = Offset(300.0, startY.clamp(100.0, screenHeight - 200.0));
    notifyListeners();
  }

  void updateDownload(String id, {
    double? progress,
    bool? isCompleted,
    bool? isPaused,
    bool? isError,
    String? errorMessage,
  }) {
    final index = _downloads.indexWhere((d) => d.id == id);
    if (index != -1) {
      final download = _downloads[index];
      if (progress != null) download.progress = progress;
      if (isCompleted != null) download.isCompleted = isCompleted;
      if (isPaused != null) download.isPaused = isPaused;
      if (isError != null) download.isError = isError;
      if (errorMessage != null) download.errorMessage = errorMessage;
      notifyListeners();

      // Auto-remove completed downloads after 3 seconds
      if (download.isCompleted) {
        Future.delayed(const Duration(seconds: 3), () {
          removeDownload(id);
        });
      }
    }
  }

  void updatePosition(String id, Offset position) {
    _positions[id] = position;
    notifyListeners();
  }

  Offset getPosition(String id) {
    return _positions[id] ?? const Offset(300.0, 100.0);
  }

  void removeDownload(String id) {
    _downloads.removeWhere((d) => d.id == id);
    _positions.remove(id);
    notifyListeners();
  }

  void pauseDownload(String id) {
    updateDownload(id, isPaused: true);
  }

  void resumeDownload(String id) {
    updateDownload(id, isPaused: false);
  }

  void cancelDownload(String id) {
    final download = _downloads.firstWhere((d) => d.id == id);
    download.onCancel?.call();
    removeDownload(id);
  }

  void retryDownload(String id) {
    final download = _downloads.firstWhere((d) => d.id == id);
    download.onRetry?.call();
    updateDownload(id, isError: false, errorMessage: null, progress: 0.0);
  }

  void clearAll() {
    _downloads.clear();
    _positions.clear();
    notifyListeners();
  }

  // Static convenience methods for easy access
  static void startDownload({
    required String id,
    required String title,
    required String thumbnail,
    VoidCallback? onCancel,
    VoidCallback? onRetry,
  }) {
    final instance = FloatingDownloadManager();
    instance.addDownload(DownloadItem(
      id: id,
      title: title,
      thumbnail: thumbnail,
      onCancel: onCancel,
      onRetry: onRetry,
    ));
  }

  static void updateProgress(String id, double progress) {
    FloatingDownloadManager().updateDownload(id, progress: progress);
  }

  static void completeDownload(String id) {
    FloatingDownloadManager().updateDownload(id, isCompleted: true, progress: 1.0);
  }

  static void errorDownload(String id, String error) {
    FloatingDownloadManager().updateDownload(id, isError: true, errorMessage: error);
  }

  void toggleVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  void show() {
    _isVisible = true;
    notifyListeners();
  }

  void hide() {
    _isVisible = false;
    notifyListeners();
  }
}
