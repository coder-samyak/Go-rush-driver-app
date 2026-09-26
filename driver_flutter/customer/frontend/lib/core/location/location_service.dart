import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'domain/location_models.dart';

abstract class LocationService {
  Future<LocationPoint> getCurrentPosition();
  Stream<LocationPoint> getLocationStream();
  Future<LocationPermissionState> checkPermission();
  Future<LocationPermissionState> requestPermission();
  void stopStream();
}

class LocationServiceImpl implements LocationService {
  StreamSubscription<Position>? _positionStream;
  final StreamController<LocationPoint> _locationController = StreamController<LocationPoint>.broadcast();

  @override
  Future<LocationPermissionState> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionState.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LocationPermissionState> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LocationPoint> getCurrentPosition() async {
    final state = await checkPermission();
    if (state != LocationPermissionState.granted) {
      throw Exception('Location permission not granted or service disabled');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    return _mapPosition(position);
  }

  @override
  Stream<LocationPoint> getLocationStream() {
    if (_positionStream != null) {
      return _locationController.stream;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _locationController.add(_mapPosition(position));
    }, onError: (e) {
      _locationController.addError(e);
    });

    return _locationController.stream;
  }

  @override
  void stopStream() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  LocationPermissionState _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return LocationPermissionState.denied;
      case LocationPermission.deniedForever:
        return LocationPermissionState.permanentlyDenied;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationPermissionState.granted;
      case LocationPermission.unableToDetermine:
        return LocationPermissionState.notDetermined;
    }
  }

  LocationPoint _mapPosition(Position position) {
    return LocationPoint(
      coordinate: GeoCoordinate(latitude: position.latitude, longitude: position.longitude),
      accuracy: position.accuracy,
      altitude: position.altitude,
      heading: position.heading,
      speed: position.speed,
      timestamp: position.timestamp,
    );
  }
}
