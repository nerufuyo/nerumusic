import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// Custom search bar component with Neru Music styling
/// Provides consistent search interface across the app
class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.onClearTap,
    this.hintText = 'Search songs, artists, albums...',
    this.controller,
    this.autofocus = false,
  });

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClearTap;
  final String hintText;
  final TextEditingController? controller;
  final bool autofocus;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _controller.addListener(_onTextChanged);
    _showClearButton = _controller.text.isNotEmpty;
    if (_showClearButton) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClearButton) {
      setState(() {
        _showClearButton = hasText;
      });
      if (hasText) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onClearTap() {
    _controller.clear();
    widget.onClearTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(
          color: AppTheme.darkBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Icon(
              Icons.search,
              color: AppTheme.tertiaryText,
              size: 20,
            ),
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.tertiaryText,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: widget.onSubmitted,
            ),
          ),
          // Clear button
          FadeTransition(
            opacity: _fadeAnimation,
            child: _showClearButton
                ? IconButton(
                    onPressed: _onClearTap,
                    icon: const Icon(Icons.clear),
                    color: AppTheme.tertiaryText,
                    iconSize: 18,
                  )
                : const SizedBox(width: 48),
          ),
        ],
      ),
    );
  }
}

/// Search suggestion tile for displaying search results
class SearchSuggestionTile extends StatelessWidget {
  const SearchSuggestionTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingIcon,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: leadingIcon != null
          ? Icon(
              leadingIcon,
              color: AppTheme.tertiaryText,
              size: 20,
            )
          : null,
      title: Text(
        title,
        style: AppTextStyles.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 4,
      ),
      tileColor: Colors.transparent,
    );
  }
}

/// Search category filter chips
class SearchFilterChip extends StatelessWidget {
  const SearchFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : AppTheme.darkCard,
          borderRadius: BorderRadius.circular(AppTheme.largeRadius),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : AppTheme.darkBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppTheme.primaryText : AppTheme.secondaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Empty search state widget
class EmptySearchState extends StatelessWidget {
  const EmptySearchState({
    super.key,
    this.title = 'Start searching',
    this.subtitle = 'Find your favorite songs, artists, and playlists',
    this.icon = Icons.search,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryText,
              size: 40,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            title,
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// No search results widget
class NoSearchResults extends StatelessWidget {
  const NoSearchResults({
    super.key,
    required this.query,
  });

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppTheme.darkBorder,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.search_off,
              color: AppTheme.tertiaryText,
              size: 40,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'No results found',
            style: AppTextStyles.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Try searching for "$query" with different keywords',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppTheme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
