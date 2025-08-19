import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/playlist.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/song_card.dart';
import '../widgets/playlist_card.dart';

/// Artist profile screen displaying artist information and music
/// Features artist bio, popular songs, albums, and playlists
class ArtistProfileScreen extends ConsumerStatefulWidget {
  const ArtistProfileScreen({
    super.key,
    required this.artistId,
  });

  final String artistId;

  @override
  ConsumerState<ArtistProfileScreen> createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends ConsumerState<ArtistProfileScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  bool _isHeaderExpanded = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isExpanded = _scrollController.offset < 200;
    if (isExpanded != _isHeaderExpanded) {
      setState(() {
        _isHeaderExpanded = isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Get artist data from state management
    final artist = _getDummyArtist();
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(artist),
          _buildArtistInfo(artist),
          _buildActionButtons(),
          _buildTabBar(),
          _buildTabContent(),
        ],
      ),
    );
  }

  /// Builds sliver app bar with artist image
  Widget _buildSliverAppBar(Artist artist) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.primaryText,
            size: 16,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _shareArtist(artist),
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.share,
              color: AppTheme.primaryText,
              size: 16,
            ),
          ),
        ),
        IconButton(
          onPressed: () => _showMoreOptions(artist),
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.more_vert,
              color: AppTheme.primaryText,
              size: 16,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Artist image
            artist.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: artist.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildImagePlaceholder(),
                    errorWidget: (context, url, error) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.darkBackground.withValues(alpha: 0.8),
                    AppTheme.darkBackground,
                  ],
                  stops: const [0.3, 0.8, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds image placeholder
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          color: AppTheme.primaryText,
          size: 80,
        ),
      ),
    );
  }

  /// Builds artist information section
  Widget _buildArtistInfo(Artist artist) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              artist.name,
              style: AppTextStyles.h1,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              '${artist.followers ?? 0} followers',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
              ),
            ),
            if (artist.biography != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                artist.biography!,
                style: AppTextStyles.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds action buttons section
  Widget _buildActionButtons() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _shufflePlay(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: AppTheme.primaryText,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.defaultPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                  ),
                ),
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle'),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryPurple,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
              ),
              child: IconButton(
                onPressed: () => _toggleFollow(),
                icon: Icon(
                  _isFollowing() ? Icons.favorite : Icons.favorite_outline,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds tab bar
  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryPurple,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: AppTheme.tertiaryText,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.bodyMedium,
          tabs: const [
            Tab(text: 'Popular'),
            Tab(text: 'Albums'),
            Tab(text: 'Playlists'),
          ],
        ),
      ),
    );
  }

  /// Builds tab content
  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPopularTab(),
          _buildAlbumsTab(),
          _buildPlaylistsTab(),
        ],
      ),
    );
  }

  /// Builds popular songs tab
  Widget _buildPopularTab() {
    final popularSongs = _getPopularSongs();
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: popularSongs.length,
      itemBuilder: (context, index) {
        final song = popularSongs[index];
        return SongTile(
          song: song,
          showIndex: true,
          index: index,
          onTap: () => _playSong(song, index),
        );
      },
    );
  }

  /// Builds albums tab
  Widget _buildAlbumsTab() {
    final albums = _getAlbums();
    
    if (albums.isEmpty) {
      return const EmptyState(
        icon: Icons.album,
        title: 'No Albums',
        message: 'This artist has no albums available',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppConstants.defaultPadding,
        mainAxisSpacing: AppConstants.defaultPadding,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return PlaylistCard(
          playlist: album,
          size: PlaylistCardSize.medium,
          onTap: () => _openAlbum(album),
        );
      },
    );
  }

  /// Builds playlists tab
  Widget _buildPlaylistsTab() {
    final playlists = _getArtistPlaylists();
    
    if (playlists.isEmpty) {
      return const EmptyState(
        icon: Icons.library_music,
        title: 'No Playlists',
        message: 'This artist has no playlists available',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return PlaylistTile(
          playlist: playlist,
          onTap: () => _openPlaylist(playlist),
        );
      },
    );
  }

  // Data methods (placeholder implementations)
  Artist _getDummyArtist() {
    return Artist(
      id: widget.artistId,
      name: 'Amazing Artist',
      imageUrl: null,
      biography: 'A talented artist creating beautiful music for everyone to enjoy.',
      followers: 1234567,
      genres: ['Pop', 'Rock', 'Electronic'],
    );
  }

  List<Song> _getPopularSongs() {
    // TODO: Get popular songs from API
    return List.generate(
      10,
      (index) => Song(
        id: 'song_$index',
        title: 'Popular Song ${index + 1}',
        artist: 'Amazing Artist',
        duration: 180000 + (index * 30000),
        popularity: 90 - (index * 5),
      ),
    );
  }

  List<Playlist> _getAlbums() {
    // TODO: Get albums from API
    return List.generate(
      6,
      (index) => Playlist(
        id: 'album_$index',
        name: 'Album ${index + 1}',
        songs: [],
        description: 'A great album by Amazing Artist',
        creator: 'Amazing Artist',
      ),
    );
  }

  List<Playlist> _getArtistPlaylists() {
    // TODO: Get artist playlists from API
    return List.generate(
      4,
      (index) => Playlist(
        id: 'playlist_$index',
        name: 'Artist Playlist ${index + 1}',
        songs: [],
        description: 'Curated by Amazing Artist',
        creator: 'Amazing Artist',
      ),
    );
  }

  bool _isFollowing() {
    // TODO: Check if user is following this artist
    return false;
  }

  // Action methods
  void _shareArtist(Artist artist) {
    // TODO: Implement share functionality
    debugPrint('Share artist: ${artist.name}');
  }

  void _showMoreOptions(Artist artist) {
    // TODO: Show more options bottom sheet
    debugPrint('Show more options for artist: ${artist.name}');
  }

  void _shufflePlay() {
    // TODO: Shuffle play artist's popular songs
    debugPrint('Shuffle play artist songs');
  }

  void _toggleFollow() {
    // TODO: Toggle follow status
    debugPrint('Toggle follow artist');
  }

  void _playSong(Song song, int index) {
    // TODO: Play song
    debugPrint('Play song: ${song.title} at index $index');
  }

  void _openAlbum(Playlist album) {
    // TODO: Navigate to album detail
    debugPrint('Open album: ${album.name}');
  }

  void _openPlaylist(Playlist playlist) {
    // TODO: Navigate to playlist detail
    debugPrint('Open playlist: ${playlist.name}');
  }
}

/// Custom delegate for sticky tab bar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.darkBackground,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
