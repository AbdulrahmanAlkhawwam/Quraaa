import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/theme/app_colors.dart';

class RenderedPdfPageImage extends StatelessWidget {
  const RenderedPdfPageImage({
    required this.snapshot,
    super.key,
  });

  final AsyncSnapshot<Uint8List> snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    final Uint8List? bytes = snapshot.data;
    if (snapshot.hasError || bytes == null || bytes.isEmpty) {
      return const ColoredBox(
        color: AppColors.surfaceLight,
        child: Center(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedPdf02,
            color: AppColors.pdfLabel,
            size: 54,
          ),
        ),
      );
    }

    return Image.memory(
      bytes,
      fit: BoxFit.fill,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
    );
  }
}
