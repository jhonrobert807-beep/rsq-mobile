class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final bool verified;
  final bool isActive;
  final double? locationLat;
  final double? locationLng;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    required this.verified,
    required this.isActive,
    this.locationLat,
    this.locationLng,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        role: json['role'] ?? 'USER',
        verified: json['verified'] ?? false,
        isActive: json['isActive'] ?? true,
        locationLat: (json['locationLat'] as num?)?.toDouble(),
        locationLng: (json['locationLng'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'verified': verified,
        'isActive': isActive,
        'locationLat': locationLat,
        'locationLng': locationLng,
      };

  String get displayName => name;
  String get displayContact => email ?? phone ?? '';
}
