class InsurancePolicy {
  final String insurerName;
  final String policyNumber;
  final String uin;
  final DateTime? policyStartDate;
  final DateTime? policyEndDate;
  final String status;
  final Map<String, dynamic> coverage;
  final List<String> exclusions;
  final List<String> claimDocuments;
  final String? policyDocumentUrl;
  final String? certificateUrl;
  final String? termsUrl;

  const InsurancePolicy({
    this.insurerName = '',
    this.policyNumber = '',
    this.uin = '',
    this.policyStartDate,
    this.policyEndDate,
    this.status = 'PENDING',
    this.coverage = const {},
    this.exclusions = const [],
    this.claimDocuments = const [],
    this.policyDocumentUrl,
    this.certificateUrl,
    this.termsUrl,
  });

  factory InsurancePolicy.fromJson(Map<String, dynamic> json) {
    DateTime? date(dynamic value) =>
        value == null ? null : DateTime.tryParse(value.toString());
    final rawCoverage = json['coverage'];
    return InsurancePolicy(
      insurerName: json['insurerName']?.toString() ?? '',
      policyNumber: json['policyNumber']?.toString() ?? '',
      uin: json['uin']?.toString() ?? '',
      policyStartDate: date(json['policyStartDate']),
      policyEndDate: date(json['policyEndDate']),
      status: json['status']?.toString() ?? 'PENDING',
      coverage: rawCoverage is Map
          ? Map<String, dynamic>.from(rawCoverage)
          : const {},
      exclusions: _strings(json['exclusions']),
      claimDocuments: _strings(json['claimDocuments']),
      policyDocumentUrl: json['policyDocumentUrl']?.toString(),
      certificateUrl: json['certificateUrl']?.toString(),
      termsUrl: json['termsUrl']?.toString(),
    );
  }
}

class InsuranceClaim {
  final String id;
  final String claimNumber;
  final String rideId;
  final String claimType;
  final String status;
  final DateTime? incidentDate;
  final String incidentLocation;
  final String description;
  final num? requestedAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InsuranceClaim({
    this.id = '',
    this.claimNumber = '',
    this.rideId = '',
    this.claimType = '',
    this.status = 'SUBMITTED',
    this.incidentDate,
    this.incidentLocation = '',
    this.description = '',
    this.requestedAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory InsuranceClaim.fromJson(Map<String, dynamic> json) {
    DateTime? date(dynamic value) =>
        value == null ? null : DateTime.tryParse(value.toString());
    return InsuranceClaim(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      claimNumber: json['claimNumber']?.toString() ?? '',
      rideId: json['rideId']?.toString() ?? '',
      claimType: json['claimType']?.toString() ?? '',
      status: json['status']?.toString() ?? 'SUBMITTED',
      incidentDate: date(json['incidentDate']),
      incidentLocation: json['incidentLocation']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      requestedAmount: json['requestedAmount'] as num?,
      createdAt: date(json['createdAt']),
      updatedAt: date(json['updatedAt']),
    );
  }
}

List<String> _strings(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString())
      .where((item) => item.isNotEmpty)
      .toList();
}
