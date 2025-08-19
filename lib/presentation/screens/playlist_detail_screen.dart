import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../controllers/audio_player_controller.dart';
import '../widgets/layout_widgets.dart';

/// Playlist detail screen showing playlist information and songs
/// Features shuffled playback, song management, and sharing options
class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final String playlistId;
  
  const PlaylistDetailScreen({
    required this.playlistId,
    super.key,
  });

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerOpacityAnimation;
  
  bool _isHeaderCollapsed = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _headerOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_headerAnimationController);
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const double threshold = 200.0;
    final bool shouldCollapse = _scrollController.offset > threshold;
    
    if (shouldCollapse != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = shouldCollapse;
      });
      
      if (shouldCollapse) {
        _headerAnimationController.forward();
      } else {
        _headerAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // For now, create a dummy playlist since we don't have playlist controller
    final playlist = Playlist(
      id: widget.playlistId,
      name: 'Sample Playlist',
      songs: [],
      description: 'A sample playlist for demonstration',
      imageUrl: null,
      creator: 'User',
      createdAt: DateTime.now(),
    );
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(playlist),
          _buildPlaylistInfo(playlist),
          _buildActionButtons(playlist),
          _buildSongsList(playlist),
        ],
      ),
    );
  }

  /// Builds collapsing app bar with playlist cover
  Widget _buildSliverAppBar(Playlist playlist) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      foregroundColor: AppTheme.primaryText,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double percentage = ((constraints.maxHeight - kToolbarHeight) / 
              (300 - kToolbarHeight)).clamp(0.0, 1.0);
          
          return FlexibleSpaceBar(
            title: AnimatedBuilder(
              animation: _headerOpacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _headerOpacityAnimation.value,
                  child: Text(
                    playlist.name,
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryPurple.withValues(alpha: 0.7),
                    AppTheme.darkBackground,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  if (playlist.imageUrl != null)
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: playlist.imageUrl!,
                        fit: BoxFit.cover,
                        color: Colors.black.withValues(alpha: 0.3),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                  Positioned(
                    bottom: 20 + kToolbarHeight,
                    left: AppConstants.defaultPadding,
                    right: AppConstants.defaultPadding,
                    child: Opacity(
                      opacity: percentage,
                      child: _buildHeaderContent(playlist),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          color: AppTheme.darkCard,
          onSelected: (value) => _handleMenuAction(value, playlist),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppTheme.primaryText),
                  SizedBox(width: 12),
                  Text('Edit Playlist', style: TextStyle(color: AppTheme.primaryText)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, color: AppTheme.primaryText),
                  SizedBox(width: 12),
                  Text('Share', style: TextStyle(color: AppTheme.primaryText)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download, color: AppTheme.primaryText),
                  SizedBox(width: 12),
                  Text('Download', style: TextStyle(color: AppTheme.primaryText)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppTheme.errorColor),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds header content for the expanded app bar
  Widget _buildHeaderContent(Playlist playlist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (playlist.imageUrl == null)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.library_music,
              color: AppTheme.primaryText,
              size: 60,
            ),
          ),
        const SizedBox(height: AppConstants.defaultPadding),
        Text(
          playlist.name,
          style: AppTextStyles.h1,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        if (playlist.description != null)
          Text(
            playlist.description!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.secondaryText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// Builds playlist metadata information
  Widget _buildPlaylistInfo(Playlist playlist) {
    final totalDuration = _calculateTotalDuration(playlist.songs);
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            if (playlist.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: playlist.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildCoverPlaceholder(60),
                  errorWidget: (context, url, error) => _buildCoverPlaceholder(60),
                ),
              )
            else
              _buildCoverPlaceholder(60),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.music_note,
                        color: AppTheme.secondaryText,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${playlist.songs.length} songs',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppTheme.secondaryText,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        TimeUtils.formatLongDuration(totalDuration),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme.secondaryText,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        playlist.createdAt != null 
                            ? TimeUtils.timeAgo(playlist.createdAt!)
                            : 'Unknown',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds action buttons for play and shuffle
  Widget _buildActionButtons(Playlist playlist) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _playPlaylist(playlist, shuffle: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: AppTheme.primaryText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play All'),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _playPlaylist(playlist, shuffle: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryText,
                  side: const BorderSide(color: AppTheme.primaryPurple),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds list of songs in the playlist
  Widget _buildSongsList(Playlist playlist) {
    if (playlist.songs.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.library_music,
          title: 'No songs in playlist',
          message: 'Add some songs to get started',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final song = playlist.songs[index];
            return _buildSongTile(song, index, playlist);
          },
          childCount: playlist.songs.length,
        ),
      ),
    );
  }

  /// Builds individual song tile
  Widget _buildSongTile(Song song, int index, Playlist playlist) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: AppTheme.primaryGradient,
        ),
        child: song.albumArt != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: song.albumArt!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Icon(
                    Icons.music_note,
                    color: AppTheme.primaryText,
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.music_note,
                    color: AppTheme.primaryText,
                  ),
                ),
              )
            : const Icon(
                Icons.music_note,
                color: AppTheme.primaryText,
              ),
      ),
      title: Text(
        song.title,
        style: AppTextStyles.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: AppTextStyles.caption,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            TimeUtils.formatDuration(song.duration),
            style: AppTextStyles.caption,
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppTheme.secondaryText,
            ),
            color: AppTheme.darkCard,
            onSelected: (value) => _handleSongAction(value, song),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'play',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, color: AppTheme.primaryText),
                    SizedBox(width: 12),
                    Text('Play Now', style: TextStyle(color: AppTheme.primaryText)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'next',
                child: Row(
                  children: [
                    Icon(Icons.queue_music, color: AppTheme.primaryText),
                    SizedBox(width: 12),
                    Text('Play Next', style: TextStyle(color: AppTheme.primaryText)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.remove_circle, color: AppTheme.errorColor),
                    SizedBox(width: 12),
                    Text('Remove from Playlist', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () => _playSongAt(index, playlist),
    );
  }

  /// Builds cover image placeholder
  Widget _buildCoverPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.library_music,
        color: AppTheme.primaryText,
        size: size * 0.5,
      ),
    );
  }

  // Helper methods
  int _calculateTotalDuration(List<Song> songs) {
    return songs.fold(0, (total, song) => total + song.duration);
  }

  // Action methods
  void _playPlaylist(Playlist playlist, {required bool shuffle}) {
    if (playlist.songs.isNotEmpty) {
      // TODO: Implement playlist playback with shuffle option
      final firstSong = shuffle ? (playlist.songs..shuffle()).first : playlist.songs.first;
      ref.read(audioPlayerControllerProvider.notifier).playSong(firstSong);
      debugPrint('Playing playlist: ${playlist.name}, shuffle: $shuffle');
    }
  }

  void _playSongAt(int index, Playlist playlist) {
    if (index < playlist.songs.length) {
      final song = playlist.songs[index];
      ref.read(audioPlayerControllerProvider.notifier).playSong(song);
      debugPrint('Playing song: ${song.title}');
    }
  }

  void _handleMenuAction(String action, Playlist playlist) {
    switch (action) {
      case 'edit':
        _editPlaylist(playlist);
        break;
      case 'share':
        _sharePlaylist(playlist);
        break;
      case 'download':
        _downloadPlaylist(playlist);
        break;
      case 'delete':
        _deletePlaylist(playlist);
        break;
    }
  }

  void _handleSongAction(String action, Song song) {
    switch (action) {
      case 'play':
        ref.read(audioPlayerControllerProvider.notifier).playSong(song);
        break;
      case 'next':
        // TODO: Add to play queue
        debugPrint('Add to queue: ${song.title}');
        break;
      case 'remove':
        _removeSongFromPlaylist(song);
        break;
    }
  }

  void _editPlaylist(Playlist playlist) {
    // TODO: Navigate to edit playlist screen
    debugPrint('Edit playlist: ${playlist.name}');
  }

  void _sharePlaylist(Playlist playlist) {
    // TODO: Implement playlist sharing
    debugPrint('Share playlist: ${playlist.name}');
  }

  void _downloadPlaylist(Playlist playlist) {
    // TODO: Implement playlist download
    debugPrint('Download playlist: ${playlist.name}');
  }

  void _deletePlaylist(Playlist playlist) {
    // TODO: Show confirmation dialog and delete playlist
    debugPrint('Delete playlist: ${playlist.name}');
  }

  void _removeSongFromPlaylist(Song song) {
    // TODO: Remove song from current playlist
    debugPrint('Remove song from playlist: ${song.title}');
  }
}
