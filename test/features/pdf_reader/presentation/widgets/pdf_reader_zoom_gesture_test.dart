import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quraaa/features/pdf_reader/domain/entities/pdf_reader_local_state.dart';
import 'package:quraaa/features/pdf_reader/domain/entities/pdf_text_layer.dart';
import 'package:quraaa/features/pdf_reader/domain/entities/pdf_text_note.dart';
import 'package:quraaa/features/pdf_reader/domain/repositories/pdf_reader_repository.dart';
import 'package:quraaa/features/pdf_reader/domain/use_cases/get_pdf_text_layer_use_case.dart';
import 'package:quraaa/features/pdf_reader/domain/use_cases/render_pdf_page_use_case.dart';
import 'package:quraaa/features/pdf_reader/domain/use_cases/share_pdf_text_use_case.dart';
import 'package:quraaa/features/pdf_reader/domain/value_objects/pdf_reader_result.dart';
import 'package:quraaa/features/pdf_reader/presentation/bloc/pdf_reader_bloc.dart';
import 'package:quraaa/features/pdf_reader/presentation/widgets/pdf_reader_continuous_view.dart';

class _MockPdfReaderRepository extends Mock implements PdfReaderRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'pinch zoom continues as one-finger pan without lifting both fingers',
    (WidgetTester tester) async {
      final _MockPdfReaderRepository repository = _MockPdfReaderRepository();
      when(
        () => repository.textLayer(
          path: any(named: 'path'),
          pageIndex: any(named: 'pageIndex'),
        ),
      ).thenAnswer(
        (_) async => const PdfReaderSuccess<PdfPageTextLayer>(
          PdfPageTextLayer.empty(),
        ),
      );
      when(
        () => repository.renderPage(
          path: any(named: 'path'),
          pageIndex: any(named: 'pageIndex'),
          width: any(named: 'width'),
        ),
      ).thenAnswer(
        (_) async => PdfReaderSuccess<Uint8List>(Uint8List(0)),
      );

      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const <Locale>[Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          saveLocale: false,
          child: _ReaderHarness(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      final Finder viewportFinder = find.byType(InteractiveViewer).first;
      final InteractiveViewer viewport = tester.widget<InteractiveViewer>(
        viewportFinder,
      );
      final TransformationController controller =
          viewport.transformationController!;
      final Offset center = tester.getCenter(viewportFinder);
      final TestGesture firstFinger = await tester.startGesture(
        center - const Offset(32, 0),
        pointer: 1,
      );
      final TestGesture secondFinger = await tester.startGesture(
        center + const Offset(32, 0),
        pointer: 2,
      );

      await firstFinger.moveBy(const Offset(-64, 0));
      await secondFinger.moveBy(const Offset(64, 0));
      await tester.pump();

      expect(controller.value.getMaxScaleOnAxis(), greaterThan(1.5));

      final double translationBeforePan = controller.value.getTranslation().x;
      await secondFinger.up();
      await tester.pump();
      await firstFinger.moveBy(const Offset(36, 24));
      await tester.pump();

      expect(
        controller.value.getTranslation().x,
        isNot(closeTo(translationBeforePan, 0.1)),
      );

      await firstFinger.up();
      await tester.pumpAndSettle();
    },
  );
}

class _ReaderHarness extends StatelessWidget {
  const _ReaderHarness({required this.repository});

  final PdfReaderRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: Scaffold(
        body: PdfReaderContinuousView(
          state: const PdfReaderReady(path: 'gesture-test.pdf', pageCount: 2),
          scrollDirection: PdfReaderScrollDirection.vertical,
          inkStrokes: const <PdfInkStroke>[],
          inkMode: false,
          inkColorValue: 0xFFF5C242,
          inkTool: PdfInkTool.highlighter,
          renderPage: RenderPdfPageUseCase(repository),
          getTextLayer: GetPdfTextLayerUseCase(repository),
          shareText: SharePdfTextUseCase(repository),
          onPageChanged: (_) {},
          onInkStrokeCompleted: (_) {},
          onNoteRequested: ({
            required PdfPageAnchor? anchor,
            required List<PdfTextBounds> bounds,
            required int pageIndex,
            required String selectedText,
          }) {},
          onSavedNotePressed: (PdfTextNote _) {},
          onMessage: (_) {},
        ),
      ),
    );
  }
}
