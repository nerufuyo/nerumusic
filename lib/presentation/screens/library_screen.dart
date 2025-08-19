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

/// Library screen displaying user's music collection
/// Shows playlists, liked songs, downloads, and recently played
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Your Library',
          style: AppTextStyles.h3,
        ),
        actions: [
          IconButton(
            onPressed: () => _showSortOptions(),
            icon: const Icon(Icons.sort),
            color: AppTheme.primaryText,
          ),
          IconButton(
            onPressed: () => _showMoreOptions(),
            icon: const Icon(Icons.more_vert),
            color: AppTheme.primaryText,
          ),
        ],
        bottom: _buildTabBar(),
      ),
      body: Column(
        children: [
          _buildQuickAccess(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlaylistsTab(),
                _buildLikedSongsTab(),
                _buildDownloadsTab(),
                _buildRecentlyPlayedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds tab bar for library sections
  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppTheme.primaryPurple,
      labelColor: AppTheme.primaryPurple,
      unselectedLabelColor: AppTheme.tertiaryText,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTextStyles.bodySmall,
      tabs: const [
        Tab(text: 'Playlists'),
        Tab(text: 'Liked'),
        Tab(text: 'Downloads'),
        Tab(text: 'Recent'),
      ],
    );
  }

  /// Builds quick access section
  Widget _buildQuickAccess() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _buildQuickAccessItem(
            icon: Icons.favorite,
            title: 'Liked Songs',
            subtitle: '${_getLikedSongsCount()} songs',
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.8),
                Colors.pink.withValues(alpha: 0.8),
              ],
            ),
            onTap: () => _navigateToLikedSongs(),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessItem(
                  icon: Icons.download,
                  title: 'Downloads',
                  subtitle: '${_getDownloadsCount()} songs',
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.8),
                      Colors.teal.withValues(alpha: 0.8),
                    ],
                  ),
                  onTap: () => _navigateToDownloads(),
                ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: _buildQuickAccessItem(
                  icon: Icons.history,
                  title: 'Recent',
                  subtitle: 'Last played',
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withValues(alpha: 0.8),
                      Colors.red.withValues(alpha: 0.8),
                    ],
                  ),
                  onTap: () => _navigateToRecent(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds individual quick access item
  Widget _buildQuickAccessItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
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
                  color: AppTheme.primaryText,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTheme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppTheme.primaryText.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds playlists tab
  Widget _buildPlaylistsTab() {
    final playlists = _getUserPlaylists();
    
    if (playlists.isEmpty) {
      return const EmptyState(
        icon: Icons.library_music,
        title: 'No Playlists Yet',
        message: 'Create your first playlist to get started',
        actionLabel: 'Create Playlist',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: playlists.length + 1, // +1 for create playlist button
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildCreatePlaylistButton();
        }
        
        final playlist = playlists[index - 1];
        return PlaylistTile(
          playlist: playlist,
          onTap: () => _openPlaylist(playlist),
          onMoreTap: () => _showPlaylistOptions(playlist),
        );
      },
    );
  }

  /// Builds liked songs tab
  Widget _buildLikedSongsTab() {
    final likedSongs = _getLikedSongs();
    
    if (likedSongs.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_outline,
        title: 'No Liked Songs',
        message: 'Songs you like will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
      itemCount: likedSongs.length,
      itemBuilder: (context, index) {
        final song = likedSongs[index];
        return SongCard(
          song: song,
          onTap: () => _playSong(song),
          onMoreTap: () => _showSongOptions(song),
        );
      },
    );
  }

  /// Builds downloads tab
  Widget _buildDownloadsTab() {
    final downloads = _getDownloadedSongs();
    
    if (downloads.isEmpty) {
      return const EmptyState(
        icon: Icons.download_outlined,
        title: 'No Downloads',
        message: 'Downloaded songs will appear here for offline listening',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final song = downloads[index];
        return SongCard(
          song: song,
          onTap: () => _playSong(song),
          onMoreTap: () => _showSongOptions(song),
        );
      },
    );
  }

  /// Builds recently played tab
  Widget _buildRecentlyPlayedTab() {
    final recentSongs = _getRecentlyPlayedSongs();
    
    if (recentSongs.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'No Recent Activity',
        message: 'Songs you play will appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
      itemCount: recentSongs.length,
      itemBuilder: (context, index) {
        final song = recentSongs[index];
        return SongCard(
          song: song,
          onTap: () => _playSong(song),
          onMoreTap: () => _showSongOptions(song),
        );
      },
    );
  }

  /// Builds create playlist button
  Widget _buildCreatePlaylistButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _createNewPlaylist(),
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppTheme.primaryPurple,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Text(
                  'Create Playlist',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Data methods (placeholder implementations)
  List<Playlist> _getUserPlaylists() {
    // TODO: Get user playlists from state management
    return [];
  }

  List<Song> _getLikedSongs() {
    // TODO: Get liked songs from state management
    return [];
  }

  List<Song> _getDownloadedSongs() {
    // TODO: Get downloaded songs from state management
    return [];
  }

  List<Song> _getRecentlyPlayedSongs() {
    // TODO: Get recently played songs from state management
    return [];
  }

  int _getLikedSongsCount() => _getLikedSongs().length;
  int _getDownloadsCount() => _getDownloadedSongs().length;

  // Action methods
  void _showSortOptions() {
    // TODO: Implement sort options bottom sheet
    debugPrint('Show sort options');
  }

  void _showMoreOptions() {
    // TODO: Implement more options bottom sheet
    debugPrint('Show more options');
  }

  void _navigateToLikedSongs() {
    _tabController.animateTo(1);
  }

  void _navigateToDownloads() {
    _tabController.animateTo(2);
  }

  void _navigateToRecent() {
    _tabController.animateTo(3);
  }

  void _openPlaylist(Playlist playlist) {
    // TODO: Navigate to playlist detail screen
    debugPrint('Open playlist: ${playlist.name}');
  }

  void _showPlaylistOptions(Playlist playlist) {
    // TODO: Show playlist options bottom sheet
    debugPrint('Show playlist options: ${playlist.name}');
  }

  void _playSong(Song song) {
    // TODO: Play song
    debugPrint('Play song: ${song.title}');
  }

  void _showSongOptions(Song song) {
    // TODO: Show song options bottom sheet
    debugPrint('Show song options: ${song.title}');
  }

  void _createNewPlaylist() {
    // TODO: Show create playlist dialog
    debugPrint('Create new playlist');
  }
}
