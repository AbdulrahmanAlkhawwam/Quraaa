import 'package:flutter/widgets.dart';

class SupportedLocales {
  SupportedLocales._();

  static const Locale english = Locale('en');
  static const Locale arabic = Locale('ar');

  static const List<Locale> all = <Locale>[
    english,
    arabic,
  ];

  static const Locale fallback = english;

  static bool isRtl(Locale locale) => locale.languageCode == arabic.languageCode;
}
