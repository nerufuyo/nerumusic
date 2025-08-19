import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// Base screen layout for consistent app structure
/// Provides navigation, header, and content areas
abstract class BaseScreen extends StatelessWidget {
  const BaseScreen({
    super.key,
    this.showBackButton = false,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.padding,
    this.safeArea = true,
  });

  final bool showBackButton;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;

  /// Build the main content of the screen
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    Widget content = buildContent(context);

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppTheme.darkBackground,
      appBar: _buildAppBar(context),
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  /// Builds app bar if title or actions are provided
  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (title == null && actions == null && !showBackButton) {
      return null;
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios),
              color: AppTheme.primaryText,
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: AppTextStyles.h3,
            )
          : null,
      actions: actions,
      centerTitle: true,
    );
  }
}

/// Loading screen template with consistent styling
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    this.message = 'Loading...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryText),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            Text(
              message,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen template with retry functionality
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
    required this.message,
    this.onRetry,
    this.title = 'Something went wrong',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
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
                  Icons.error_outline,
                  color: AppTheme.tertiaryText,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppConstants.largePadding),
              Text(
                title,
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppConstants.largePadding),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: AppTheme.primaryText,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.largePadding,
                      vertical: AppConstants.defaultPadding,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: AppTextStyles.buttonMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header widget for organizing content
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? 
          const EdgeInsets.fromLTRB(
            AppConstants.defaultPadding,
            AppConstants.largePadding,
            AppConstants.defaultPadding,
            AppConstants.defaultPadding,
          ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h3,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Empty state widget for lists and content areas
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
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
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppConstants.largePadding),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: AppTheme.primaryText,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.largePadding,
                    vertical: AppConstants.defaultPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.buttonMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrollable list container
class HorizontalList extends StatelessWidget {
  const HorizontalList({
    super.key,
    required this.children,
    this.height,
    this.padding,
  });

  final List<Widget> children;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: padding ?? 
            const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

/// Grid container for displaying items in grid layout
class GridContainer extends StatelessWidget {
  const GridContainer({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.padding,
  });

  final List<Widget> children;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? 
          const EdgeInsets.all(AppConstants.defaultPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}
