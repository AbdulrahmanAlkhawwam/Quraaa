import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/pdf_reader/presentation/widgets/pdf_reader_zoom_controls.dart';

void main() {
  Widget buildSubject({
    required double scale,
    required VoidCallback onZoomIn,
    required VoidCallback onZoomOut,
    required VoidCallback onResetZoom,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PdfReaderZoomControls(
            scale: scale,
            zoomInLabel: 'Zoom in',
            zoomOutLabel: 'Zoom out',
            resetZoomLabel: 'Reset zoom',
            onZoomIn: onZoomIn,
            onZoomOut: onZoomOut,
            onResetZoom: onResetZoom,
          ),
        ),
      ),
    );
  }

  testWidgets('starts at 100 percent and disables zoom out', (
    WidgetTester tester,
  ) async {
    int zoomInCalls = 0;
    int zoomOutCalls = 0;

    await tester.pumpWidget(
      buildSubject(
        scale: 1,
        onZoomIn: () => zoomInCalls++,
        onZoomOut: () => zoomOutCalls++,
        onResetZoom: () {},
      ),
    );

    expect(find.text('100%'), findsOneWidget);
    await tester.tap(find.byTooltip('Zoom out'));
    await tester.tap(find.byTooltip('Zoom in'));

    expect(zoomOutCalls, 0);
    expect(zoomInCalls, 1);
  });

  testWidgets('shows the scale and resets from the percentage button', (
    WidgetTester tester,
  ) async {
    int resetCalls = 0;
    int zoomOutCalls = 0;

    await tester.pumpWidget(
      buildSubject(
        scale: 1.5,
        onZoomIn: () {},
        onZoomOut: () => zoomOutCalls++,
        onResetZoom: () => resetCalls++,
      ),
    );

    expect(find.text('150%'), findsOneWidget);
    await tester.tap(find.byTooltip('Zoom out'));
    await tester.tap(find.byTooltip('Reset zoom'));

    expect(zoomOutCalls, 1);
    expect(resetCalls, 1);
  });
}
