import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/shared/widgets/app_image.dart';

const _svgString = '<svg viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg">'
    '<rect width="10" height="10"/></svg>';

void main() {
  group('AppImage', () {
    testWidgets('shows error widget when url is null', (tester) async {
      const error = Text('error');
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage(null, errorWidget: error),
        ),
      );

      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('shows default placeholder when url is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage(null),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('renders SvgPicture.string for inline svg', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppImage(_svgString),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders SvgPicture.string for inline xml svg', (tester) async {
      const xmlSvg = '<?xml version="1.0"?><svg></svg>';
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage(xmlSvg),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('renders Image.asset for asset image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage('assets/images/onboarding.jpg'),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    });

    testWidgets('renders SvgPicture.asset for asset svg', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage('assets/icons/icon.svg'),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('renders SvgPicture.asset for uppercase asset svg extension',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage('assets/icons/icon.SVG'),
        ),
      );

      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('renders Image.network for network image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage('https://example.com/image.png'),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    });

    testWidgets('shows error widget for unrecognized url', (tester) async {
      const error = Text('fallback error');
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage('unknown/path', errorWidget: error),
        ),
      );

      expect(find.text('fallback error'), findsOneWidget);
    });

    testWidgets('shows placeholder for unrecognized url', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage('unknown/path'),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('uses custom placeholder when provided', (tester) async {
      const customPlaceholder = Text('loading');
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage(null, placeholder: customPlaceholder),
        ),
      );

      expect(find.text('loading'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsNothing);
    });

    testWidgets('applies width and height to the rendered image',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage('assets/images/onboarding.jpg', width: 64, height: 64),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, 64);
      expect(image.height, 64);
    });

    testWidgets('applies color to image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage(
            'assets/images/onboarding.jpg',
            color: Colors.red,
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.color, Colors.red);
    });

    testWidgets('applies color filter to svg', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage(
            'assets/icons/icon.svg',
            color: Colors.red,
          ),
        ),
      );

      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.colorFilter, isNotNull);
    });

    testWidgets('animated placeholder wraps icon in FadeTransition',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage('https://example.com/image.png'),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(AppImage),
          matching: find.byType(FadeTransition),
        ),
        findsOneWidget,
      );
    });

    testWidgets('placeholder icon size is clamped to a non-negative value',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppImage(null, width: 10),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });
}
