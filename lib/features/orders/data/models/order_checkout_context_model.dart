import '../../domain/entities/order_checkout_context.dart';

class OrderCheckoutContextModel extends OrderCheckoutContext {
  const OrderCheckoutContextModel({
    required super.requiresShippingLocation,
    required super.locations,
    super.selectedShippingLocationId,
  });

  factory OrderCheckoutContextModel.fromJson(Map<String, dynamic> json) {
    final Object? rawLocations = json['locations'];
    final List<OrderCheckoutLocation> locations = rawLocations is List
        ? rawLocations.map((Object? value) {
            if (value is! Map) {
              throw const FormatException('Invalid checkout location.');
            }
            final Map<String, dynamic> item = Map<String, dynamic>.from(value);
            final String id = item['id']?.toString().trim() ?? '';
            final double? latitude = _asDouble(item['latitude']);
            final double? longitude = _asDouble(item['longitude']);
            if (id.isEmpty || latitude == null || longitude == null) {
              throw const FormatException('Invalid checkout location.');
            }
            return OrderCheckoutLocation(
              id: id,
              name: item['name']?.toString(),
              address: item['address']?.toString(),
              latitude: latitude,
              longitude: longitude,
              isDefault: item['isDefault'] == true,
            );
          }).toList(growable: false)
        : const <OrderCheckoutLocation>[];

    return OrderCheckoutContextModel(
      requiresShippingLocation: json['requiresShippingLocation'] == true,
      selectedShippingLocationId:
          json['selectedShippingLocationId']?.toString(),
      locations: locations,
    );
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}
