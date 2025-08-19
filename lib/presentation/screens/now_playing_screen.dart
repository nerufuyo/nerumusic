import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/song.dart';
import '../controllers/audio_player_controller.dart';

/// Repeat mode enum for player controls
enum RepeatMode { off, all, one }

/// Full-screen now playing interface
/// Provides complete music control with queue and lyrics
class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  
  bool _showQueue = false;
  bool _showLyrics = false;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_rotationController);

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(audioPlayerControllerProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                children: [
                  _buildMainPlayerView(playerState),
                  _buildQueueView(),
                  _buildLyricsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds header with navigation and options
  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.keyboard_arrow_down),
              color: AppTheme.primaryText,
              iconSize: 32,
            ),
            const Spacer(),
            Text(
              'Now Playing',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppTheme.primaryText,
              ),
              color: AppTheme.darkCard,
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'queue',
                  child: Row(
                    children: [
                      Icon(Icons.queue_music, color: AppTheme.primaryText),
                      SizedBox(width: 12),
                      Text('View Queue', style: TextStyle(color: AppTheme.primaryText)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'lyrics',
                  child: Row(
                    children: [
                      Icon(Icons.lyrics, color: AppTheme.primaryText),
                      SizedBox(width: 12),
                      Text('Show Lyrics', style: TextStyle(color: AppTheme.primaryText)),
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
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryText),
                      SizedBox(width: 12),
                      Text('Song Info', style: TextStyle(color: AppTheme.primaryText)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds main player view with album art and controls
  Widget _buildMainPlayerView(AudioPlayerState playerState) {
    final currentSong = playerState.currentSong;
    
    if (currentSong == null) {
      return const Center(
        child: Text(
          'No song playing',
          style: AppTextStyles.h3,
        ),
      );
    }

    // Update rotation animation based on playing state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (playerState.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          const Spacer(),
          _buildAlbumArt(currentSong),
          const SizedBox(height: AppConstants.largePadding),
          _buildSongInfo(currentSong),
          const SizedBox(height: AppConstants.largePadding),
          _buildProgressSection(playerState),
          const SizedBox(height: AppConstants.largePadding),
          _buildPlayerControls(playerState),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSecondaryControls(playerState),
          const Spacer(),
        ],
      ),
    );
  }

  /// Builds rotating album artwork
  Widget _buildAlbumArt(Song song) {
    return Hero(
      tag: 'album_art_${song.id}',
      child: RotationTransition(
        turns: _rotationAnimation,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(150),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(150),
            child: song.albumArt != null
                ? CachedNetworkImage(
                    imageUrl: song.albumArt!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildAlbumPlaceholder(),
                    errorWidget: (context, url, error) => _buildAlbumPlaceholder(),
                  )
                : _buildAlbumPlaceholder(),
          ),
        ),
      ),
    );
  }

  /// Builds album art placeholder
  Widget _buildAlbumPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(150),
      ),
      child: const Icon(
        Icons.music_note,
        color: AppTheme.primaryText,
        size: 100,
      ),
    );
  }

  /// Builds song information
  Widget _buildSongInfo(Song song) {
    return Column(
      children: [
        Text(
          song.title,
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        GestureDetector(
          onTap: () => _navigateToArtist(song.artist),
          child: Text(
            song.artist,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppTheme.secondaryText,
              decoration: TextDecoration.underline,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (song.album != null) ...[
          const SizedBox(height: 4),
          Text(
            song.album!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.tertiaryText,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Builds progress section with seeker
  Widget _buildProgressSection(AudioPlayerState playerState) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppTheme.primaryPurple,
            inactiveTrackColor: AppTheme.darkBorder,
            thumbColor: AppTheme.primaryPurple,
            overlayColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: playerState.position.inMilliseconds.toDouble(),
            max: playerState.duration.inMilliseconds.toDouble(),
            onChanged: (value) {
              ref.read(audioPlayerControllerProvider.notifier)
                  .seekTo(Duration(milliseconds: value.round()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TimeUtils.formatDuration(playerState.position.inMilliseconds),
                style: AppTextStyles.caption,
              ),
              Text(
                TimeUtils.formatDuration(playerState.duration.inMilliseconds),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds main player controls
  Widget _buildPlayerControls(AudioPlayerState playerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => _previousSong(),
          icon: const Icon(Icons.skip_previous),
          color: AppTheme.primaryText,
          iconSize: 40,
        ),
        _buildPlayPauseButton(playerState.isPlaying),
        IconButton(
          onPressed: () => _nextSong(),
          icon: const Icon(Icons.skip_next),
          color: AppTheme.primaryText,
          iconSize: 40,
        ),
      ],
    );
  }

  /// Builds play/pause button
  Widget _buildPlayPauseButton(bool isPlaying) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _togglePlayPause(),
          borderRadius: BorderRadius.circular(40),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppTheme.primaryText,
            size: 40,
          ),
        ),
      ),
    );
  }

  /// Builds secondary controls
  Widget _buildSecondaryControls(AudioPlayerState playerState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => _toggleShuffle(),
          icon: const Icon(Icons.shuffle),
          color: _isShuffleEnabled ? AppTheme.primaryPurple : AppTheme.tertiaryText,
        ),
        IconButton(
          onPressed: () => _toggleLike(),
          icon: Icon(
            _isCurrentSongLiked() ? Icons.favorite : Icons.favorite_outline,
            color: _isCurrentSongLiked() ? AppTheme.primaryPurple : AppTheme.tertiaryText,
          ),
        ),
        IconButton(
          onPressed: () => _toggleRepeat(),
          icon: Icon(
            _repeatMode == RepeatMode.one ? Icons.repeat_one : Icons.repeat,
          ),
          color: _repeatMode != RepeatMode.off ? AppTheme.primaryPurple : AppTheme.tertiaryText,
        ),
      ],
    );
  }

  /// Builds queue view
  Widget _buildQueueView() {
    return const Center(
      child: Text(
        'Queue View\n(Coming Soon)',
        style: AppTextStyles.h3,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds lyrics view
  Widget _buildLyricsView() {
    return const Center(
      child: Text(
        'Lyrics View\n(Coming Soon)',
        style: AppTextStyles.h3,
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper methods
  bool _isCurrentSongLiked() {
    // TODO: Check if current song is liked
    return false;
  }

  // Action methods
  void _handleMenuAction(String action) {
    switch (action) {
      case 'queue':
        setState(() {
          _showQueue = !_showQueue;
        });
        break;
      case 'lyrics':
        setState(() {
          _showLyrics = !_showLyrics;
        });
        break;
      case 'share':
        _shareCurrentSong();
        break;
      case 'info':
        _showSongInfo();
        break;
    }
  }

  void _previousSong() {
    // TODO: Implement previous song logic
    debugPrint('Previous song');
  }

  void _nextSong() {
    // TODO: Implement next song logic
    debugPrint('Next song');
  }

  void _togglePlayPause() {
    final playerState = ref.read(audioPlayerControllerProvider);
    if (playerState.isPlaying) {
      ref.read(audioPlayerControllerProvider.notifier).pause();
    } else {
      ref.read(audioPlayerControllerProvider.notifier).resume();
    }
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffleEnabled = !_isShuffleEnabled;
    });
    // TODO: Implement shuffle logic
    debugPrint('Shuffle toggled: $_isShuffleEnabled');
  }

  void _toggleRepeat() {
    setState(() {
      switch (_repeatMode) {
        case RepeatMode.off:
          _repeatMode = RepeatMode.all;
          break;
        case RepeatMode.all:
          _repeatMode = RepeatMode.one;
          break;
        case RepeatMode.one:
          _repeatMode = RepeatMode.off;
          break;
      }
    });
    // TODO: Implement repeat logic
    debugPrint('Repeat mode: $_repeatMode');
  }

  void _navigateToArtist(String artistName) {
    // TODO: Navigate to artist profile
    debugPrint('Navigate to artist: $artistName');
  }

  void _toggleLike() {
    // TODO: Toggle like status for current song
    debugPrint('Toggle like for current song');
  }

  void _shareCurrentSong() {
    // TODO: Share current song
    debugPrint('Share current song');
  }

  void _showSongInfo() {
    // TODO: Show song information dialog
    debugPrint('Show song info');
  }
}
