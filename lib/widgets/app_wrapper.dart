import 'package:flutter/material.dart';
import '../services/version_check_service.dart';
import '../screens/main_screen.dart';
import '../screens/force_update_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_ui_widgets.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isCheckingVersion = true;
  bool _requiresForceUpdate = false;
  VersionInfo? _updateVersionInfo;

  @override
  void initState() {
    super.initState();
    _checkForForceUpdate();
  }

  Future<void> _checkForForceUpdate() async {
    try {
      // Wait a bit for the app to fully initialize
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Always check on app start for force updates
      final updateStatus = await VersionCheckService.checkForUpdate();
      
      if (!mounted) return;
      
      setState(() {
        _isCheckingVersion = false;
        _requiresForceUpdate = updateStatus.forceUpdate && updateStatus.updateAvailable;
        _updateVersionInfo = updateStatus.versionInfo;
      });
      
    } catch (e) {
      print('Force update check failed: $e');
      // On error, allow app to continue
      if (mounted) {
        setState(() {
          _isCheckingVersion = false;
          _requiresForceUpdate = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingVersion) {
      return _buildModernLoadingScreen();
    }

    if (_requiresForceUpdate && _updateVersionInfo != null) {
      return ForceUpdateScreen(versionInfo: _updateVersionInfo!);
    }

    return const MainScreen();
  }
  
  Widget _buildModernLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradientLinear,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo with pulse animation
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.8, end: 1.2),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation
                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 40),
              // App name
              Text(
                'SoundWave',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              // Tagline
              Text(
                'Your Music, Your Way',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 60),
              // Modern loading indicator
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Initializing...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
