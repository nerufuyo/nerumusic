import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/song.dart';

/// Now playing bottom sheet for mini player functionality
/// Expandable player interface following design system
class NowPlayingBottomSheet extends StatefulWidget {
  const NowPlayingBottomSheet({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.position,
    required this.duration,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onSeek,
    this.onShuffle,
    this.onRepeat,
    this.isShuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
  });

  final Song song;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final ValueChanged<Duration>? onSeek;
  final VoidCallback? onShuffle;
  final VoidCallback? onRepeat;
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;

  @override
  State<NowPlayingBottomSheet> createState() => _NowPlayingBottomSheetState();
}

class _NowPlayingBottomSheetState extends State<NowPlayingBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _rotationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;

  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    
    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(NowPlayingBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppTheme.darkBackground,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.largeRadius),
          ),
        ),
        child: Column(
          children: [
            _buildDragHandle(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: Column(
                  children: [
                    const Spacer(),
                    _buildAlbumArt(),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildSongInfo(),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildProgressBar(),
                    const SizedBox(height: AppConstants.largePadding),
                    _buildControls(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    _buildSecondaryControls(),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds drag handle for bottom sheet
  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppTheme.darkBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Builds rotating album artwork
  Widget _buildAlbumArt() {
    return RotationTransition(
      turns: _rotationAnimation,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(140),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(140),
          child: widget.song.albumArt != null
              ? CachedNetworkImage(
                  imageUrl: widget.song.albumArt!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildAlbumPlaceholder(),
                  errorWidget: (context, url, error) => _buildAlbumPlaceholder(),
                )
              : _buildAlbumPlaceholder(),
        ),
      ),
    );
  }

  /// Builds album art placeholder
  Widget _buildAlbumPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(140),
      ),
      child: const Icon(
        Icons.music_note,
        color: AppTheme.primaryText,
        size: 80,
      ),
    );
  }

  /// Builds song information
  Widget _buildSongInfo() {
    return Column(
      children: [
        Text(
          widget.song.title,
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          widget.song.artist,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppTheme.secondaryText,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Builds progress bar with time labels
  Widget _buildProgressBar() {
    final progress = widget.duration.inMilliseconds > 0
        ? widget.position.inMilliseconds / widget.duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: AppTheme.primaryPurple,
            inactiveTrackColor: AppTheme.darkBorder,
            thumbColor: AppTheme.primaryPurple,
            overlayColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: _isDragging ? null : (value) {
              final newPosition = Duration(
                milliseconds: (value * widget.duration.inMilliseconds).round(),
              );
              widget.onSeek?.call(newPosition);
            },
            onChangeStart: (value) {
              _isDragging = true;
            },
            onChangeEnd: (value) {
              _isDragging = false;
              final newPosition = Duration(
                milliseconds: (value * widget.duration.inMilliseconds).round(),
              );
              widget.onSeek?.call(newPosition);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TimeUtils.formatDuration(widget.position.inMilliseconds),
                style: AppTextStyles.caption,
              ),
              Text(
                TimeUtils.formatDuration(widget.duration.inMilliseconds),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds main playback controls
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.skip_previous,
          onTap: widget.onPrevious,
          size: 32,
        ),
        _buildPlayPauseButton(),
        _buildControlButton(
          icon: Icons.skip_next,
          onTap: widget.onNext,
          size: 32,
        ),
      ],
    );
  }

  /// Builds play/pause button
  Widget _buildPlayPauseButton() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPlayPause,
          borderRadius: BorderRadius.circular(36),
          child: Icon(
            widget.isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppTheme.primaryText,
            size: 36,
          ),
        ),
      ),
    );
  }

  /// Builds secondary controls (shuffle, repeat)
  Widget _buildSecondaryControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.shuffle,
          onTap: widget.onShuffle,
          isActive: widget.isShuffleEnabled,
        ),
        _buildControlButton(
          icon: _getRepeatIcon(),
          onTap: widget.onRepeat,
          isActive: widget.repeatMode != RepeatMode.off,
        ),
      ],
    );
  }

  /// Builds individual control button
  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isActive = false,
    double size = 24,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryPurple.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Icon(
            icon,
            color: isActive ? AppTheme.primaryPurple : AppTheme.secondaryText,
            size: size,
          ),
        ),
      ),
    );
  }

  /// Gets appropriate repeat mode icon
  IconData _getRepeatIcon() {
    switch (widget.repeatMode) {
      case RepeatMode.off:
        return Icons.repeat;
      case RepeatMode.all:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
    }
  }
}

/// Mini player widget for bottom navigation
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.progress,
    this.onTap,
    this.onPlayPause,
    this.onNext,
  });

  final Song song;
  final bool isPlaying;
  final double progress;
  final VoidCallback? onTap;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.darkBorder,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            minHeight: 2,
          ),
          // Player content
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  child: Row(
                    children: [
                      _buildAlbumArt(),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(child: _buildSongInfo()),
                      _buildControls(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds mini album art
  Widget _buildAlbumArt() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        color: AppTheme.darkBorder,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        child: song.albumArt != null
            ? CachedNetworkImage(
                imageUrl: song.albumArt!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  /// Builds placeholder for mini player
  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
      ),
      child: const Icon(
        Icons.music_note,
        color: AppTheme.primaryText,
        size: 16,
      ),
    );
  }

  /// Builds mini song info
  Widget _buildSongInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          song.title,
          style: AppTextStyles.bodyMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          song.artist,
          style: AppTextStyles.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Builds mini player controls
  Widget _buildControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPlayPause,
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppTheme.primaryText,
          ),
          iconSize: 24,
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(
            Icons.skip_next,
            color: AppTheme.secondaryText,
          ),
          iconSize: 20,
        ),
      ],
    );
  }
}

/// Repeat mode enum
enum RepeatMode {
  off,
  all,
  one,
}
