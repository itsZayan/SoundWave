import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/floating_download_manager.dart';
import 'download_progress_dialog.dart';

class FloatingDownloadOverlay extends StatelessWidget {
  const FloatingDownloadOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FloatingDownloadManager>(
      builder: (context, downloadManager, child) {
        if (downloadManager.downloads.isEmpty) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: downloadManager.downloads.map((download) {
            return FloatingDownloadCircle(download: download);
          }).toList(),
        );
      },
    );
  }
}

class FloatingDownloadCircle extends StatefulWidget {
  final DownloadItem download;

  const FloatingDownloadCircle({required this.download, super.key});

  @override
  State<FloatingDownloadCircle> createState() => _FloatingDownloadCircleState();
}

class _FloatingDownloadCircleState extends State<FloatingDownloadCircle>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _completionController;
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _particleController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _completionAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _particleAnimation;
  
  Offset _position = const Offset(300.0, 100.0);
  bool _isDragging = false;
  bool _showParticles = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _completionAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticInOut,
    ));

    // Start entrance animation
    _scaleController.forward();
    
    // Get initial position
    final downloadManager = Provider.of<FloatingDownloadManager>(context, listen: false);
    _position = downloadManager.getPosition(widget.download.id);
  }

  @override
  void didUpdateWidget(FloatingDownloadCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Trigger completion animation when download completes
    if (!oldWidget.download.isCompleted && widget.download.isCompleted) {
      _completionController.forward().then((_) {
        _completionController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position = Offset(
        (_position.dx + details.delta.dx).clamp(0.0, MediaQuery.of(context).size.width - 70),
        (_position.dy + details.delta.dy).clamp(50.0, MediaQuery.of(context).size.height - 150),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    
    // Update position in manager
    final downloadManager = Provider.of<FloatingDownloadManager>(context, listen: false);
    downloadManager.updatePosition(widget.download.id, _position);
  }

  void _onTap() {
    _showDownloadDialog();
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return DownloadProgressDialog(
          title: widget.download.title,
          videoId: widget.download.id,
          onCancel: (id) {
            Navigator.of(context).pop();
            final downloadManager = Provider.of<FloatingDownloadManager>(context, listen: false);
            downloadManager.cancelDownload(id);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _completionAnimation]),
      builder: (context, child) {
        return Positioned(
          left: _position.dx,
          top: _position.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value * _completionAnimation.value,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                });
              },
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTap: _onTap,
              child: AnimatedContainer(
                duration: Duration(milliseconds: _isDragging ? 0 : 300),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: _isDragging ? 15 : 8,
                      offset: Offset(0, _isDragging ? 8 : 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background image
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: ClipOval(
                        child: widget.download.thumbnail.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.download.thumbnail,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.music_note, color: Colors.grey),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.music_note, color: Colors.grey),
                                ),
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.music_note, color: Colors.grey),
                              ),
                      ),
                    ),
                    
                    // Progress indicator
                    if (!widget.download.isCompleted && !widget.download.isError)
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          value: widget.download.progress / 100,
                          strokeWidth: 3,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.download.isPaused ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    
                    // Center content
                    Center(
                      child: _buildCenterContent(),
                    ),
                    
                    // Completion checkmark
                    if (widget.download.isCompleted)
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(0.9),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterContent() {
    if (widget.download.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: const Text(
          'Done!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else if (widget.download.isError) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.error,
          color: Colors.white,
          size: 20,
        ),
      );
    } else if (widget.download.isPaused) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.pause,
          color: Colors.white,
          size: 20,
        ),
      );
    } else {
      // Show percentage
      return Container(
        padding: const EdgeInsets.all(4),
        child: Text(
          '${widget.download.progress.toInt()}%',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
