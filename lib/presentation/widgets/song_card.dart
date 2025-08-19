import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../../domain/entities/song.dart';

/// Reusable song card component following 80% reusability target
/// Displays song information with consistent styling across the app
class SongCard extends StatelessWidget {
  const SongCard({
    super.key,
    required this.song,
    this.onTap,
    this.onMoreTap,
    this.showAlbum = true,
    this.showDuration = true,
    this.isPlaying = false,
  });

  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool showAlbum;
  final bool showDuration;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding / 2,
      ),
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
                _buildAlbumArt(),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(child: _buildSongInfo()),
                if (showDuration) _buildDuration(),
                _buildMoreButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds album artwork with placeholder
  Widget _buildAlbumArt() {
    return Container(
      width: 56,
      height: 56,
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

  /// Builds placeholder for missing album art
  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
      ),
      child: const Icon(
        Icons.music_note,
        color: AppTheme.primaryText,
        size: 24,
      ),
    );
  }

  /// Builds song information section
  Widget _buildSongInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                song.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isPlaying ? AppTheme.primaryPurple : AppTheme.primaryText,
                  fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isPlaying) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.play_arrow,
                color: AppTheme.primaryPurple,
                size: 16,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          song.artist,
          style: AppTextStyles.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (showAlbum && song.album != null) ...[
          const SizedBox(height: 2),
          Text(
            song.album!,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// Builds duration display
  Widget _buildDuration() {
    return Text(
      TimeUtils.formatDuration(song.duration),
      style: AppTextStyles.caption.copyWith(
        color: AppTheme.tertiaryText,
      ),
    );
  }

  /// Builds more options button
  Widget _buildMoreButton() {
    return IconButton(
      onPressed: onMoreTap,
      icon: const Icon(Icons.more_vert),
      color: AppTheme.tertiaryText,
      iconSize: 20,
    );
  }
}

/// Compact song tile for lists with minimal space
class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.isPlaying = false,
    this.showIndex = false,
    this.index,
  });

  final Song song;
  final VoidCallback? onTap;
  final bool isPlaying;
  final bool showIndex;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: showIndex 
          ? _buildIndexOrPlayingIcon() 
          : _buildSmallAlbumArt(),
      title: Text(
        song.title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isPlaying ? AppTheme.primaryPurple : AppTheme.primaryText,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: AppTextStyles.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        TimeUtils.formatDuration(song.duration),
        style: AppTextStyles.caption.copyWith(
          color: AppTheme.tertiaryText,
        ),
      ),
      tileColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 4,
      ),
    );
  }

  /// Builds index number or playing icon
  Widget _buildIndexOrPlayingIcon() {
    if (isPlaying) {
      return Icon(
        Icons.play_arrow,
        color: AppTheme.primaryPurple,
        size: 24,
      );
    }
    
    return SizedBox(
      width: 24,
      child: Text(
        '${(index ?? 0) + 1}',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppTheme.tertiaryText,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds small album art for tile
  Widget _buildSmallAlbumArt() {
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
                placeholder: (context, url) => _buildSmallPlaceholder(),
                errorWidget: (context, url, error) => _buildSmallPlaceholder(),
              )
            : _buildSmallPlaceholder(),
      ),
    );
  }

  /// Builds small placeholder for tile
  Widget _buildSmallPlaceholder() {
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
}
