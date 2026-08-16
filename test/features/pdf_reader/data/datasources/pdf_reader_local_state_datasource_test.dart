import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quraaa/features/pdf_reader/data/datasources/local/pdf_reader_local_state_datasource.dart';
import 'package:quraaa/features/pdf_reader/domain/entities/pdf_reader_local_state.dart';

import '../../../../mocks/mock_classes.dart';

void main() {
  late MockStorageService storageService;
  late StoredPdfReaderLocalStateDataSource dataSource;
  String? storedValue;

  setUp(() {
    storageService = MockStorageService();
    dataSource = StoredPdfReaderLocalStateDataSource(storageService);
    storedValue = null;

    when(() => storageService.getString(any())).thenAnswer((_) => storedValue);
    when(() => storageService.setString(any(), any())).thenAnswer(
      (Invocation invocation) async {
        storedValue = invocation.positionalArguments[1] as String;
        return true;
      },
    );
  });

  test('persists pen and highlighter strokes with their tool styles', () async {
    final PdfReaderLocalState state = PdfReaderLocalState(
      currentPageIndex: 4,
      scrollDirection: PdfReaderScrollDirection.horizontal,
      readingDays: <DateTime>[DateTime.utc(2026, 8, 15)],
      inkStrokes: const <PdfInkStroke>[
        PdfInkStroke(
          id: 'highlight-1',
          pageIndex: 2,
          colorValue: 0xFFF5C242,
          tool: PdfInkTool.highlighter,
          widthRatio: 0.018,
          points: <PdfInkPoint>[
            PdfInkPoint(xRatio: 0.1, yRatio: 0.2),
            PdfInkPoint(xRatio: 0.4, yRatio: 0.2),
          ],
        ),
        PdfInkStroke(
          id: 'pen-1',
          pageIndex: 4,
          colorValue: 0xFF243B53,
          tool: PdfInkTool.pen,
          widthRatio: 0.0045,
          points: <PdfInkPoint>[
            PdfInkPoint(xRatio: 0.2, yRatio: 0.3),
            PdfInkPoint(xRatio: 0.25, yRatio: 0.4),
          ],
        ),
      ],
    );

    await dataSource.saveState('book.pdf', state);
    final PdfReaderLocalState loaded = await dataSource.loadState('book.pdf');

    expect(loaded, state);
    expect(loaded.inkStrokes.last.tool, PdfInkTool.pen);
  });

  test('loads strokes saved before tool metadata as highlighters', () async {
    const PdfReaderLocalState state = PdfReaderLocalState(
      inkStrokes: <PdfInkStroke>[
        PdfInkStroke(
          id: 'legacy-stroke',
          pageIndex: 0,
          colorValue: 0xFFF5C242,
          points: <PdfInkPoint>[
            PdfInkPoint(xRatio: 0.1, yRatio: 0.1),
            PdfInkPoint(xRatio: 0.2, yRatio: 0.2),
          ],
        ),
      ],
    );

    await dataSource.saveState('legacy.pdf', state);
    final Map<String, dynamic> json =
        jsonDecode(storedValue!) as Map<String, dynamic>;
    final List<dynamic> strokes = json['inkStrokes'] as List<dynamic>;
    (strokes.first as Map<String, dynamic>).remove('tool');
    storedValue = jsonEncode(json);

    final PdfReaderLocalState loaded = await dataSource.loadState('legacy.pdf');

    expect(loaded.inkStrokes.single.tool, PdfInkTool.highlighter);
  });
}
