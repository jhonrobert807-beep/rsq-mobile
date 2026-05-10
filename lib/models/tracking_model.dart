class TrackingModel {
  final String id;
  final String ambulanceId;
  final String? rideRequestId;
  final double lat;
  final double lng;
  final DateTime recordedAt;

  TrackingModel({
    required this.id,
    required this.ambulanceId,
    this.rideRequestId,
    required this.lat,
    required this.lng,
    required this.recordedAt,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) => TrackingModel(
        id: json['id'],
        ambulanceId: json['ambulanceId'],
        rideRequestId: json['rideRequestId'],
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        recordedAt: DateTime.parse(json['recordedAt']),
      );
}
