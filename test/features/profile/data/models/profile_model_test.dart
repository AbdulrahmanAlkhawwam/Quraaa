import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/profile/data/models/profile_model.dart';

void main() {
  test('parses profile interests and string coordinates from the API', () {
    final ProfileModel model = ProfileModel.fromJson(<String, dynamic>{
      'userId': 'user-id',
      'firstName': 'Maya',
      'lastName': 'Haddad',
      'gender': 1,
      'interests': <dynamic>[
        <String, dynamic>{
          'id': 'interest-id',
          'nameAr': 'روايات',
          'nameEn': 'Novels',
        },
      ],
      'location': <String, dynamic>{
        'latitude': '33.5138',
        'longitude': '36.2765',
      },
    });

    expect(model.fullName, 'Maya Haddad');
    expect(model.interests.single.id, 'interest-id');
    expect(model.interests.single.nameAr, 'روايات');
    expect(model.location?.latitude, 33.5138);
    expect(model.location?.longitude, 36.2765);
  });
}
