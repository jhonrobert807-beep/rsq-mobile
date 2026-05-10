class DriverProfileModel {
  final String id;
  final String userId;
  final String? licenseNumber;
  final int? experienceYears;
  final String status;
  final String? notes;
  final DateTime? verifiedAt;

  DriverProfileModel({
    required this.id,
    required this.userId,
    this.licenseNumber,
    this.experienceYears,
    required this.status,
    this.notes,
    this.verifiedAt,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) => DriverProfileModel(
        id: json['id'],
        userId: json['userId'],
        licenseNumber: json['licenseNumber'],
        experienceYears: json['experienceYears'],
        status: json['status'] ?? 'PENDING',
        notes: json['notes'],
        verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      );
}
