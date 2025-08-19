import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/library_screen.dart';
import '../screens/artist_profile_screen.dart';
import '../screens/now_playing_screen.dart';
import '../screens/playlist_detail_screen.dart';
import '../widgets/layout_widgets.dart';
import '../../core/themes/app_colors.dart';

/// App navigation router using GoRouter for declarative routing
/// Provides type-safe navigation with animation support
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  /// Main router configuration
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      // Main app shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home tab
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          
          // Search tab
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          
          // Library tab
          GoRoute(
            path: '/library',
            name: 'library',
            builder: (context, state) => const LibraryScreen(),
          ),
        ],
      ),
      
      // Full screen routes (outside main shell)
      GoRoute(
        path: '/artist/:artistId',
        name: 'artist',
        builder: (context, state) {
          final artistId = state.pathParameters['artistId']!;
          return ArtistProfileScreen(artistId: artistId);
        },
      ),
      
      GoRoute(
        path: '/playlist/:playlistId',
        name: 'playlist',
        builder: (context, state) {
          final playlistId = state.pathParameters['playlistId']!;
          return PlaylistDetailScreen(playlistId: playlistId);
        },
      ),
      
      GoRoute(
        path: '/now-playing',
        name: 'nowPlaying',
        builder: (context, state) => const NowPlayingScreen(),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => ErrorScreen(
      title: 'Page Not Found',
      message: 'The page you are looking for does not exist.',
      onRetry: () => context.go('/home'),
    ),
  );
}

/// Main app shell with bottom navigation and mini player
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});
  
  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Column(
        children: [
          Expanded(child: widget.child),
          // Mini player placeholder - will be implemented later
          // const MiniPlayerBar(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  /// Builds custom bottom navigation bar
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        border: Border(
          top: BorderSide(
            color: AppTheme.darkBorder,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                index: 0,
                route: '/home',
              ),
              _buildNavItem(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
                label: 'Search',
                index: 1,
                route: '/search',
              ),
              _buildNavItem(
                icon: Icons.library_music_outlined,
                selectedIcon: Icons.library_music,
                label: 'Library',
                index: 2,
                route: '/library',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds individual navigation item
  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required String route,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        context.go(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? AppTheme.primaryPurple : AppTheme.tertiaryText,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryPurple : AppTheme.tertiaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
