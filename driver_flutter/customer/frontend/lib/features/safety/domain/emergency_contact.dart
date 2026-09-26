class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relationship = 'Family',
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String? ?? 'ec_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Emergency Contact',
      phone: json['phone'] as String? ?? '',
      relationship: json['relationship'] as String? ?? 'Family',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }
}
