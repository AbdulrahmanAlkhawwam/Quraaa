import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/profile/data/models/profile_location_model.dart';

void main() {
  test('parses the profile location list item returned by the API', () {
    final ProfileLocationModel model = ProfileLocationModel.fromJson(
      <String, dynamic>{
        'id': '58924258-bab4-4576-a78c-d27219cde19b',
        'name': 'Saved location',
        'address': null,
        'latitude': 33.54640553148003,
        'longitude': 36.30615263330232,
        'isDefault': true,
        'creationTime': '2026-07-02T12:17:27.407098Z',
        'lastModificationTime': null,
      },
    );

    expect(model.id, '58924258-bab4-4576-a78c-d27219cde19b');
    expect(model.name, 'Saved location');
    expect(model.address, isNull);
    expect(model.latitude, 33.54640553148003);
    expect(model.longitude, 36.30615263330232);
    expect(model.isDefault, isTrue);
    expect(model.creationTime, '2026-07-02T12:17:27.407098Z');
    expect(model.lastModificationTime, isNull);
  });

  test('parses every item in a locations array', () {
    final List<ProfileLocationModel> locations =
        ProfileLocationModel.listFromJson(<dynamic>[
      <String, dynamic>{
        'id': 'first',
        'name': 'Home',
        'latitude': 33.5,
        'longitude': 36.2,
        'isDefault': true,
      },
      <String, dynamic>{
        'id': 'second',
        'name': 'Work',
        'latitude': 33.6,
        'longitude': 36.3,
        'isDefault': false,
      },
    ]);

    expect(locations, hasLength(2));
    expect(
        locations.map((location) => location.name), <String>['Home', 'Work']);
    expect(locations.singleWhere((location) => location.isDefault).id, 'first');
  });
}
