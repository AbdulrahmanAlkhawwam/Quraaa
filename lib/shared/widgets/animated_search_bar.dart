import 'package:flutter/material.dart';

/// A production-quality animated search bar widget that mimics the Noon app's
/// search suggestion animation.
///
/// The widget displays a pill-shaped search bar with a search icon and
/// vertically sliding text suggestions that rotate automatically.
///
/// Features:
/// * Vertical slide + fade transition between suggestions
/// * Optimized for 60fps using [AnimationController] and [AnimatedSwitcher]
/// * Minimal rebuilds via [ValueNotifier] and [ValueListenableBuilder]
/// * Automatic pause/resume on app lifecycle changes
/// * Supports RTL, localization, dark mode, and long text
///
/// Example usage:
/// ```dart
/// AnimatedSearchBar(
///   suggestions: const ['History', 'Mathematics', 'Science', 'Novels'],
///   onTap: () => Navigator.pushNamed(context, '/search'),
/// )
/// ```
class AnimatedSearchBar extends StatefulWidget {
  /// List of suggestion texts to cycle through.
  ///
  /// Must not be empty. Each suggestion should ideally be concise.
  final List<String> suggestions;

  /// Duration between text switches.
  ///
  /// Defaults to 2.8 seconds. Must be greater than or equal to
  /// [animationDuration] to avoid overlapping transitions.
  final Duration switchDuration;

  /// Duration of the slide + fade transition between suggestions.
  ///
  /// Defaults to 350 milliseconds.
  final Duration animationDuration;

  /// Callback invoked when the user taps the search bar.
  final VoidCallback? onTap;

  /// Background color of the search bar.
  ///
  /// Defaults to light grey (#F5F5F5).
  final Color backgroundColor;

  /// Color of the icon and text.
  ///
  /// Defaults to [Colors.black87].
  final Color textColor;

  /// Icon displayed on the leading side of the search bar.
  ///
  /// Defaults to [Icons.search].
  final IconData icon;

  /// Border radius of the search bar.
  ///
  /// Defaults to 999.0 for a pill shape.
  final double borderRadius;

  /// Optional text style for the suggestions.
  ///
  /// If provided, it is merged with the default style. The default style
  /// uses [FontWeight.w600], font size 22, and [TextOverflow.ellipsis].
  final TextStyle? textStyle;

  const AnimatedSearchBar({
    super.key,
    required this.suggestions,
    this.switchDuration = const Duration(milliseconds: 2800),
    this.animationDuration = const Duration(milliseconds: 350),
    this.onTap,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.textColor = Colors.black87,
    this.icon = Icons.search,
    this.borderRadius = 999.0,
    this.textStyle,
  }) /*: assert(suggestions.isNotEmpty, 'suggestions must not be empty')*/;

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final ValueNotifier<int> _indexNotifier;
  late final ValueNotifier<bool> _pressedNotifier;
  AnimationController? _intervalController;

  bool _isAppActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _indexNotifier = ValueNotifier<int>(0);
    _pressedNotifier = ValueNotifier<bool>(false);
    _initIntervalController();
  }

  void _initIntervalController() {
    if (widget.suggestions.length <= 1) return;

    _intervalController = AnimationController(
      vsync: this,
      duration: widget.switchDuration,
    );
    _intervalController!.addStatusListener(_onIntervalStatusChanged);
    if (_isAppActive) {
      _intervalController!.forward();
    }
  }

  void _onIntervalStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _indexNotifier.value =
          (_indexNotifier.value + 1) % widget.suggestions.length;
      _intervalController?.forward(from: 0);
    }
  }

  void _pauseAnimation() {
    if (_intervalController?.isAnimating ?? false) {
      _intervalController?.stop();
    }
  }

  void _resumeAnimation() {
    if ((_intervalController?.isAnimating == false) &&
        _isAppActive &&
        mounted &&
        widget.suggestions.length > 1) {
      _intervalController?.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        _isAppActive = false;
        _pauseAnimation();
        break;
      case AppLifecycleState.resumed:
        _isAppActive = true;
        _resumeAnimation();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void didUpdateWidget(AnimatedSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.switchDuration != widget.switchDuration) {
      _intervalController?.duration = widget.switchDuration;
    }

    if (oldWidget.suggestions.length != widget.suggestions.length) {
      if (_indexNotifier.value >= widget.suggestions.length) {
        _indexNotifier.value = 0;
      }

      if (widget.suggestions.length > 1) {
        _intervalController ??= AnimationController(
          vsync: this,
          duration: widget.switchDuration,
        )..addStatusListener(_onIntervalStatusChanged);
        _resumeAnimation();
      } else {
        _intervalController?.stop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intervalController?.dispose();
    _indexNotifier.dispose();
    _pressedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = TextStyle(
      color: widget.textColor,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      overflow: TextOverflow.ellipsis,
    );

    final effectiveTextStyle = widget.textStyle != null
        ? defaultTextStyle.merge(widget.textStyle)
        : defaultTextStyle;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _pressedNotifier.value = true,
      onTapUp: (_) => _pressedNotifier.value = false,
      onTapCancel: () => _pressedNotifier.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _pressedNotifier,
        builder: (context, isPressed, child) {
          return AnimatedScale(
            scale: isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeInOut,
            child: child!,
          );
        },
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10), // ~0.04 opacity
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 22,
                color: widget.textColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRect(
                  child: ValueListenableBuilder<int>(
                    valueListenable: _indexNotifier,
                    builder: (context, currentIndex, _) {
                      return AnimatedSwitcher(
                        duration: widget.animationDuration,
                        transitionBuilder: _buildTransition,
                        child: Text(
                          widget.suggestions[currentIndex],
                          key: ValueKey<int>(currentIndex),
                          style: effectiveTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the combined slide + fade transition for [AnimatedSwitcher].
  ///
  /// The outgoing text slides upward and fades out, while the incoming text
  /// slides from below and fades in. Both animations happen simultaneously
  /// with [Curves.easeInOutCubic].
  Widget _buildTransition(Widget child, Animation<double> animation) {
    final int childIndex = (child.key as ValueKey<int>).value;
    final bool isIncoming = childIndex == _indexNotifier.value;

    final slideAnimation = Tween<Offset>(
      begin: isIncoming ? const Offset(0, 1.0) : Offset.zero,
      end: isIncoming ? Offset.zero : const Offset(0, -1.0),
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      ),
    );

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}
