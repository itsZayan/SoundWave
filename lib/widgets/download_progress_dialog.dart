import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class DownloadProgressDialog extends StatefulWidget {
  final String title;
  final String videoId;
  final Function(String) onCancel;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final GlobalKey<DownloadProgressDialogState>? dialogKey;

  const DownloadProgressDialog({
    Key? key,
    required this.title,
    required this.videoId,
    required this.onCancel,
    this.onPause,
    this.onResume,
    this.dialogKey,
  }) : super(key: key);

  @override
  DownloadProgressDialogState createState() => DownloadProgressDialogState();
}

class DownloadProgressDialogState extends State<DownloadProgressDialog>
    with TickerProviderStateMixin {
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  bool _isPaused = false;
  bool _isCompleted = false;
  bool _hasError = false;
  String _status = 'Initializing download...';
  String _errorMessage = '';

  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _progressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _scaleController.forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void updateProgress(double progress, int received, int total) {
    if (mounted) {
      setState(() {
        _progress = progress;
        _receivedBytes = received;
        _totalBytes = total;
        _status = 'Downloading... ${(progress * 100).toInt()}%';
      });
      _progressController.animateTo(progress);
    }
  }

  void setCompleted() {
    if (mounted) {
      setState(() {
        _progress = 1.0;
        _isCompleted = true;
        _status = 'Download completed!';
      });
      _progressController.animateTo(1.0);
      _rotationController.stop();
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void setError(String error) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = error;
        _status = 'Download failed';
      });
      _rotationController.stop();
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) return '${bytesPerSecond} B/s';
    if (bytesPerSecond < 1024 * 1024) return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  Color get _getStatusColor {
    if (_hasError) return Colors.red;
    if (_isCompleted) return Colors.green;
    if (_isPaused) return Colors.orange;
    return const Color(0xFF6366F1);
  }

  IconData get _getStatusIcon {
    if (_hasError) return Icons.error_outline;
    if (_isCompleted) return Icons.check_circle_outline;
    if (_isPaused) return Icons.pause_circle_outline;
    return Icons.download;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PopScope(
      canPop: true, // Always allow dismissing
      onPopInvoked: (didPop) {
        // Don't cancel download when dialog is dismissed
        // Downloads will continue in background
        // Only show cancellation confirmation if user explicitly clicks cancel button
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.black.withOpacity(0.7)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark 
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(isDark),
                      const SizedBox(height: 24),
                      _buildProgressSection(isDark),
                      const SizedBox(height: 24),
                      _buildActionButtons(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getStatusColor,
                _getStatusColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getStatusColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _hasError || _isCompleted || _isPaused
              ? Icon(
                  _getStatusIcon,
                  color: Colors.white,
                  size: 28,
                )
              : AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: Icon(
                        _getStatusIcon,
                        color: Colors.white,
                        size: 28,
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _hasError ? 'Download Failed' : 
                _isCompleted ? 'Download Complete' :
                _isPaused ? 'Download Paused' : 'Downloading',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(bool isDark) {
    return Column(
      children: [
        // Circular Progress Indicator
        Container(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark 
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
              // Progress circle
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _progressAnimation.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor),
                      strokeCap: StrokeCap.round,
                    ),
                  );
                },
              ),
              // Percentage text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (_totalBytes > 0)
                    Text(
                      '${_formatBytes(_receivedBytes)} / ${_formatBytes(_totalBytes)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Status text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getStatusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getStatusColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            _hasError ? _errorMessage : _status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _getStatusColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    if (_isCompleted) {
      return Container(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text(
            'Done',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      );
    }

    if (_hasError) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        if (!_isPaused && _progress < 1.0) ...
        [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isPaused = true;
                  _status = 'Download paused';
                });
                widget.onPause?.call();
              },
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (_isPaused) ...
        [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isPaused = false;
                  _status = 'Resuming download...';
                });
                widget.onResume?.call();
              },
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                'Resume',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              widget.onCancel(widget.videoId);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
