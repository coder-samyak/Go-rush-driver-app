/// GoRush Driver Partner Models & State Enums

enum VehicleCategory {
  bike,
  auto,
  cabMini,
  cabSedan,
  premium,
  ev,
}

enum DriverVerificationStatus {
  pending,
  approved,
  rejected,
  suspended,
}

class DispatchOffer {
  final String id;
  final String rideId;
  final String driverId;
  final double estimatedEarnings;
  final int pickupDistanceMeters;
  final int pickupEtaSeconds;
  final String pickupAddress;
  final String dropAddress;
  final String category;
  final DateTime expiresAt;
  final String status;

  DispatchOffer({
    required this.id,
    required this.rideId,
    required this.driverId,
    required this.estimatedEarnings,
    required this.pickupDistanceMeters,
    required this.pickupEtaSeconds,
    required this.pickupAddress,
    required this.dropAddress,
    required this.category,
    required this.expiresAt,
    required this.status,
  });

  factory DispatchOffer.fromJson(Map<String, dynamic> json) {
    return DispatchOffer(
      id: json['id'] ?? '',
      rideId: json['rideId'] ?? '',
      driverId: json['driverId'] ?? '',
      estimatedEarnings: (json['estimatedEarnings'] as num?)?.toDouble() ?? 0.0,
      pickupDistanceMeters: json['pickupDistanceMeters'] ?? 0,
      pickupEtaSeconds: json['pickupEtaSeconds'] ?? 0,
      pickupAddress: json['pickupAddress'] ?? '',
      dropAddress: json['dropAddress'] ?? '',
      category: json['category'] ?? 'AUTO',
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(seconds: 15)),
      status: json['status'] ?? 'PENDING',
    );
  }
}

class DriverProfile {
  final String id;
  final String name;
  final String phone;
  final String category;
  final String vehiclePlate;
  final String vehicleModel;
  final DriverVerificationStatus verificationStatus;
  final bool online;
  final double rating;
  final int totalTrips;

  DriverProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.category,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.verificationStatus,
    required this.online,
    required this.rating,
    required this.totalTrips,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    DriverVerificationStatus status = DriverVerificationStatus.approved;
    final st = json['verificationStatus'];
    if (st == 'PENDING') status = DriverVerificationStatus.pending;
    if (st == 'REJECTED') status = DriverVerificationStatus.rejected;
    if (st == 'SUSPENDED') status = DriverVerificationStatus.suspended;

    return DriverProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Driver Partner',
      phone: json['phone'] ?? '',
      category: json['category'] ?? 'AUTO',
      vehiclePlate: json['vehiclePlate'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      verificationStatus: status,
      online: json['online'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: json['totalTrips'] ?? 0,
    );
  }
}
