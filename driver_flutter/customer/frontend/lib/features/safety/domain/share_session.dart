enum RideShareStatus {
  pending,
  active,
  revoked,
  expired,
  completed
}

class RideShareSession {
  final String id;
  final String recipientName;
  final RideShareStatus status;
  final DateTime expiresAt;

  RideShareSession({
    required this.id,
    required this.recipientName,
    required this.status,
    required this.expiresAt,
  });
}
