class DriverLocation {
  final String driverId;
  final String rideId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? heading;
  final DateTime timestamp;
  final int sequenceNumber;

  const DriverLocation({
    required this.driverId,
    required this.rideId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.heading,
    required this.timestamp,
    required this.sequenceNumber,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      driverId: json['driverId'] as String,
      rideId: json['rideId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      heading: json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      sequenceNumber: json['sequenceNumber'] as int,
    );
  }
}
