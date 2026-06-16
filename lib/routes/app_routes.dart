import 'package:flutter/material.dart';
import 'package:resqlink_mobile/screens/SelectVehicleScreen.dart';
import 'package:resqlink_mobile/screens/booking_history_screen.dart';
import 'package:resqlink_mobile/screens/chat_screen.dart';
import 'package:resqlink_mobile/screens/driver/driver_alert_screen.dart';
import 'package:resqlink_mobile/screens/driver/driver_home_screen.dart';
import 'package:resqlink_mobile/screens/driver/driver_profile_screen.dart';
import 'package:resqlink_mobile/screens/driver/driver_ride_screen.dart';
import 'package:resqlink_mobile/screens/driver/edit_driver_profile_screen.dart';
import 'package:resqlink_mobile/screens/driver/rider_notifications_screen.dart';
import 'package:resqlink_mobile/screens/edit_profile_screen.dart';
import 'package:resqlink_mobile/screens/fare_selection_screen.dart';
import 'package:resqlink_mobile/screens/home_screen.dart';
import 'package:resqlink_mobile/screens/language_selection_screen.dart';
import 'package:resqlink_mobile/screens/notifications_screen.dart';
import 'package:resqlink_mobile/screens/paramedic/edit_para_profile_screen.dart';
import 'package:resqlink_mobile/screens/paramedic/paramedi_notifications_screen.dart';
import 'package:resqlink_mobile/screens/paramedic/paramedic_alert_screen.dart';
import 'package:resqlink_mobile/screens/paramedic/paramedic_home_screen.dart';
import 'package:resqlink_mobile/screens/paramedic/paramedic_profile_screen.dart';
import 'package:resqlink_mobile/screens/payment/add_card_screen.dart';
import 'package:resqlink_mobile/screens/payment/card_flow_screen.dart';
import 'package:resqlink_mobile/screens/privacy_policy_screen.dart';
import 'package:resqlink_mobile/screens/select_payment_method_screen.dart';
import 'package:resqlink_mobile/screens/select_route_screen.dart';
import 'package:resqlink_mobile/screens/splash_screen.dart';
import 'package:resqlink_mobile/screens/user_profile_screen.dart';
import 'package:resqlink_mobile/screens/user_ride_details_sceen.dart';
import 'package:resqlink_mobile/screens/vehical_edit_profile_screen.dart';
import 'package:resqlink_mobile/screens/welcome_screen.dart';
import 'package:resqlink_mobile/screens/login_screen.dart';
import 'package:resqlink_mobile/screens/signup_screen.dart';
import 'package:resqlink_mobile/screens/send_verification_screen.dart';
import 'package:resqlink_mobile/screens/verify_otp_screen.dart';
import 'package:resqlink_mobile/screens/set_password_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String selectRoute = '/select_route';
  static const String selectVehicle = '/select_vehicle';
  static const String fareSelection = '/fare_selection';
  static const String paymentMethodScreen = '/payment_method_screen';
  static const String userRideDetails = '/user_ride_details';
  static const String userProfile = '/user_profile';
  static const String editProfile = '/edit_profile';
  static const String editVehicleProfile = '/edit_vehicle_profile';
  static const String notificationsSetting = '/notifications';
  static const String ridernotificationsSetting = '/rider_notifications';
  static const String paramedicnotificationsSetting = '/paramedic_notifications';
  static const String languageSelection = '/language_selection';
  static const String privacyPolicy = '/privacy_policy';
  static const String bookingHistoryScreen = '/booking_history';
  static const String addCardScreen = '/add_card_screen';
  static const String cardFlowScreen = '/card_flow_screen';
  static const String chatScreen = '/chat_screen';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String sendVerification = '/send_verification';
  static const String verifyOtp = '/verify_otp';
  static const String setPassword = '/set_password';

  static const String editProfileDriver = '/edit_profile_driver';
  static const String driverAlertScreen = '/driver_alert_screen';
  static const String driverHomeScreen = '/driver_home_screen';
  static const String driverProfileScreen = '/driver_profile_screen';
  static const String driverRideScreen = '/driver_ride_screen';

  static const String editParamedicProfileScreen = '/edit_paramedic_profile';
  static const String paramedicAlertScreen = '/paramedic_alert_screen';
  static const String paramedicHomeScreen = '/paramedic_home_screen';
  static const String paramedicProfileScreen = '/paramedic_profile_screen';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      welcome: (context) => const WelcomeScreen(),
      home: (context) => HomeScreen(),
      selectRoute: (context) => const SelectRouteScreen(),
      selectVehicle: (context) => const SelectVehicleScreen(),
      fareSelection: (context) => const FareSelectionScreen(),
      paymentMethodScreen: (context) => const SelectPaymentMethodScreen(),
      userRideDetails: (context) => const UserRideDetailsScreen(),
      userProfile: (context) => const UserProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      editVehicleProfile: (context) => const VehicleProfileEditScreen(),
      notificationsSetting: (context) => const NotificationsSettingsScreen(),
      ridernotificationsSetting: (context) => const RDNotificationsSettingsScreen(),
      paramedicnotificationsSetting: (context) => const PMNotificationsSettingsScreen(),
      languageSelection: (context) => const LanguageSelectionScreen(),
      privacyPolicy: (context) => const PrivacyPolicyScreen(),
      bookingHistoryScreen: (context) => const BookingHistoryScreen(),
      addCardScreen: (context) => const AddCardScreen(),
      cardFlowScreen: (context) => const CardFlowScreen(),
      chatScreen: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return ChatScreen(
          rideRequestId: args?['rideRequestId'] ?? 'default',
          recipientId: args?['recipientId'] ?? 'unknown',
          recipientName: args?['recipientName'] ?? 'User',
        );
      },
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      sendVerification: (context) => const SendVerificationScreen(),
      verifyOtp: (context) => const VerifyOtpScreen(),
      setPassword: (context) => const SetPasswordScreen(),

      editProfileDriver: (context) => const EditDriverProfileScreen(),
      driverAlertScreen: (context) => const DriverAlertScreen(),
      driverHomeScreen: (context) => const DriverHomeScreen(),
      driverProfileScreen: (context) => const DriverProfileScreen(),
      driverRideScreen: (context) => const DriverRideScreen(),

      editParamedicProfileScreen: (context) =>
          const EditParamedicProfileScreen(),
      paramedicAlertScreen: (context) => const ParamedicAlertScreen(),
      paramedicHomeScreen: (context) => const ParamedicHomeScreen(),
      paramedicProfileScreen: (context) => const ParamedicProfileScreen(),
    };
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: const Center(child: Text('404 - Page Not Found')),
      ),
    );
  }
}
