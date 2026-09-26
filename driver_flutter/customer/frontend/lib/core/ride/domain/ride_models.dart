import '../../pricing/domain/quote_models.dart';

enum RideStatus {
  requested,
  searching,
  driverAssigned,
  driverEnRoute,
  driverArrived,
  rideStarted,
  rideInProgress,
  rideCompleted,
  cancelled,
  noDriver,
  failed,
}

RideStatus _statusFromString(String status) {
  switch (status) {
    case 'REQUESTED': return RideStatus.requested;
    case 'SEARCHING': return RideStatus.searching;
    case 'DRIVER_ASSIGNED': return RideStatus.driverAssigned;
    case 'DRIVER_EN_ROUTE': return RideStatus.driverEnRoute;
    case 'DRIVER_ARRIVED': return RideStatus.driverArrived;
    case 'RIDE_STARTED': return RideStatus.rideStarted;
    case 'RIDE_IN_PROGRESS': return RideStatus.rideInProgress;
    case 'RIDE_COMPLETED': return RideStatus.rideCompleted;
    case 'CANCELLED': return RideStatus.cancelled;
    case 'NO_DRIVER': return RideStatus.noDriver;
    default: return RideStatus.failed;
  }
}

class Ride {
  final String rideId;
  final String customerId;
  final RideStatus status;
  final Quote quoteSnapshot;
  final String pickupAddress;
  final String dropoffAddress;
  final String paymentMethod;
  final String specialInstructions;
  final String otpCode;
  final String? driverName;
  final String? driverPhone;
  final String? driverVehicle;
  final String? driverPlate;
  final double driverRating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cancellationReason;

  const Ride({
    required this.rideId,
    required this.customerId,
    required this.status,
    required this.quoteSnapshot,
    this.pickupAddress = 'Sector 63, Noida (GPS Fixed)',
    this.dropoffAddress = 'Terminal 3, IGI Airport, New Delhi',
    this.paymentMethod = 'Google Pay',
    this.specialInstructions = '',
    this.otpCode = '4829',
    this.driverName,
    this.driverPhone,
    this.driverVehicle,
    this.driverPlate,
    this.driverRating = 4.9,
    required this.createdAt,
    required this.updatedAt,
    this.cancellationReason,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    final driver = json['driverInfo'] as Map<String, dynamic>?;
    return Ride(
      rideId: json['rideId'] as String,
      customerId: json['customerId'] as String,
      status: _statusFromString(json['status'] as String),
      quoteSnapshot: Quote.fromJson(json['quoteSnapshot'] as Map<String, dynamic>),
      pickupAddress: json['pickupAddress'] as String? ?? 'Sector 63, Noida (GPS Fixed)',
      dropoffAddress: json['dropoffAddress'] as String? ?? 'Terminal 3, IGI Airport, New Delhi',
      paymentMethod: json['paymentMethod'] as String? ?? 'Google Pay',
      specialInstructions: json['specialInstructions'] as String? ?? '',
      otpCode: json['otpCode'] as String? ?? '4829',
      driverName: driver?['name'] as String? ?? json['driverName'] as String?,
      driverPhone: driver?['phone'] as String? ?? json['driverPhone'] as String?,
      driverVehicle: driver?['vehicle'] as String? ?? json['driverVehicle'] as String?,
      driverPlate: driver?['plateNumber'] as String? ?? json['driverPlate'] as String?,
      driverRating: (driver?['rating'] as num?)?.toDouble() ?? (json['driverRating'] as num?)?.toDouble() ?? 4.9,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      cancellationReason: json['cancellationReason'] as String?,
    );
  }
}
