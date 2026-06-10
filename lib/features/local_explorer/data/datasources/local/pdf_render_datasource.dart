import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

class PdfTextContentInfo {
  const PdfTextContentInfo({
    required this.text,
    required this.bounds,
  });

  final String text;
  final List<Rect> bounds;

  static PdfTextContentInfo? fromChannel(Object? value) {
    if (value is! Map<Object?, Object?>) {
      return null;
    }

    final Object? rawBounds = value['bounds'];
    final List<Rect> bounds = rawBounds is List<Object?>
        ? rawBounds
            .map(_rectFromChannel)
            .whereType<Rect>()
            .toList(growable: false)
        : const <Rect>[];
    final String text = (value['text'] as String? ?? '').trim();

    if (text.isEmpty || bounds.isEmpty) {
      return null;
    }

    return PdfTextContentInfo(text: text, bounds: bounds);
  }
}

class PdfTextHighlight {
  const PdfTextHighlight({
    required this.text,
    required this.bounds,
  });

  final String text;
  final List<Rect> bounds;
}

class PdfPageTextLayer {
  const PdfPageTextLayer({
    required this.width,
    required this.height,
    required this.contents,
  });

  const PdfPageTextLayer.empty({
    this.width = 1,
    this.height = 1,
  }) : contents = const <PdfTextContentInfo>[];

  final double width;
  final double height;
  final List<PdfTextContentInfo> contents;

  factory PdfPageTextLayer.fromChannel(Object? value) {
    if (value is! Map<Object?, Object?>) {
      return const PdfPageTextLayer.empty();
    }

    final Object? rawContents = value['contents'];
    final List<PdfTextContentInfo> contents = rawContents is List<Object?>
        ? rawContents
            .map(PdfTextContentInfo.fromChannel)
            .whereType<PdfTextContentInfo>()
            .toList(growable: false)
        : const <PdfTextContentInfo>[];

    return PdfPageTextLayer(
      width: _numberFromChannel(value['width'], 1),
      height: _numberFromChannel(value['height'], 1),
      contents: contents,
    );
  }

  bool get hasText => contents.isNotEmpty;
}

abstract class PdfRenderDataSource {
  Future<int> pageCount(String path);

  Future<Uint8List> renderPage({
    required String path,
    required int pageIndex,
    required int width,
  });

  Future<PdfPageTextLayer> textLayer({
    required String path,
    required int pageIndex,
  });

  Future<void> shareText(String text);
}

class MethodChannelPdfRenderDataSource implements PdfRenderDataSource {
  MethodChannelPdfRenderDataSource({
    MethodChannel channel = const MethodChannel('quraaa/pdf_renderer'),
  }) : _channel = channel;

  final MethodChannel _channel;

  @override
  Future<int> pageCount(String path) async {
    try {
      return await _channel.invokeMethod<int>(
            'pageCount',
            <String, Object?>{'path': path},
          ) ??
          0;
    } on MissingPluginException catch (error) {
      throw UnsupportedError(
        'PDF preview is not available on this platform: $error',
      );
    }
  }

  @override
  Future<Uint8List> renderPage({
    required String path,
    required int pageIndex,
    required int width,
  }) async {
    try {
      final Uint8List? bytes = await _channel.invokeMethod<Uint8List>(
        'renderPage',
        <String, Object?>{
          'path': path,
          'pageIndex': pageIndex,
          'width': width,
        },
      );

      if (bytes == null) {
        throw StateError('PDF page was rendered with no image data.');
      }

      return bytes;
    } on MissingPluginException catch (error) {
      throw UnsupportedError(
        'PDF preview is not available on this platform: $error',
      );
    }
  }

  @override
  Future<PdfPageTextLayer> textLayer({
    required String path,
    required int pageIndex,
  }) async {
    try {
      final Object? response = await _channel.invokeMethod<Object?>(
        'textLayer',
        <String, Object?>{
          'path': path,
          'pageIndex': pageIndex,
        },
      );

      return PdfPageTextLayer.fromChannel(response);
    } on MissingPluginException {
      return const PdfPageTextLayer.empty();
    }
  }

  @override
  Future<void> shareText(String text) async {
    try {
      await _channel.invokeMethod<void>(
        'shareText',
        <String, Object?>{'text': text},
      );
    } on MissingPluginException catch (error) {
      throw UnsupportedError('Text sharing is not available: $error');
    }
  }
}

double _numberFromChannel(Object? value, double fallback) {
  return value is num ? value.toDouble() : fallback;
}

Rect? _rectFromChannel(Object? value) {
  if (value is! Map<Object?, Object?>) {
    return null;
  }

  final double left = _numberFromChannel(value['left'], 0);
  final double top = _numberFromChannel(value['top'], 0);
  final double right = _numberFromChannel(value['right'], 0);
  final double bottom = _numberFromChannel(value['bottom'], 0);

  if (right <= left || bottom <= top) {
    return null;
  }

  return Rect.fromLTRB(left, top, right, bottom);
}
