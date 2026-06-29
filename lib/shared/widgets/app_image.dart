// ignore_for_file: unnecessary_underscores
// The image error/frame callbacks receive multiple positional parameters that
// are intentionally unused; multi-underscore names are the standard way to
// express this in Dart when a single `_` is not enough.

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/utils/image_helper.dart';

/// A unified image widget that handles assets, network URLs, local files and
/// inline SVG strings.
///
/// The widget uses [ImageHelper] to detect the image source from [url]:
/// - Paths starting with `assets` are loaded with [Image.asset] / [SvgPicture.asset].
/// - Paths starting with `http` are loaded with [Image.network] / [SvgPicture.network].
/// - Inline SVG strings (starting with `<svg` or `<?xml`) are loaded with
///   [SvgPicture.string].
/// - Local file paths are loaded with [Image.file] / [SvgPicture.file] when
///   [isFile] is `true`.
class AppImage extends StatefulWidget {
  final String? url;
  final double? width;
  final double? height;
  final Alignment? alignment;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? placeholder;
  final double? placeholderHeight;
  final double? placeholderWidth;
  final Color? color;

  /// Treat [url] as a local file path instead of an asset or network URL.
  final bool isFile;

  const AppImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.alignment,
    this.fit,
    this.errorWidget,
    this.placeholder,
    this.placeholderHeight,
    this.placeholderWidth,
    this.color,
    this.isFile = false,
  });

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage>
    with SingleTickerProviderStateMixin {
  late final Animation<double> animation;
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );
    controller.repeat(min: 0.5, max: 0.8, reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null) {
      return widget.errorWidget ?? placeholder();
    }

    final String url = widget.url!.trim();
    final bool isSvg = ImageHelper.isSvg(url);

    switch (ImageHelper.detectSource(url, isFile: widget.isFile)) {
      case ImageSource.inlineSvg:
        return SvgPicture.string(
          url,
          width: widget.width,
          height: widget.height,
          alignment: widget.alignment ?? Alignment.center,
          fit: widget.fit ?? BoxFit.contain,
          placeholderBuilder: (_) => placeholder(withAnimation: true),
          colorFilter: widget.color == null
              ? null
              : ColorFilter.mode(widget.color!, BlendMode.srcIn),
        );
      case ImageSource.asset:
        return isSvg
            ? SvgPicture.asset(
                url,
                width: widget.width,
                height: widget.height,
                alignment: widget.alignment ?? Alignment.center,
                placeholderBuilder: (_) => placeholder(withAnimation: true),
                colorFilter: widget.color == null
                    ? null
                    : ColorFilter.mode(widget.color!, BlendMode.srcIn),
              )
            : Image.asset(
                url,
                width: widget.width,
                height: widget.height,
                alignment: widget.alignment ?? Alignment.center,
                fit: widget.fit ?? BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    widget.errorWidget ?? placeholder(),
                frameBuilder: (_, child, frame, ___) =>
                    frame != null ? child : placeholder(withAnimation: true),
                color: widget.color,
                colorBlendMode: widget.color == null ? null : BlendMode.srcIn,
              );
      case ImageSource.network:
        return isSvg
            ? SvgPicture.network(
                url,
                width: widget.width,
                height: widget.height,
                alignment: widget.alignment ?? Alignment.center,
                placeholderBuilder: (_) => placeholder(withAnimation: true),
                colorFilter: widget.color == null
                    ? null
                    : ColorFilter.mode(widget.color!, BlendMode.srcIn),
              )
            : Image.network(
                url,
                width: widget.width,
                height: widget.height,
                alignment: widget.alignment ?? Alignment.center,
                fit: widget.fit ?? BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    widget.errorWidget ?? placeholder(),
                frameBuilder: (_, child, frame, ___) =>
                    frame != null ? child : placeholder(withAnimation: true),
                color: widget.color,
                colorBlendMode: widget.color == null ? null : BlendMode.srcIn,
              );
      case ImageSource.file:
        final File file = File(url);
        return isSvg
            ? SvgPicture.file(
                file,
                width: widget.width,
                height: widget.height,
                alignment: widget.alignment ?? Alignment.center,
                placeholderBuilder: (_) => placeholder(withAnimation: true),
                colorFilter: widget.color == null
                    ? null
                    : ColorFilter.mode(widget.color!, BlendMode.srcIn),
              )
            : Image.file(
                file,
                width: widget.width,
                height: widget.height,
                alignment: widget.alignment ?? Alignment.center,
                fit: widget.fit ?? BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    widget.errorWidget ?? placeholder(),
                frameBuilder: (_, child, frame, ___) =>
                    frame != null ? child : placeholder(withAnimation: true),
                color: widget.color,
                colorBlendMode: widget.color == null ? null : BlendMode.srcIn,
              );
      case ImageSource.unknown:
        return widget.errorWidget ?? placeholder();
    }
  }

  Widget placeholder({bool withAnimation = false}) {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    final Widget icon = Icon(
      Icons.image_outlined,
      size: widget.width != null ? max(0, min(widget.width! - 20, 100)) : 48,
      color: Theme.of(context).disabledColor,
    );

    return Container(
      width: widget.placeholderWidth ?? widget.width,
      height: widget.placeholderHeight ?? widget.height,
      alignment: Alignment.center,
      child: withAnimation
          ? FadeTransition(opacity: animation, child: icon)
          : icon,
    );
  }
}
