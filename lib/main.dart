import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers/theme_provider.dart';
import 'providers/music_provider.dart';
import 'services/audio_service.dart';
import 'services/shortcut_service.dart';
import 'services/floating_download_manager.dart';
import 'screens/main_screen.dart';
import 'screens/player_screen.dart';
import 'services/audio_player_task.dart';
import 'package:audio_service/audio_service.dart';
import 'screens/add_music_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/force_update_screen.dart';
import 'services/version_check_service.dart';
import 'widgets/floating_download_widget.dart';
import 'widgets/app_wrapper.dart';
import 'services/audio_handler.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    print('SoundWave: App starting...');
    
    // Only set system UI mode on mobile platforms
    if (!kIsWeb) {
      try {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        print('SoundWave: System UI mode set');
      } catch (e) {
        print('SoundWave: Failed to set system UI mode: $e');
      }
      
      // Initialize AudioService for notifications and background playback
      try {
        print('SoundWave: Initializing AudioService...');
        await AudioService.init(
          builder: () => AudioHandlerImpl(),
          config: const AudioServiceConfig(
            androidNotificationChannelId: 'com.soundwave.audio',
            androidNotificationChannelName: 'SoundWave Audio',
            androidNotificationChannelDescription: 'Audio and video playback controls',
            androidNotificationIcon: 'mipmap/ic_launcher',
            androidShowNotificationBadge: true,
            androidStopForegroundOnPause: true, // Required when androidNotificationOngoing is true
            androidNotificationOngoing: false, // Non-persistent notification for better UX
            androidNotificationClickStartsActivity: true,
          ),
        );
        print('SoundWave: AudioService initialized successfully');
      } catch (e) {
        print('SoundWave: Failed to initialize AudioService: $e');
        // Continue without AudioService if initialization fails
      }
    } else {
      print('SoundWave: Skipping AudioService initialization on web');
    }
    
    print('SoundWave: Running app...');
    runApp(const SoundWaveApp());
  } catch (e, stackTrace) {
    print('SoundWave: Fatal error in main: $e');
    print('SoundWave: Stack trace: $stackTrace');
    // Run a minimal app in case of error
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error starting app: $e'),
            ],
          ),
        ),
      ),
    ));
  }
}

class SoundWaveApp extends StatefulWidget {
  const SoundWaveApp({super.key});

  @override
  State<SoundWaveApp> createState() => _SoundWaveAppState();
}

class _SoundWaveAppState extends State<SoundWaveApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('SoundWave: Initializing app components...');
      
      // Add any initialization logic here
      // For example: loading preferences, initializing services, etc.
      await Future.delayed(const Duration(milliseconds: 2000)); // Simulate initialization
      
      print('SoundWave: App initialization complete');
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('SoundWave: Error during initialization: $e');
      // Still mark as initialized to show the main app (with error handling)
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          onInitializationComplete: () {
            // This callback is handled by the _initializeApp method above
          },
        ),
      );
    }

    try {
      print('SoundWave: Building main app widget...');
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            print('SoundWave: Creating ThemeProvider');
            return ThemeProvider();
          }),
          ChangeNotifierProvider(create: (_) {
            print('SoundWave: Creating MusicProvider');
            return MusicProvider();
          }),
          ChangeNotifierProvider(create: (_) {
            print('SoundWave: Creating GlobalAudioService');
            return GlobalAudioService();
          }),
          ChangeNotifierProvider(create: (_) {
            print('SoundWave: Creating FloatingDownloadManager');
            return FloatingDownloadManager();
          }),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            print('SoundWave: Building MaterialApp with theme');
            return MaterialApp(
              title: 'SoundWave',
              debugShowCheckedModeBanner: false,
              theme: themeProvider.currentTheme,
              home: const AppWrapper(),
              builder: (context, child) {
                return Stack(
                  children: [
                    child ?? const Scaffold(
                      body: Center(
                        child: Text('Failed to load app'),
                      ),
                    ),
                    const FloatingDownloadOverlay(),
                  ],
                );
              },
            );
          },
        ),
      );
    } catch (e, stackTrace) {
      print('SoundWave: Error building app: $e');
      print('SoundWave: Stack trace: $stackTrace');
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error building app: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app initialization
                    setState(() {
                      _isInitialized = false;
                    });
                    _initializeApp();
                  },
                  child: const Text('Restart App'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
