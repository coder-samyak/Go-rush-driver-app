enum LocationPermissionState {
  notDetermined,
  granted,
  denied,
  permanentlyDenied,
  restricted,
  serviceDisabled,
  unavailable
}

enum LocationStatus {
  fresh,
  stale,
  unavailable
}

class GeoCoordinate {
  final double latitude;
  final double longitude;

  const GeoCoordinate({
    required this.latitude,
    required this.longitude,
  }) : assert(latitude >= -90 && latitude <= 90, 'Latitude must be between -90 and 90'),
       assert(longitude >= -180 && longitude <= 180, 'Longitude must be between -180 and 180');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoCoordinate && other.latitude == latitude && other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => 'GeoCoordinate(lat: $latitude, lng: $longitude)';
}

class LocationPoint {
  final GeoCoordinate coordinate;
  final double accuracy;
  final double altitude;
  final double heading;
  final double speed;
  final DateTime timestamp;

  const LocationPoint({
    required this.coordinate,
    required this.accuracy,
    required this.altitude,
    required this.heading,
    required this.speed,
    required this.timestamp,
  });

  LocationStatus get status {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inSeconds < 30) return LocationStatus.fresh;
    return LocationStatus.stale;
  }
}
