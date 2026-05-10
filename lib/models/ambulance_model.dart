class AmbulanceModel {
  final String id;
  final String? registrationNumber;
  final String type;
  final String status;
  final double? currentLat;
  final double? currentLng;
  final double? distanceKm;
  final int? etaMinutes;

  AmbulanceModel({
    required this.id,
    this.registrationNumber,
    required this.type,
    required this.status,
    this.currentLat,
    this.currentLng,
    this.distanceKm,
    this.etaMinutes,
  });

  factory AmbulanceModel.fromJson(Map<String, dynamic> json) => AmbulanceModel(
        id: json['id'],
        registrationNumber: json['registrationNumber'],
        type: json['type'],
        status: json['status'],
        currentLat: (json['currentLat'] as num?)?.toDouble(),
        currentLng: (json['currentLng'] as num?)?.toDouble(),
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        etaMinutes: json['etaMinutes'],
      );

  String get displayEta => etaMinutes != null ? '$etaMinutes min' : '--';
  String get displayDistance => distanceKm != null ? '${distanceKm!.toStringAsFixed(1)} km' : '--';
  String get pricePerKm => type == 'WITH_DOCTOR' ? 'PKR 100/km' : 'PKR 50/km';
  int get baseFare => type == 'WITH_DOCTOR' ? 500 : 200;
}
