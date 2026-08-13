import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/cart/data/models/cart_response_model.dart';

void main() {
  test('parses string-valued numeric cart fields', () {
    final CartResponseModel response = CartResponseModel.fromJson(
      <String, dynamic>{
        'cartId': 'cart-id',
        'status': 0,
        'itemCount': '1',
        'totalAmount': '10.50',
        'items': <Map<String, String>>[
          <String, String>{
            'listingId': 'listing-id',
            'quantity': '2',
            'unitPrice': '5.25',
            'lineTotal': '10.50',
          },
        ],
      },
    );

    expect(response.itemCount, 1);
    expect(response.totalAmount, 10.5);
    expect(response.items.single.quantity, 2);
    expect(response.items.single.unitPrice, 5.25);
  });
}
