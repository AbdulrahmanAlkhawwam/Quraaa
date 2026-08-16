import 'package:equatable/equatable.dart';

class LibraryRegistration extends Equatable {
  const LibraryRegistration({
    required this.registrationUrl,
    required this.expiresAtUtc,
  });

  final String registrationUrl;
  final DateTime expiresAtUtc;

  @override
  List<Object> get props => <Object>[registrationUrl, expiresAtUtc];
}
