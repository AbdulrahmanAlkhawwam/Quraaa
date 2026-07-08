import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/libraries/data/models/library_model.dart';

void main() {
  group('LibraryModel', () {
    const Map<String, dynamic> json = <String, dynamic>{
      'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      'libraryName': 'Jarir Book Store',
      'location': 'Riyadh',
      'libraryImage': 'https://example.com/library.png',
      'headerImage': 'https://example.com/header.png',
      'email': 'contact@jarir.com',
    };

    test('fromJson parses all fields correctly', () {
      final LibraryModel model = LibraryModel.fromJson(json);

      expect(model.id, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(model.libraryName, 'Jarir Book Store');
      expect(model.location, 'Riyadh');
      expect(model.libraryImage, 'https://example.com/library.png');
      expect(model.headerImage, 'https://example.com/header.png');
      expect(model.email, 'contact@jarir.com');
    });

    test('fromJson handles null values gracefully', () {
      final LibraryModel model = LibraryModel.fromJson(
        const <String, dynamic>{},
      );

      expect(model.id, '');
      expect(model.libraryName, '');
      expect(model.location, '');
      expect(model.libraryImage, '');
      expect(model.headerImage, '');
      expect(model.email, '');
    });

    test('toJson serializes all fields correctly', () {
      const LibraryModel model = LibraryModel(
        id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        libraryName: 'Jarir Book Store',
        location: 'Riyadh',
        libraryImage: 'https://example.com/library.png',
        headerImage: 'https://example.com/header.png',
        email: 'contact@jarir.com',
      );

      expect(model.toJson(), json);
    });

    test('toEntity maps to domain entity correctly', () {
      const LibraryModel model = LibraryModel(
        id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        libraryName: 'Jarir Book Store',
        location: 'Riyadh',
        libraryImage: 'https://example.com/library.png',
        headerImage: 'https://example.com/header.png',
        email: 'contact@jarir.com',
      );

      final entity = model.toEntity();

      expect(entity.id, model.id);
      expect(entity.libraryName, model.libraryName);
      expect(entity.location, model.location);
      expect(entity.libraryImage, model.libraryImage);
      expect(entity.headerImage, model.headerImage);
      expect(entity.email, model.email);
    });
  });
}
