import 'package:flutter/material.dart';

/// Custom animation utilities for enhanced UI interactions
/// Provides reusable animations for consistent app experience
class AppAnimations {
  AppAnimations._();

  // Animation durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Animation curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  /// Slide transition from bottom
  static SlideTransition slideFromBottom({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: fastOutSlowIn,
      )),
      child: child,
    );
  }

  /// Slide transition from right
  static SlideTransition slideFromRight({
    required Animation<double> animation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: fastOutSlowIn,
      )),
      child: child,
    );
  }

  /// Fade transition
  static FadeTransition fade({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Scale transition
  static ScaleTransition scale({
    required Animation<double> animation,
    required Widget child,
    double? begin,
    double? end,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: begin ?? 0.0,
        end: end ?? 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: elasticOut,
      )),
      child: child,
    );
  }

  /// Rotation transition
  static RotationTransition rotation({
    required Animation<double> animation,
    required Widget child,
  }) {
    return RotationTransition(
      turns: animation,
      child: child,
    );
  }

  /// Combined fade and scale transition
  static Widget fadeScale({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: easeInOut,
        )),
        child: child,
      ),
    );
  }

  /// Staggered list animation
  static Widget staggeredListItem({
    required int index,
    required Animation<double> animation,
    required Widget child,
    Duration delay = const Duration(milliseconds: 100),
    Duration totalDuration = const Duration(milliseconds: 500),
  }) {
    final itemDelay = delay.inMilliseconds * index;
    final start = itemDelay / totalDuration.inMilliseconds;
    
    if (start >= 1.0) return child;
    
    final itemAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Interval(start.clamp(0.0, 1.0), 1.0, curve: easeInOut),
    ));

    return slideFromBottom(
      animation: itemAnimation,
      child: fade(
        animation: itemAnimation,
        child: child,
      ),
    );
  }

  /// Bounce animation for buttons
  static Widget bouncyButton({
    required Widget child,
    required VoidCallback onTap,
    double scaleDown = 0.95,
  }) {
    return _BouncyButton(
      onTap: onTap,
      scaleDown: scaleDown,
      child: child,
    );
  }

  /// Shimmer loading animation
  static Widget shimmer({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return _ShimmerWidget(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: child,
    );
  }

  /// Page transition builder for route animations
  static PageTransitionsBuilder get pageTransitionBuilder {
    return const _CustomPageTransitionsBuilder();
  }

  /// Custom route transition
  static Route<T> createRoute<T>({
    required Widget page,
    Duration duration = medium,
    RouteTransitionsBuilder? transitionsBuilder,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => page,
      transitionDuration: duration,
      transitionsBuilder: transitionsBuilder ?? _defaultTransitionBuilder,
    );
  }

  static Widget _defaultTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return slideFromRight(animation: animation, child: child);
  }
}

/// Bouncy button implementation
class _BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleDown;

  const _BouncyButton({
    required this.child,
    required this.onTap,
    this.scaleDown = 0.95,
  });

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Shimmer loading animation implementation
class _ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const _ShimmerWidget({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Custom page transitions builder
class _CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  const _CustomPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AppAnimations.slideFromRight(
      animation: animation,
      child: child,
    );
  }
}

/// Pre-built animation widgets for common use cases
class AnimatedWidgets {
  AnimatedWidgets._();

  /// Animated counter
  static Widget counter({
    required int value,
    Duration duration = AppAnimations.medium,
    TextStyle? style,
  }) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: style,
        );
      },
    );
  }

  /// Animated progress bar
  static Widget progressBar({
    required double progress,
    Duration duration = AppAnimations.medium,
    Color? color,
    Color? backgroundColor,
    double height = 4.0,
    BorderRadius? borderRadius,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
      duration: duration,
      builder: (context, value, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[300],
            borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: color ?? Theme.of(context).primaryColor,
                borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Animated list view
  static Widget listView({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
  }) {
    return _AnimatedListView(
      children: children,
      staggerDelay: staggerDelay,
      controller: controller,
      padding: padding,
    );
  }
}

/// Animated list view implementation
class _AnimatedListView extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const _AnimatedListView({
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.controller,
    this.padding,
  });

  @override
  State<_AnimatedListView> createState() => _AnimatedListViewState();
}

class _AnimatedListViewState extends State<_AnimatedListView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        milliseconds: 500 + (widget.children.length * widget.staggerDelay.inMilliseconds),
      ),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      padding: widget.padding,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AppAnimations.staggeredListItem(
          index: index,
          animation: _controller,
          delay: widget.staggerDelay,
          totalDuration: _controller.duration!,
          child: widget.children[index],
        );
      },
    );
  }
}
