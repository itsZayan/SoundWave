import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/music_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_ui_widgets.dart';
import '../services/download_service.dart';
import 'add_music_screen.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        // Get all downloaded and imported songs
        final allSongs = <Map<String, dynamic>>[];
        allSongs.addAll(musicProvider.getDownloadedSongs());
        allSongs.addAll(musicProvider.getImportedSongs());
        
        // Also get songs from library that have been played at least once
        final librarySongs = musicProvider.library;
        allSongs.addAll(librarySongs);
        
        // Remove duplicates based on ID
        final uniqueSongs = <String, Map<String, dynamic>>{};
        for (final song in allSongs) {
          final id = song['id'] ?? song['url'] ?? song['title'];
          if (id != null && !uniqueSongs.containsKey(id)) {
            uniqueSongs[id] = song;
          }
        }
        
        final recentMusic = uniqueSongs.values.toList();
        
        // Sort by recently added or last played
        recentMusic.sort((a, b) {
          try {
            final aTime = DateTime.tryParse(a['addedAt'] ?? a['lastPlayedAt'] ?? '') ?? DateTime(1970);
            final bTime = DateTime.tryParse(b['addedAt'] ?? b['lastPlayedAt'] ?? '') ?? DateTime(1970);
            return bTime.compareTo(aTime);
          } catch (e) {
            return 0;
          }
        });
        
        final displayedMusic = recentMusic.take(6).toList();
        final hasMusic = displayedMusic.isNotEmpty;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(context),
                        const SizedBox(height: AppTheme.spacingExtraLarge),
                        _buildQuickActionsSection(context),
                        if (hasMusic) ...[
                          const SizedBox(height: AppTheme.spacingExtraLarge),
                          _buildSectionHeader(
                            context,
                            'Recently Added',
                            'View All',
                            () => widget.onNavigateToTab?.call(2),
                          ),
                          const SizedBox(height: AppTheme.spacingLarge),
                        ],
                      ],
                    ),
                  ),
                ),
                if (hasMusic)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildModernMusicItem(
                        context,
                        displayedMusic[index],
                        index,
                      ),
                      childCount: displayedMusic.length,
                    ),
                  ),
                if (!hasMusic)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(context),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppTheme.spacingExtraLarge * 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Row(
          children: [
            Text(
              'Let the music play!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradientLinear,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'v1.0.1',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQuickActionsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildModernQuickAction(
          context,
          icon: Icons.add_circle_outline_rounded,
          label: 'Add Music',
          color: AppTheme.primaryColor,
          onTap: () => _navigateToScreen(context, const AddMusicScreen()),
        ),
        _buildModernQuickAction(
          context,
          icon: Icons.queue_music_rounded,
          label: 'Playlists',
          color: AppTheme.secondaryColor,
          onTap: () => widget.onNavigateToTab?.call(3),
        ),
        _buildModernQuickAction(
          context,
          icon: Icons.shuffle_rounded,
          label: 'Shuffle All',
          color: AppTheme.successColor,
          onTap: () {
            final musicProvider = Provider.of<MusicProvider>(context, listen: false);
            musicProvider.shuffleAll();
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }
  
  Widget _buildModernQuickAction(
    BuildContext context,
    {
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap,
    }
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ModernCard(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingExtraSmall),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.8),
                  color,
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(
    BuildContext context, 
    String title, 
    String actionText, 
    VoidCallback onActionPressed
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        TextButton(
          onPressed: onActionPressed,
          child: Text(
            actionText,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryColor,
                ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildModernMusicItem(BuildContext context, Map<String, dynamic> song, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLarge,
                vertical: AppTheme.spacingSmall,
              ),
              child: ModernCard(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _navigateToScreen(context, PlayerScreen(song: song));
                },
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                showBorder: true,
                child: Row(
                  children: [
                    // Album art with modern styling
                    Hero(
                      tag: 'thumbnail_${song['id']}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          boxShadow: AppTheme.modernShadow,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          child: CachedNetworkImage(
                            imageUrl: song['thumbnail'] ?? '',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => ShimmerLoading(
                              isLoading: true,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                ),
                                child: const Icon(Icons.music_note_rounded, color: Colors.grey),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                              ),
                              child: Icon(
                                Icons.music_note_rounded,
                                color: AppTheme.primaryColor,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),
                    // Song info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song['title'] ?? 'Unknown Title',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingExtraSmall),
                          Text(
                            song['artist'] ?? 'Unknown Artist',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          if (song['duration'] != null) ...[
                            const SizedBox(height: AppTheme.spacingExtraSmall),
                            Text(
                              _formatDuration(song['duration']),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Modern play button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradientLinear,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _navigateToScreen(context, PlayerScreen(song: song));
                          },
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
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
  
  String _formatDuration(dynamic duration) {
    if (duration == null) return '';
    
    int seconds = 0;
    if (duration is String) {
      seconds = int.tryParse(duration) ?? 0;
    } else if (duration is int) {
      seconds = duration;
    }
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              'Your Library is Empty',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Add music from YouTube to get started.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingExtraLarge),
            ElevatedButton.icon(
              onPressed: () => _navigateToScreen(context, const AddMusicScreen()),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Music'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

// Floating Action Button overlay widget
class HomeScreenWithFAB extends StatelessWidget {
  final Function(int)? onNavigateToTab;
  
  const HomeScreenWithFAB({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeScreen(onNavigateToTab: onNavigateToTab),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddMusicScreen(),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
