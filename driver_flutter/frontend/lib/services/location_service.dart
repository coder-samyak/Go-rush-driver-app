import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Small device-location boundary: permissions stay explicit and no location is
/// collected until a driver is on an active ride or triggers SOS.
class LocationService {
  static final LocationService instance = LocationService._();
  LocationService._();

  Future<Position?> currentPosition() async {
    if (!await _ensurePermission()) return null;
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Stream<Position> activeRidePositions() async* {
    if (!await _ensurePermission()) return;
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      ),
    );
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
