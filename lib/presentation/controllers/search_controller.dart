import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/song.dart';
import '../../domain/usecases/search_songs.dart';
import '../../core/utils/injection.dart';

/// Search state representing current search status and results
/// Manages search results, loading states, and search history
class SearchState {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.recentSearches = const [],
    this.isLoading = false,
    this.hasSearched = false,
    this.error,
  });

  final String query;
  final List<Song> results;
  final List<String> recentSearches;
  final bool isLoading;
  final bool hasSearched;
  final String? error;

  /// Creates a copy with updated properties
  SearchState copyWith({
    String? query,
    List<Song>? results,
    List<String>? recentSearches,
    bool? isLoading,
    bool? hasSearched,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
      error: error ?? this.error,
    );
  }

  /// Whether search has results
  bool get hasResults => results.isNotEmpty;

  /// Whether search returned no results
  bool get hasNoResults => hasSearched && !isLoading && results.isEmpty;
}

/// Search controller handling search operations and state
/// Implements debounced search with result caching
class SearchController extends StateNotifier<SearchState> {
  final SearchSongs _searchSongs;
  
  SearchController() : 
    _searchSongs = getIt<SearchSongs>(),
    super(const SearchState()) {
    _loadRecentSearches();
  }

  /// Loads recent searches from local storage
  Future<void> _loadRecentSearches() async {
    try {
      // TODO: Load from Hive storage
      // For now, use empty list
      state = state.copyWith(recentSearches: []);
    } catch (e) {
      // Silently fail for recent searches
    }
  }

  /// Performs search with the given query
  Future<void> search(String query) async {
    final trimmedQuery = query.trim();
    
    // Clear results if query is empty
    if (trimmedQuery.isEmpty) {
      state = state.copyWith(
        query: '',
        results: [],
        hasSearched: false,
        error: null,
      );
      return;
    }

    // Skip if same query is already being searched
    if (state.isLoading && state.query == trimmedQuery) {
      return;
    }

    state = state.copyWith(
      query: trimmedQuery,
      isLoading: true,
      error: null,
    );

    // Perform search using use case
    final params = SearchSongsParams(query: trimmedQuery, limit: 20);
    final result = await _searchSongs(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          hasSearched: true,
          error: failure.message,
        );
      },
      (songs) {
        state = state.copyWith(
          results: songs,
          isLoading: false,
          hasSearched: true,
          error: null,
        );
        
        // Add to recent searches
        _addToRecentSearches(trimmedQuery);
      },
    );
  }

  /// Clears current search results
  void clearSearch() {
    state = state.copyWith(
      query: '',
      results: [],
      hasSearched: false,
      error: null,
    );
  }

  /// Clears search history
  void clearSearchHistory() {
    state = state.copyWith(recentSearches: []);
    // TODO: Clear from Hive storage
  }

  /// Removes a specific search from history
  void removeFromHistory(String query) {
    final updatedHistory = state.recentSearches
        .where((search) => search != query)
        .toList();
    
    state = state.copyWith(recentSearches: updatedHistory);
    // TODO: Save to Hive storage
  }

  /// Adds query to recent searches
  void _addToRecentSearches(String query) {
    final updatedHistory = [query];
    
    // Add existing searches (excluding duplicates)
    for (final search in state.recentSearches) {
      if (search != query && updatedHistory.length < 20) {
        updatedHistory.add(search);
      }
    }
    
    state = state.copyWith(recentSearches: updatedHistory);
    // TODO: Save to Hive storage
  }

  /// Performs search with a recent query
  void searchWithRecentQuery(String query) {
    search(query);
  }
}

/// Provider for search controller
final searchControllerProvider = StateNotifierProvider<SearchController, SearchState>(
  (ref) => SearchController(),
);
