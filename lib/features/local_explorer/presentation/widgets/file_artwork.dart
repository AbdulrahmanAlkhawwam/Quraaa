import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/local_file_entry.dart';
import 'document_artwork_label.dart';

class FileArtwork extends StatelessWidget {
  const FileArtwork({
    required this.type,
    this.label,
    super.key,
  });

  final LocalFileEntryType type;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final bool isDirectory = type == LocalFileEntryType.directory;

    return AspectRatio(
      aspectRatio: isDirectory ? 1.40 : 0.78,
      child: CustomPaint(
        painter: isDirectory
            ? const _FolderArtworkPainter()
            : _DocumentArtworkPainter.styleFor(type),
        child: isDirectory
            ? const SizedBox.expand()
            : DocumentArtworkLabel(
                label: label ?? _defaultLabelFor(type),
                type: type,
              ),
      ),
    );
  }

  String _defaultLabelFor(LocalFileEntryType type) {
    return switch (type) {
      LocalFileEntryType.directory => '',
      LocalFileEntryType.pdf => 'PDF',
      LocalFileEntryType.unsupported => 'File',
    };
  }
}

class _FolderArtworkPainter extends CustomPainter {
  const _FolderArtworkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withAlpha(12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawRRect(
      RRect.fromLTRBR(
        width * 0.03,
        height * 0.29,
        width * 0.98,
        height * 0.99,
        Radius.circular(width * 0.08),
      ),
      shadowPaint,
    );

    final Path tabPath = Path()
      ..moveTo(width * 0.02, height * 0.16)
      ..quadraticBezierTo(width * 0.02, height * 0.04, width * 0.13, height * 0.04)
      ..lineTo(width * 0.58, height * 0.04)
      ..quadraticBezierTo(width * 0.66, height * 0.04, width * 0.70, height * 0.16)
      ..lineTo(width * 0.76, height * 0.31)
      ..lineTo(width * 0.98, height * 0.31)
      ..lineTo(width * 0.98, height * 0.48)
      ..lineTo(width * 0.02, height * 0.48)
      ..close();

    canvas.drawPath(
      tabPath,
      Paint()..color = AppColors.folderTab,
    );

    canvas.drawRRect(
      RRect.fromLTRBR(
        width * 0.02,
        height * 0.28,
        width * 0.98,
        height * 0.98,
        Radius.circular(width * 0.08),
      ),
      Paint()..color = AppColors.folderBody,
    );
  }

  @override
  bool shouldRepaint(covariant _FolderArtworkPainter oldDelegate) {
    return false;
  }
}

class _DocumentArtworkPainter extends CustomPainter {
  const _DocumentArtworkPainter({
    required this.fillColor,
    required this.foldColor,
  });

  final Color fillColor;
  final Color foldColor;

  static _DocumentArtworkPainter styleFor(LocalFileEntryType type) {
    return switch (type) {
      LocalFileEntryType.directory => const _DocumentArtworkPainter(
          fillColor: AppColors.folderBody,
          foldColor: AppColors.folderTab,
        ),
      LocalFileEntryType.pdf => const _DocumentArtworkPainter(
          fillColor: AppColors.pdfSurface,
          foldColor: AppColors.pdfFold,
        ),
      LocalFileEntryType.unsupported => const _DocumentArtworkPainter(
          fillColor: AppColors.unsupportedFileSurface,
          foldColor: AppColors.unsupportedFileFold,
        ),
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withAlpha(10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final Path shadowPath = _pagePath(size).shift(Offset(0, height * 0.025));
    canvas.drawPath(shadowPath, shadowPaint);

    final Path pagePath = _pagePath(size);
    canvas.drawPath(pagePath, Paint()..color = fillColor);

    final Path foldPath = Path()
      ..moveTo(width * 0.60, 0)
      ..lineTo(width * 0.98, height * 0.31)
      ..lineTo(width * 0.68, height * 0.31)
      ..quadraticBezierTo(width * 0.60, height * 0.31, width * 0.60, height * 0.23)
      ..close();

    canvas.drawPath(foldPath, Paint()..color = foldColor);
  }

  Path _pagePath(Size size) {
    final double width = size.width;
    final double height = size.height;

    return Path()
      ..moveTo(width * 0.14, 0)
      ..lineTo(width * 0.60, 0)
      ..quadraticBezierTo(width * 0.66, 0, width * 0.72, height * 0.05)
      ..lineTo(width * 0.98, height * 0.28)
      ..quadraticBezierTo(width, height * 0.30, width, height * 0.36)
      ..lineTo(width, height * 0.86)
      ..quadraticBezierTo(width, height, width * 0.86, height)
      ..lineTo(width * 0.14, height)
      ..quadraticBezierTo(0, height, 0, height * 0.86)
      ..lineTo(0, height * 0.14)
      ..quadraticBezierTo(0, 0, width * 0.14, 0)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _DocumentArtworkPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor || oldDelegate.foldColor != foldColor;
  }
}
