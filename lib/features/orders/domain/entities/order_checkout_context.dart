import 'package:equatable/equatable.dart';

class OrderCheckoutLocation extends Equatable {
  const OrderCheckoutLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    this.name,
    this.address,
  });

  final String id;
  final String? name;
  final String? address;
  final double latitude;
  final double longitude;
  final bool isDefault;

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        address,
        latitude,
        longitude,
        isDefault,
      ];
}

class OrderCheckoutContext extends Equatable {
  const OrderCheckoutContext({
    required this.requiresShippingLocation,
    required this.locations,
    this.selectedShippingLocationId,
  });

  final bool requiresShippingLocation;
  final String? selectedShippingLocationId;
  final List<OrderCheckoutLocation> locations;

  OrderCheckoutLocation? get preferredLocation {
    final String selectedId = selectedShippingLocationId?.trim() ?? '';
    if (selectedId.isNotEmpty) {
      for (final OrderCheckoutLocation location in locations) {
        if (location.id == selectedId) return location;
      }
    }
    for (final OrderCheckoutLocation location in locations) {
      if (location.isDefault) return location;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
        requiresShippingLocation,
        selectedShippingLocationId,
        locations,
      ];
}
