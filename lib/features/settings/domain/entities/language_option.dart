import 'package:equatable/equatable.dart';

/// Represents a selectable language.
class LanguageOption extends Equatable {
  const LanguageOption({
    required this.id,
    required this.labelKey,
    required this.languageCode,
    required this.selected,
  });

  final String id;
  final String labelKey;
  final String languageCode;
  final bool selected;

  LanguageOption copyWith({bool? selected}) {
    return LanguageOption(
      id: id,
      labelKey: labelKey,
      languageCode: languageCode,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, labelKey, languageCode, selected];
}
