import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/playlist.dart';

/// Reusable playlist card component for displaying playlists
/// Follows app design system and reusability standards
class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.playlist,
    this.onTap,
    this.onMoreTap,
    this.showSongCount = true,
    this.size = PlaylistCardSize.medium,
  });

  final Playlist playlist;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool showSongCount;
  final PlaylistCardSize size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _getCardWidth(),
      margin: const EdgeInsets.all(AppConstants.smallPadding),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlaylistImage(),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildPlaylistInfo(),
                if (onMoreTap != null) _buildMoreButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gets card width based on size
  double _getCardWidth() {
    switch (size) {
      case PlaylistCardSize.small:
        return 140;
      case PlaylistCardSize.medium:
        return 180;
      case PlaylistCardSize.large:
        return 220;
    }
  }

  /// Builds playlist image with gradient overlay
  Widget _buildPlaylistImage() {
    final imageSize = _getCardWidth() - (AppConstants.defaultPadding * 2);
    
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        color: AppTheme.darkBorder,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        child: Stack(
          children: [
            playlist.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: playlist.imageUrl!,
                    fit: BoxFit.cover,
                    width: imageSize,
                    height: imageSize,
                    placeholder: (context, url) => _buildPlaceholder(imageSize),
                    errorWidget: (context, url, error) => _buildPlaceholder(imageSize),
                  )
                : _buildPlaceholder(imageSize),
            // Gradient overlay for better text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: imageSize * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Play button overlay
            Positioned(
              bottom: AppConstants.smallPadding,
              right: AppConstants.smallPadding,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.play_arrow,
                  color: AppTheme.primaryText,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds placeholder for missing playlist image
  Widget _buildPlaceholder(double imageSize) {
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
      ),
      child: const Icon(
        Icons.library_music,
        color: AppTheme.primaryText,
        size: 48,
      ),
    );
  }

  /// Builds playlist information section
  Widget _buildPlaylistInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          playlist.name,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (playlist.description != null) ...[
          const SizedBox(height: 4),
          Text(
            playlist.description!,
            style: AppTextStyles.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (showSongCount) ...[
          const SizedBox(height: 4),
          Text(
            '${playlist.songCount} songs',
            style: AppTextStyles.caption.copyWith(
              color: AppTheme.tertiaryText,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds more options button
  Widget _buildMoreButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: onMoreTap,
        icon: const Icon(Icons.more_vert),
        color: AppTheme.tertiaryText,
        iconSize: 18,
      ),
    );
  }
}

/// Horizontal playlist tile for lists
class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.playlist,
    this.onTap,
    this.onMoreTap,
    this.showDescription = true,
  });

  final Playlist playlist;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool showDescription;

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
                _buildPlaylistImage(),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(child: _buildPlaylistInfo()),
                _buildMoreButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds playlist image for tile
  Widget _buildPlaylistImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        color: AppTheme.darkBorder,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
        child: playlist.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: playlist.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  /// Builds placeholder for tile image
  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
      ),
      child: const Icon(
        Icons.library_music,
        color: AppTheme.primaryText,
        size: 24,
      ),
    );
  }

  /// Builds playlist information for tile
  Widget _buildPlaylistInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          playlist.name,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (showDescription && playlist.description != null)
          Text(
            playlist.description!,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        else
          Text(
            '${playlist.songCount} songs',
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// Builds more options button for tile
  Widget _buildMoreButton() {
    return IconButton(
      onPressed: onMoreTap,
      icon: const Icon(Icons.more_vert),
      color: AppTheme.tertiaryText,
      iconSize: 20,
    );
  }
}

/// Playlist card size variants
enum PlaylistCardSize {
  small,
  medium,
  large,
}
