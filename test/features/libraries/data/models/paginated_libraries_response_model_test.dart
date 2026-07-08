import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/libraries/data/models/library_model.dart';
import 'package:quraaa/features/libraries/data/models/paginated_libraries_response_model.dart';

void main() {
  group('PaginatedLibrariesResponseModel', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'items': <Map<String, dynamic>>[
        const <String, dynamic>{
          'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
          'libraryName': 'Jarir Book Store',
          'location': 'Riyadh',
          'libraryImage': 'https://example.com/library.png',
          'headerImage': 'https://example.com/header.png',
          'email': 'contact@jarir.com',
        },
      ],
      'pageNumber': '1',
      'pageSize': '10',
      'totalCount': '100',
      'totalPages': '10',
      'hasNextPage': true,
      'hasPreviousPage': false,
    };

    test('fromJson parses string pagination fields correctly', () {
      final PaginatedLibrariesResponseModel model =
          PaginatedLibrariesResponseModel.fromJson(json);

      expect(model.items.length, 1);
      expect(model.pageNumber, 1);
      expect(model.pageSize, 10);
      expect(model.totalCount, 100);
      expect(model.totalPages, 10);
      expect(model.hasNextPage, true);
      expect(model.hasPreviousPage, false);
    });

    test('fromJson parses int pagination fields correctly', () {
      final PaginatedLibrariesResponseModel model =
          PaginatedLibrariesResponseModel.fromJson(
        <String, dynamic>{
          ...json,
          'pageNumber': 2,
          'pageSize': 20,
          'totalCount': 200,
          'totalPages': 10,
        },
      );

      expect(model.pageNumber, 2);
      expect(model.pageSize, 20);
      expect(model.totalCount, 200);
    });

    test('fromJson returns empty list when items is missing', () {
      final PaginatedLibrariesResponseModel model =
          PaginatedLibrariesResponseModel.fromJson(
        <String, dynamic>{
          'pageNumber': 1,
          'pageSize': 10,
          'totalCount': 0,
          'totalPages': 0,
          'hasNextPage': false,
          'hasPreviousPage': false,
        },
      );

      expect(model.items, isEmpty);
    });

    test('toJson serializes the model correctly', () {
      const PaginatedLibrariesResponseModel model =
          PaginatedLibrariesResponseModel(
        items: <LibraryModel>[
          LibraryModel(
            id: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
            libraryName: 'Jarir Book Store',
            location: 'Riyadh',
            libraryImage: 'https://example.com/library.png',
            headerImage: 'https://example.com/header.png',
            email: 'contact@jarir.com',
          ),
        ],
        pageNumber: 1,
        pageSize: 10,
        totalCount: 100,
        totalPages: 10,
        hasNextPage: true,
        hasPreviousPage: false,
      );

      final Map<String, dynamic> result = model.toJson();

      expect(result['items'], isA<List<dynamic>>());
      expect(result['pageNumber'], 1);
      expect(result['pageSize'], 10);
      expect(result['totalCount'], 100);
      expect(result['totalPages'], 10);
      expect(result['hasNextPage'], true);
      expect(result['hasPreviousPage'], false);
    });
  });
}
