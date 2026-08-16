import 'dart:convert';

import '../../../../../core/services/storage_service.dart';
import '../../../domain/entities/pdf_reader_local_state.dart';

abstract class PdfReaderLocalStateDataSource {
  Future<PdfReaderLocalState> loadState(String path);

  Future<void> saveState(String path, PdfReaderLocalState state);
}

class StoredPdfReaderLocalStateDataSource
    implements PdfReaderLocalStateDataSource {
  const StoredPdfReaderLocalStateDataSource(this._storageService);

  final StorageService _storageService;

  static const String _keyPrefix = 'pdf_reader_local_state_v1_';

  @override
  Future<PdfReaderLocalState> loadState(String path) async {
    final String? encoded = _storageService.getString(_key(path));
    if (encoded == null || encoded.isEmpty) {
      return const PdfReaderLocalState();
    }

    try {
      final Object? decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        return const PdfReaderLocalState();
      }
      return _stateFromJson(decoded);
    } catch (_) {
      return const PdfReaderLocalState();
    }
  }

  @override
  Future<void> saveState(String path, PdfReaderLocalState state) async {
    await _storageService.setString(
        _key(path), jsonEncode(_stateToJson(state)));
  }

  String _key(String path) => _keyPrefix + base64Url.encode(utf8.encode(path));

  Map<String, Object?> _stateToJson(PdfReaderLocalState state) {
    return <String, Object?>{
      'currentPageIndex': state.currentPageIndex,
      'scrollDirection': state.scrollDirection.name,
      'readingDays': state.readingDays
          .map((DateTime day) => day.toIso8601String())
          .toList(growable: false),
      'inkStrokes': state.inkStrokes
          .map(
            (PdfInkStroke stroke) => <String, Object?>{
              'id': stroke.id,
              'pageIndex': stroke.pageIndex,
              'colorValue': stroke.colorValue,
              'tool': stroke.tool.name,
              'widthRatio': stroke.widthRatio,
              'points': stroke.points
                  .map(
                    (PdfInkPoint point) => <String, Object?>{
                      'xRatio': point.xRatio,
                      'yRatio': point.yRatio,
                    },
                  )
                  .toList(growable: false),
            },
          )
          .toList(growable: false),
    };
  }

  PdfReaderLocalState _stateFromJson(Map<String, dynamic> json) {
    final String direction = json['scrollDirection'] as String? ?? '';
    return PdfReaderLocalState(
      currentPageIndex: (json['currentPageIndex'] as num?)?.toInt() ?? 0,
      scrollDirection: direction == PdfReaderScrollDirection.horizontal.name
          ? PdfReaderScrollDirection.horizontal
          : PdfReaderScrollDirection.vertical,
      readingDays: (json['readingDays'] as List<dynamic>? ?? <dynamic>[])
          .whereType<String>()
          .map(DateTime.tryParse)
          .whereType<DateTime>()
          .toList(growable: false),
      inkStrokes: (json['inkStrokes'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_strokeFromJson)
          .whereType<PdfInkStroke>()
          .toList(growable: false),
    );
  }

  PdfInkStroke? _strokeFromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String? ?? '';
    final int pageIndex = (json['pageIndex'] as num?)?.toInt() ?? -1;
    final List<PdfInkPoint> points =
        (json['points'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> point) => PdfInkPoint(
                xRatio: (point['xRatio'] as num?)?.toDouble() ?? 0,
                yRatio: (point['yRatio'] as num?)?.toDouble() ?? 0,
              ),
            )
            .toList(growable: false);
    if (id.isEmpty || pageIndex < 0 || points.isEmpty) {
      return null;
    }

    return PdfInkStroke(
      id: id,
      pageIndex: pageIndex,
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFFF5C242,
      tool: json['tool'] == PdfInkTool.pen.name
          ? PdfInkTool.pen
          : PdfInkTool.highlighter,
      widthRatio: (json['widthRatio'] as num?)?.toDouble() ?? 0.018,
      points: points,
    );
  }
}
