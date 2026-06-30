class ApiConstants {
  // Toggle this to switch between local and production
  static const bool useProduction = true;

  static const String _localBase = 'http://localhost:3001';
  static const String _prodBase = 'https://gleaming-inspiration-production-64dc.up.railway.app';

  static String get baseUrl => (useProduction ? _prodBase : _localBase) + '/api';
  static String get socketUrl => useProduction ? _prodBase : _localBase;

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/profile';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String googleLogin = '/auth/google-login';

  // Users
  static const String users = '/users';

  // Ride Requests
  static const String rideRequests = '/ride-requests';
  static const String myRides = '/ride-requests/my-rides';
  static const String driverRides = '/ride-requests/driver-rides';

  // Dispatch
  static const String dispatch = '/dispatch';
  static const String nearest = '/dispatch/nearest';
  static const String distance = '/dispatch/distance';

  // Tracking
  static const String trackingUpdate = '/tracking/update';
  static const String trackingLive = '/tracking/live';

  // Chat
  static const String chats = '/chats';

  // Driver Profiles
  static const String driverProfiles = '/driver-profiles';

  // Paramedic Profiles
  static const String paramedicProfiles = '/paramedic-profiles';
}
