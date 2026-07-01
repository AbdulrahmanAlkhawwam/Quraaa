import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/utils/image_helper.dart';

void main() {
  group('ImageHelper', () {
    group('isSvg', () {
      test('returns true for lowercase svg extension', () {
        expect(ImageHelper.isSvg('assets/icons/icon.svg'), isTrue);
      });

      test('returns true for uppercase svg extension', () {
        expect(ImageHelper.isSvg('assets/icons/icon.SVG'), isTrue);
      });

      test('returns true for svg in network url', () {
        expect(ImageHelper.isSvg('https://example.com/image.svg'), isTrue);
      });

      test('returns true for svg url with query parameters', () {
        expect(
          ImageHelper.isSvg('https://example.com/image.svg?size=large'),
          isTrue,
        );
      });

      test('returns false for non-svg extension', () {
        expect(ImageHelper.isSvg('assets/images/photo.png'), isFalse);
      });

      test('returns false when svg appears in path but not extension', () {
        expect(ImageHelper.isSvg('assets/svg/photo.png'), isFalse);
      });

      test('trims whitespace before checking', () {
        expect(ImageHelper.isSvg('  assets/icons/icon.svg  '), isTrue);
      });
    });

    group('detectSource', () {
      test('detects inline svg string', () {
        expect(
          ImageHelper.detectSource(
            '<svg viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg"></svg>',
          ),
          ImageSource.inlineSvg,
        );
      });

      test('detects inline xml svg string', () {
        expect(
          ImageHelper.detectSource('<?xml version="1.0"?><svg></svg>'),
          ImageSource.inlineSvg,
        );
      });

      test('detects asset path', () {
        expect(
          ImageHelper.detectSource('assets/images/photo.png'),
          ImageSource.asset,
        );
      });

      test('detects https url', () {
        expect(
          ImageHelper.detectSource('https://example.com/photo.png'),
          ImageSource.network,
        );
      });

      test('detects http url', () {
        expect(
          ImageHelper.detectSource('http://example.com/photo.png'),
          ImageSource.network,
        );
      });

      test('detects file path when isFile is true', () {
        expect(
          ImageHelper.detectSource('/tmp/photo.png', isFile: true),
          ImageSource.file,
        );
      });

      test('returns unknown for unmatched path', () {
        expect(
          ImageHelper.detectSource('some/random/path'),
          ImageSource.unknown,
        );
      });

      test('returns file for unmatched path when isFile is true', () {
        expect(
          ImageHelper.detectSource('some/random/path', isFile: true),
          ImageSource.file,
        );
      });

      test('trims whitespace before detecting', () {
        expect(
          ImageHelper.detectSource('  assets/images/photo.png  '),
          ImageSource.asset,
        );
      });
    });
  });
}
