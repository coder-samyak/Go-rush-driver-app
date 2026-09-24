/// GoRush Driver App - Core Ride & Trip Model
/// Strongly-typed Dart model mirroring the MongoDB Atlas `rides` collection.
class RideModel {
  final String id;
  final String rideId;
  final String? driverId;
  final String status;

  // Passenger details
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final int passengerTotalRides;
  final String passengerAvatar;
  final String vehicleTier;

  // Route details
  final String pickupAddress;
  final String pickupArea;
  final String pickupDistanceAway;
  final double pickupLat;
  final double pickupLng;

  final String destinationAddress;
  final String destinationArea;
  final double destinationLat;
  final double destinationLng;

  // Metrics & Security
  final double distanceKm;
  final int durationMin;
  final String otp;

  // Fare Breakdown
  final double baseFare;
  final double distanceFare;
  final double taxes;
  final double totalFare;
  final double driverEarnings;
  final String paymentMethod;
  final bool isPaid;

  // Timestamps
  final DateTime? requestedAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  const RideModel({
    required this.id,
    required this.rideId,
    this.driverId,
    required this.status,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.passengerTotalRides,
    required this.passengerAvatar,
    required this.vehicleTier,
    required this.pickupAddress,
    required this.pickupArea,
    required this.pickupDistanceAway,
    required this.pickupLat,
    required this.pickupLng,
    required this.destinationAddress,
    required this.destinationArea,
    required this.destinationLat,
    required this.destinationLng,
    required this.distanceKm,
    required this.durationMin,
    required this.otp,
    required this.baseFare,
    required this.distanceFare,
    required this.taxes,
    required this.totalFare,
    required this.driverEarnings,
    required this.paymentMethod,
    this.isPaid = false,
    this.requestedAt,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  bool get isRequested => status == 'requested';
  bool get isAccepted => status == 'accepted';
  bool get isArrived => status == 'arrived';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  RideModel copyWith({String? status, DateTime? acceptedAt}) {
    return RideModel(
      id: id,
      rideId: rideId,
      driverId: driverId,
      status: status ?? this.status,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      passengerRating: passengerRating,
      passengerTotalRides: passengerTotalRides,
      passengerAvatar: passengerAvatar,
      vehicleTier: vehicleTier,
      pickupAddress: pickupAddress,
      pickupArea: pickupArea,
      pickupDistanceAway: pickupDistanceAway,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      destinationAddress: destinationAddress,
      destinationArea: destinationArea,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      distanceKm: distanceKm,
      durationMin: durationMin,
      otp: otp,
      baseFare: baseFare,
      distanceFare: distanceFare,
      taxes: taxes,
      totalFare: totalFare,
      driverEarnings: driverEarnings,
      paymentMethod: paymentMethod,
      isPaid: isPaid,
      requestedAt: requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      arrivedAt: arrivedAt,
      startedAt: startedAt,
      completedAt: completedAt,
      cancelledAt: cancelledAt,
      cancellationReason: cancellationReason,
    );
  }

  factory RideModel.fromJson(Map<String, dynamic> json) {
    final passenger = json['passenger'] as Map<String, dynamic>? ?? {};
    final pickup = json['pickup'] as Map<String, dynamic>? ?? {};
    final destination = json['destination'] as Map<String, dynamic>? ?? {};
    final fare = json['fare'] as Map<String, dynamic>? ?? {};

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return RideModel(
      id: (json['_id'] ?? json['id'] ?? json['rideId'] ?? '').toString(),
      rideId: (json['rideId'] ?? json['_id'] ?? 'GR-000000').toString(),
      driverId: json['driverId']?.toString(),
      status: (json['status'] ?? 'requested').toString(),
      passengerName: (passenger['name'] ?? 'Priya Sharma').toString(),
      passengerPhone: (passenger['phone'] ?? '+91 98765 43210').toString(),
      passengerRating: (passenger['rating'] as num?)?.toDouble() ?? 4.8,
      passengerTotalRides: (passenger['totalRides'] as num?)?.toInt() ?? 120,
      passengerAvatar: (passenger['avatar'] ??
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150')
          .toString(),
      vehicleTier: (passenger['vehicleTier'] ?? 'Prime Sedan').toString(),
      pickupAddress: (pickup['address'] ?? 'Sector 62, Noida').toString(),
      pickupArea: (pickup['area'] ?? 'Sector 62').toString(),
      pickupDistanceAway: (pickup['distanceAway'] ?? '2.1 km away').toString(),
      pickupLat: (pickup['lat'] as num?)?.toDouble() ?? 28.6280,
      pickupLng: (pickup['lng'] as num?)?.toDouble() ?? 77.3649,
      destinationAddress:
          (destination['address'] ?? 'Connaught Place, New Delhi').toString(),
      destinationArea: (destination['area'] ?? 'Connaught Place').toString(),
      destinationLat: (destination['lat'] as num?)?.toDouble() ?? 28.6328,
      destinationLng: (destination['lng'] as num?)?.toDouble() ?? 77.2197,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 16.4,
      durationMin: (json['durationMin'] as num?)?.toInt() ?? 32,
      otp: (json['otp'] ?? '4892').toString(),
      baseFare: (fare['baseFare'] as num?)?.toDouble() ?? 200.0,
      distanceFare: (fare['distanceFare'] as num?)?.toDouble() ?? 110.0,
      taxes: (fare['taxes'] as num?)?.toDouble() ?? 52.0,
      totalFare: (fare['total'] as num?)?.toDouble() ?? 362.0,
      driverEarnings: (fare['driverEarnings'] as num?)?.toDouble() ?? 310.0,
      paymentMethod: (fare['paymentMethod'] ?? 'Cash / UPI').toString(),
      isPaid: fare['isPaid'] == true,
      requestedAt: parseDate(json['requestedAt']),
      acceptedAt: parseDate(json['acceptedAt']),
      arrivedAt: parseDate(json['arrivedAt']),
      startedAt: parseDate(json['startedAt']),
      completedAt: parseDate(json['completedAt']),
      cancelledAt: parseDate(json['cancelledAt']),
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  /// Default fallback mock ride representation matching approved UI
  factory RideModel.defaultSample() {
    return const RideModel(
      id: 'default_ride_sample',
      rideId: 'GR-108709',
      status: 'requested',
      passengerName: 'Priya Sharma',
      passengerPhone: '+91 98765 43210',
      passengerRating: 4.8,
      passengerTotalRides: 120,
      passengerAvatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      vehicleTier: 'Prime Sedan',
      pickupAddress: 'Sector 62, Noida',
      pickupArea: 'Sector 62',
      pickupDistanceAway: '2.1 km away',
      pickupLat: 28.6280,
      pickupLng: 77.3649,
      destinationAddress: 'Connaught Place, New Delhi',
      destinationArea: 'Connaught Place',
      destinationLat: 28.6328,
      destinationLng: 77.2197,
      distanceKm: 16.4,
      durationMin: 32,
      otp: '4892',
      baseFare: 200,
      distanceFare: 80,
      taxes: 40,
      totalFare: 320,
      driverEarnings: 282,
      paymentMethod: 'Cash / UPI',
    );
  }
}

/// Aggregated earnings representation
class DriverEarningsSummary {
  final double totalEarnings;
  final double todayEarnings;
  final int totalRides;
  final int completedRidesCount;

  const DriverEarningsSummary({
    this.totalEarnings = 23000.0,
    this.todayEarnings = 12400.0,
    this.totalRides = 18,
    this.completedRidesCount = 18,
  });

  factory DriverEarningsSummary.fromJson(Map<String, dynamic> json) {
    return DriverEarningsSummary(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 23000.0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 12400.0,
      totalRides: (json['totalRides'] as num?)?.toInt() ?? 18,
      completedRidesCount: (json['completedRidesCount'] as num?)?.toInt() ?? 18,
    );
  }
}
