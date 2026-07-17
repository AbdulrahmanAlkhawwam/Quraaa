import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('localization keys', () {
    late Set<String> englishKeys;
    late Set<String> arabicKeys;

    setUpAll(() {
      englishKeys = _flattenTranslations('assets/translations/en.json').keys.toSet();
      arabicKeys = _flattenTranslations('assets/translations/ar.json').keys.toSet();
    });

    test('English and Arabic dictionaries expose the same leaf keys', () {
      expect(
        englishKeys.difference(arabicKeys),
        isEmpty,
        reason: 'Every English translation key must exist in Arabic.',
      );
      expect(
        arabicKeys.difference(englishKeys),
        isEmpty,
        reason: 'Every Arabic translation key must exist in English.',
      );
    });

    test('LocalizationConstants leaf keys exist in both dictionaries', () {
      final Set<String> keys = _localizationConstantKeys().difference(
        <String>{
          'assets/translations',
          'user_data.edit',
        },
      );

      expect(keys.difference(englishKeys), isEmpty);
      expect(keys.difference(arabicKeys), isEmpty);
    });

    test('literal translation keys used in Dart files exist in both dictionaries', () {
      final Set<String> keys = _literalTranslationKeys();

      expect(keys.difference(englishKeys), isEmpty);
      expect(keys.difference(arabicKeys), isEmpty);
    });
  });
}

Map<String, Object?> _flattenTranslations(String path) {
  final Object? decoded = jsonDecode(File(path).readAsStringSync());
  final Map<String, Object?> output = <String, Object?>{};

  void visit(Object? value, String prefix) {
    if (value is Map) {
      for (final MapEntry<dynamic, dynamic> entry in value.entries) {
        final String segment = entry.key as String;
        final String key = prefix.isEmpty ? segment : '$prefix.$segment';
        visit(entry.value, key);
      }
      return;
    }

    output[prefix] = value;
  }

  visit(decoded, '');
  return output;
}

Set<String> _localizationConstantKeys() {
  final String source = File(
    'lib/core/localization/localization_constants.dart',
  ).readAsStringSync();

  return RegExp(r"=\s*'([^']+)'")
      .allMatches(source)
      .map((RegExpMatch match) => match.group(1)!)
      .toSet();
}

Set<String> _literalTranslationKeys() {
  final RegExp translationCall = RegExp(
    r"'([a-zA-Z0-9_]+(?:\.[a-zA-Z0-9_]+)+)'\s*\.tr\(",
  );
  final Set<String> keys = <String>{};

  for (final FileSystemEntity entity in Directory('lib').listSync(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }

    final String source = entity.readAsStringSync();
    keys.addAll(
      translationCall
          .allMatches(source)
          .map((RegExpMatch match) => match.group(1)!),
    );
  }

  return keys;
}
