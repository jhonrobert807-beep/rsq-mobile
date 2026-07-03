class RideRequestModel {
  final String id;
  final String userId;
  final String ambulanceType;
  final double pickupLat;
  final double pickupLng;
  final double? destinationLat;
  final double? destinationLng;
  final String status;
  final String? assignedDriverId;
  final String? driverName;
  final String? driverPhone;
  final String? assignedParamedicId;
  final String? paramedicName;
  final String? paramedicPhone;
  final String? patientName;
  final String? ambulanceId;
  final String? ambulanceRegistrationNumber;
  final double? cost;
  final String paymentStatus;
  final String paymentMethod;
  final double? userRating;
  final double? distanceKm;
  final int? etaMinutes;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  RideRequestModel({
    required this.id,
    required this.userId,
    required this.ambulanceType,
    required this.pickupLat,
    required this.pickupLng,
    this.destinationLat,
    this.destinationLng,
    required this.status,
    this.assignedDriverId,
    this.driverName,
    this.driverPhone,
    this.assignedParamedicId,
    this.paramedicName,
    this.paramedicPhone,
    this.patientName,
    this.ambulanceId,
    this.ambulanceRegistrationNumber,
    this.cost,
    required this.paymentStatus,
    required this.paymentMethod,
    this.userRating,
    this.distanceKm,
    this.etaMinutes,
    required this.requestedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory RideRequestModel.fromJson(Map<String, dynamic> json) => RideRequestModel(
        id: json['id'],
        userId: json['userId'],
        ambulanceType: json['ambulanceType'],
        pickupLat: (json['pickupLat'] as num).toDouble(),
        pickupLng: (json['pickupLng'] as num).toDouble(),
        destinationLat: (json['destinationLat'] as num?)?.toDouble(),
        destinationLng: (json['destinationLng'] as num?)?.toDouble(),
        status: json['status'],
        assignedDriverId: json['assignedDriverId'],
        driverName: json['assignedDriver']?['name'],
        driverPhone: json['assignedDriver']?['phone'],
        assignedParamedicId: json['assignedParamedicId'],
        paramedicName: json['assignedParamedic']?['name'],
        paramedicPhone: json['assignedParamedic']?['phone'],
        patientName: json['user']?['name'],
        ambulanceId: json['ambulanceId'],
        ambulanceRegistrationNumber: json['ambulance']?['registrationNumber'],
        cost: (json['cost'] as num?)?.toDouble(),
        paymentStatus: json['paymentStatus'] ?? 'PENDING',
        paymentMethod: json['paymentMethod'] ?? 'CASH',
        userRating: (json['userRating'] as num?)?.toDouble(),
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        etaMinutes: json['etaMinutes'],
        requestedAt: DateTime.parse(json['requestedAt']),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
        cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      );

  bool get isActive => ['CREATED', 'DISPATCHING', 'WAITING_DRIVER_ACCEPT', 'DRIVER_ACCEPTED', 'DRIVER_ARRIVED', 'IN_TRIP'].contains(status);
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isFailedNoDriver => status == 'FAILED_NO_DRIVER';

  String get formattedCost => cost != null ? 'PKR ${cost!.toStringAsFixed(0)}' : 'Calculating...';
  String get formattedEta => etaMinutes != null ? '$etaMinutes min' : '--';
}
