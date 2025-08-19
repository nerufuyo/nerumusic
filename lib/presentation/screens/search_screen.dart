import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/song.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/song_card.dart';
import '../widgets/search_widgets.dart';
import '../controllers/search_controller.dart';

/// Search screen for discovering music content
/// Provides comprehensive search functionality with filters
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios),
          color: AppTheme.primaryText,
        ),
        title: Text(
          'Search',
          style: AppTextStyles.h3,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _buildSearchContent(searchState),
          ),
        ],
      ),
    );
  }

  /// Builds search input bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: CustomSearchBar(
        controller: _searchController,
        autofocus: true,
        hintText: 'Search songs, artists, albums, playlists...',
        onChanged: (query) {
          ref.read(searchControllerProvider.notifier).search(query);
        },
        onClearTap: () {
          ref.read(searchControllerProvider.notifier).clearSearch();
        },
      ),
    );
  }

  /// Builds filter chips for search categories
  Widget _buildFilterChips() {
    final filters = ['All', 'Songs', 'Artists', 'Albums', 'Playlists'];
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppConstants.smallPadding),
            child: SearchFilterChip(
              label: filter,
              isSelected: _selectedFilter == filter,
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
          );
        },
      ),
    );
  }

  /// Builds search content based on state
  Widget _buildSearchContent(SearchState searchState) {
    if (searchState.query.isEmpty) {
      return _buildEmptySearchState();
    }

    if (searchState.isLoading) {
      return _buildLoadingState();
    }

    if (searchState.error != null) {
      return _buildErrorState(searchState.error!);
    }

    final hasResults = searchState.results.isNotEmpty;

    if (!hasResults) {
      return NoSearchResults(query: searchState.query);
    }

    return _buildSearchResults(searchState);
  }

  /// Builds empty search state
  Widget _buildEmptySearchState() {
    return Column(
      children: [
        const Expanded(
          child: EmptySearchState(),
        ),
        _buildRecentSearches(),
        _buildTrendingSearches(),
      ],
    );
  }

  /// Builds loading state
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
      ),
    );
  }

  /// Builds error state
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.tertiaryText,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Search Error',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton(
              onPressed: () {
                ref.read(searchControllerProvider.notifier)
                    .search(_searchController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: AppTheme.primaryText,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds search results
  Widget _buildSearchResults(SearchState searchState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_shouldShowSongs(searchState)) _buildSongsSection(searchState),
        ],
      ),
    );
  }

  /// Checks if songs should be shown based on filter
  bool _shouldShowSongs(SearchState searchState) {
    return (_selectedFilter == 'All' || _selectedFilter == 'Songs') &&
        searchState.results.isNotEmpty;
  }

  /// Builds songs section
  Widget _buildSongsSection(SearchState searchState) {
    return Column(
      children: [
        SectionHeader(
          title: 'Songs',
          subtitle: '${searchState.results.length} results',
          action: searchState.results.length > 5
              ? TextButton(
                  onPressed: () => _viewAllSongs(searchState.results),
                  child: Text(
                    'View All',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
        ...searchState.results.take(5).map(
              (song) => SongCard(
                song: song,
                onTap: () => _playSong(song),
                onMoreTap: () => _showSongOptions(song),
              ),
            ),
      ],
    );
  }

  // Action methods

  /// Builds recent searches section
  Widget _buildRecentSearches() {
    return Column(
      children: [
        SectionHeader(
          title: 'Recent Searches',
          action: TextButton(
            onPressed: () => _clearRecentSearches(),
            child: Text(
              'Clear',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.tertiaryText,
              ),
            ),
          ),
        ),
        // TODO: Replace with actual recent searches
        ...List.generate(
          3,
          (index) => SearchSuggestionTile(
            title: 'Recent search ${index + 1}',
            subtitle: 'Song • Artist',
            leadingIcon: Icons.history,
            onTap: () => _selectRecentSearch('Recent search ${index + 1}'),
          ),
        ),
      ],
    );
  }

  /// Builds trending searches section
  Widget _buildTrendingSearches() {
    return Column(
      children: [
        SectionHeader(
          title: 'Trending Searches',
        ),
        // TODO: Replace with actual trending searches
        ...List.generate(
          3,
          (index) => SearchSuggestionTile(
            title: 'Trending song ${index + 1}',
            subtitle: 'Popular Artist',
            leadingIcon: Icons.trending_up,
            onTap: () => _selectTrendingSearch('Trending song ${index + 1}'),
            trailing: Icon(
              Icons.whatshot,
              color: AppTheme.primaryPurple,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Action methods
  void _playSong(Song song) {
    // TODO: Implement song playback
    debugPrint('Playing song: ${song.title}');
  }

  void _showSongOptions(Song song) {
    // TODO: Implement song options bottom sheet
    debugPrint('Show options for song: ${song.title}');
  }

  void _viewAllSongs(List<Song> songs) {
    // TODO: Implement view all songs screen
    debugPrint('View all ${songs.length} songs');
  }

  void _clearRecentSearches() {
    // TODO: Implement clear recent searches
    ref.read(searchControllerProvider.notifier).clearSearchHistory();
  }

  void _selectRecentSearch(String query) {
    _searchController.text = query;
    ref.read(searchControllerProvider.notifier).search(query);
  }

  void _selectTrendingSearch(String query) {
    _searchController.text = query;
    ref.read(searchControllerProvider.notifier).search(query);
  }
}
