import 'package:geolocator/geolocator.dart';

abstract class LocationPermissionService {
  Future<void> requestWhileInUse();

  Future<void> requestAlways();
}

class GeolocatorLocationPermissionService implements LocationPermissionService {
  const GeolocatorLocationPermissionService();

  @override
  Future<void> requestWhileInUse() async {
    await Geolocator.requestPermission();
  }

  @override
  Future<void> requestAlways() async {
    await Geolocator.requestPermission();
    final LocationPermission current = await Geolocator.checkPermission();
    if (current == LocationPermission.whileInUse) {
      await Geolocator.requestPermission();
    }
  }
}