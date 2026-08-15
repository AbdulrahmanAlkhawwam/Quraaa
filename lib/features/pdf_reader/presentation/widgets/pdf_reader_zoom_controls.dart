import 'package:flutter/material.dart';

import '../../../../shared/extensions/app_context.dart';
import '../../../../shared/theme/app_radius.dart';

class PdfReaderZoomControls extends StatelessWidget {
  const PdfReaderZoomControls({
    required this.scale,
    required this.zoomInLabel,
    required this.zoomOutLabel,
    required this.resetZoomLabel,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onResetZoom,
    this.minScale = 1,
    this.maxScale = 4,
    super.key,
  });

  final double scale;
  final double minScale;
  final double maxScale;
  final String zoomInLabel;
  final String zoomOutLabel;
  final String resetZoomLabel;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onResetZoom;

  @override
  Widget build(BuildContext context) {
    final bool canZoomOut = scale > minScale + 0.01;
    final bool canZoomIn = scale < maxScale - 0.01;

    return Material(
      color: context.appCard.withValues(alpha: 0.96),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        side: BorderSide(color: context.appBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _ZoomIconButton(
              icon: Icons.remove_rounded,
              tooltip: zoomOutLabel,
              onPressed: canZoomOut ? onZoomOut : null,
            ),
            Tooltip(
              message: resetZoomLabel,
              child: Semantics(
                button: true,
                label: resetZoomLabel,
                value: '${(scale * 100).round()}%',
                child: InkWell(
                  onTap: canZoomOut ? onResetZoom : null,
                  child: SizedBox(
                    width: 64,
                    height: 44,
                    child: Center(
                      child: Text(
                        '${(scale * 100).round()}%',
                        maxLines: 1,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: canZoomOut
                              ? context.colors.primary
                              : context.appTextSecondary,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _ZoomIconButton(
              icon: Icons.add_rounded,
              tooltip: zoomInLabel,
              onPressed: canZoomIn ? onZoomIn : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomIconButton extends StatelessWidget {
  const _ZoomIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      icon: Icon(icon, size: 21),
      color: context.appTextPrimary,
      disabledColor: context.appTextTertiary.withValues(alpha: 0.5),
    );
  }
}
