import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/playlist.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/song_card.dart';
import '../widgets/playlist_card.dart';

/// Home screen displaying music discovery and recommendations
/// Main entry point showcasing trending and personalized content
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial home content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: Load trending songs and playlists
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Neru Music',
          style: AppTextStyles.h3,
        ),
        actions: [
          IconButton(
            onPressed: () => _navigateToSearch(context),
            icon: const Icon(Icons.search),
            color: AppTheme.primaryText,
          ),
          IconButton(
            onPressed: () => _showProfile(context),
            icon: const Icon(Icons.person),
            color: AppTheme.primaryText,
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            _buildQuickActions(),
            _buildTrendingSongs(),
            _buildFeaturedPlaylists(),
            _buildRecommendedForYou(),
            _buildRecentlyPlayed(),
            const SizedBox(height: AppConstants.largePadding),
          ],
        ),
      ),
    );
  }

  /// Builds welcome section with greeting
  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTextStyles.h2.copyWith(
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'What would you like to listen to?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppTheme.primaryText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.music_note,
              color: AppTheme.primaryText,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds quick action buttons
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.shuffle,
              label: 'Shuffle Play',
              onTap: () => _shufflePlay(),
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.favorite,
              label: 'Liked Songs',
              onTap: () => _navigateToLikedSongs(),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual quick action button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryPurple,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds trending songs section
  Widget _buildTrendingSongs() {
    return Column(
      children: [
        SectionHeader(
          title: 'Trending Now',
          subtitle: 'Popular songs everyone is listening to',
          action: TextButton(
            onPressed: () => _viewAllTrending(),
            child: Text(
              'View All',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // TODO: Replace with actual trending songs from state
        HorizontalList(
          height: 280,
          children: List.generate(
            5,
            (index) => Container(
              width: 160,
              margin: const EdgeInsets.only(right: AppConstants.defaultPadding),
              child: _buildTrendingSongCard(index),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds trending song card placeholder
  Widget _buildTrendingSongCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.mediumRadius),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.music_note,
                color: AppTheme.primaryText,
                size: 40,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Song ${index + 1}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Popular Artist',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      color: AppTheme.primaryPurple,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(index + 1) * 123}K plays',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds featured playlists section
  Widget _buildFeaturedPlaylists() {
    return Column(
      children: [
        SectionHeader(
          title: 'Featured Playlists',
          subtitle: 'Curated collections for every mood',
          action: TextButton(
            onPressed: () => _viewAllPlaylists(),
            child: Text(
              'View All',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // TODO: Replace with actual playlists from state
        HorizontalList(
          height: 200,
          children: List.generate(
            5,
            (index) => Container(
              width: 160,
              margin: const EdgeInsets.only(right: AppConstants.defaultPadding),
              child: PlaylistCard(
                playlist: _createDummyPlaylist(index),
                size: PlaylistCardSize.small,
                onTap: () => _openPlaylist(index),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds recommended section
  Widget _buildRecommendedForYou() {
    return Column(
      children: [
        SectionHeader(
          title: 'Recommended for You',
          subtitle: 'Based on your listening history',
        ),
        // TODO: Replace with actual recommendations
        ...List.generate(
          3,
          (index) => SongCard(
            song: _createDummySong(index),
            onTap: () => _playSong(index),
            onMoreTap: () => _showSongOptions(index),
          ),
        ),
      ],
    );
  }

  /// Builds recently played section
  Widget _buildRecentlyPlayed() {
    return Column(
      children: [
        SectionHeader(
          title: 'Recently Played',
          subtitle: 'Continue where you left off',
        ),
        HorizontalList(
          height: 200,
          children: List.generate(
            5,
            (index) => Container(
              width: 160,
              margin: const EdgeInsets.only(right: AppConstants.defaultPadding),
              child: PlaylistCard(
                playlist: _createDummyPlaylist(index + 10),
                size: PlaylistCardSize.small,
                onTap: () => _openPlaylist(index + 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Navigation methods
  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).pushNamed('/search');
  }

  void _showProfile(BuildContext context) {
    // TODO: Implement profile screen navigation
  }

  void _shufflePlay() {
    // TODO: Implement shuffle play functionality
  }

  void _navigateToLikedSongs() {
    // TODO: Implement liked songs navigation
  }

  void _viewAllTrending() {
    // TODO: Implement view all trending
  }

  void _viewAllPlaylists() {
    // TODO: Implement view all playlists
  }

  void _openPlaylist(int index) {
    // TODO: Implement playlist navigation
  }

  void _playSong(int index) {
    // TODO: Implement song playback
  }

  void _showSongOptions(int index) {
    // TODO: Implement song options menu
  }

  // Helper methods for dummy data
  Playlist _createDummyPlaylist(int index) {
    return Playlist(
      id: 'playlist_$index',
      name: 'Playlist ${index + 1}',
      songs: [],
      description: 'A great collection of songs',
      imageUrl: null,
      creator: 'Neru Music',
    );
  }

  Song _createDummySong(int index) {
    return Song(
      id: 'song_$index',
      title: 'Amazing Song ${index + 1}',
      artist: 'Great Artist',
      duration: 180000 + (index * 30000),
      albumArt: null,
      album: 'Popular Album',
      audioUrl: null,
    );
  }
}
