import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
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
        final recentMusic = musicProvider.library
            .where((song) => song['addedAt'] != null)
            .toList();
            
        recentMusic.sort((a, b) {
          try {
            return DateTime.parse(b['addedAt'])
                .compareTo(DateTime.parse(a['addedAt']));
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
        Text(
          'Let the music play!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
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
            // Add shuffle all functionality
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
    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLarge,
        vertical: AppTheme.spacingSmall,
      ),
      child: InkWell(
        onTap: () => _navigateToScreen(context, PlayerScreen(song: song)),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Hero(
                tag: 'thumbnail_${song['id']}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  child: CachedNetworkImage(
                    imageUrl: song['thumbnail'] ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.withOpacity(0.1),
                      child: const Center(
                        child: Icon(Icons.music_note_rounded),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.withOpacity(0.1),
                      child: const Center(
                        child: Icon(Icons.error_outline_rounded),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song['title'] ?? 'Unknown Title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
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
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.play_arrow_rounded),
                color: AppTheme.primaryColor,
                iconSize: 32,
                onPressed: () => _navigateToScreen(context, PlayerScreen(song: song)),
              ),
            ],
          ),
        ),
      ),
    );
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
