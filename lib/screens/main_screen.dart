import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/music_provider.dart';
import '../widgets/bottom_music_player.dart';
import '../services/shortcut_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'playlists_screen.dart';
import 'playlist_detail_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final ShortcutService _shortcutService = ShortcutService();
  late PageController _pageController;
  late AnimationController _navigationAnimationController;
  late Animation<double> _navigationAnimation;
  
  List<Widget> get _screens => [
    HomeScreen(onNavigateToTab: _navigateToTab),
    const SearchScreen(),
    const LibraryScreen(),
    const PlaylistsScreen(),
  ];
  
  // Navigation icons data
  final List<Map<String, dynamic>> _navigationItems = [
    {
      'icon': Icons.home_rounded,
      'activeIcon': Icons.home,
      'label': 'Home',
      'color': AppTheme.primaryColor,
    },
    {
      'icon': Icons.search_rounded,
      'activeIcon': Icons.search,
      'label': 'Search',
      'color': AppTheme.secondaryColor,
    },
    {
      'icon': Icons.library_music_rounded,
      'activeIcon': Icons.library_music,
      'label': 'Library',
      'color': AppTheme.successColor,
    },
    {
      'icon': Icons.queue_music_rounded,
      'activeIcon': Icons.queue_music,
      'label': 'Playlists',
      'color': AppTheme.warningColor,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _navigationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navigationAnimation = CurvedAnimation(
      parent: _navigationAnimationController,
      curve: Curves.easeInOut,
    );
    _initializeShortcuts();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _navigationAnimationController.dispose();
    super.dispose();
  }
  
  void _initializeShortcuts() async {
    await _shortcutService.initialize();
    _shortcutService.onShortcutPressed = (playlistId) {
      _handlePlaylistShortcut(playlistId);
    };
  }
  
  void _handlePlaylistShortcut(String playlistId) {
    _navigateToTab(3);
    
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final playlist = musicProvider.playlists.firstWhere(
      (p) => p['id'] == playlistId,
      orElse: () => <String, dynamic>{},
    );
    
    if (playlist.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.push(
            context,
            _createSlideRoute(PlaylistDetailScreen(playlist: playlist)),
          );
        }
      });
    } else {
      _showErrorSnackBar('Playlist not found');
    }
  }
  
  void _navigateToTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _navigationAnimationController.forward().then((_) {
        _navigationAnimationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildModernAppBar(context, themeProvider),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: _screens,
            ),
          ),
          const BottomMusicPlayer(),
        ],
      ),
      bottomNavigationBar: _buildModernBottomNavigation(context, isDark),
    );
  }
  
  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'Library';
      case 3:
        return 'Playlists';
      default:
        return 'SoundWave';
    }
  }
  
  PreferredSizeWidget _buildModernAppBar(BuildContext context, ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: AppTheme.spacingLarge,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          _getTitle(),
          key: ValueKey(_currentIndex),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: AppTheme.spacingMedium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
          ),
          child: IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(themeProvider.isDarkMode),
              ),
            ),
            onPressed: () {
              themeProvider.toggleTheme();
              // Add haptic feedback
              HapticFeedback.lightImpact();
            },
            tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ),
      ],
    );
  }
  
  Widget _buildModernBottomNavigation(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLarge,
            vertical: AppTheme.spacingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavItem(context, index, isDark),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(BuildContext context, int index, bool isDark) {
    final item = _navigationItems[index];
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        _navigateToTab(index);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          color: isSelected 
            ? (item['color'] as Color).withOpacity(0.1)
            : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                color: isSelected 
                  ? item['color'] as Color
                  : Colors.transparent,
              ),
              child: Icon(
                isSelected ? item['activeIcon'] : item['icon'],
                color: isSelected 
                  ? Colors.white
                  : Theme.of(context).iconTheme.color?.withOpacity(0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: AppTheme.spacingExtraSmall),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: isSelected 
                  ? item['color'] as Color
                  : Theme.of(context).textTheme.labelSmall?.color?.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(item['label']),
            ),
          ],
        ),
      ),
    );
  }
  
  PageRouteBuilder _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMedium),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
