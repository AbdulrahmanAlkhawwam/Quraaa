import 'package:equatable/equatable.dart';

/// Available application theme modes.
enum AppearanceMode {
  light,
  dark,
  system,
}

/// Represents a selectable appearance option.
class AppearanceOption extends Equatable {
  const AppearanceOption({
    required this.id,
    required this.labelKey,
    required this.mode,
    required this.selected,
  });

  final String id;
  final String labelKey;
  final AppearanceMode mode;
  final bool selected;

  AppearanceOption copyWith({bool? selected}) {
    return AppearanceOption(
      id: id,
      labelKey: labelKey,
      mode: mode,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, labelKey, mode, selected];
}
