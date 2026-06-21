import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '69448074236-1b05qm623tinea2gotrh5qgjt7kb5n0i.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      print('Error signing in with Google: $error');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  /// Returns idToken on mobile, accessToken on web (idToken unavailable on web).
  static Future<({String token, bool isAccessToken})?> getToken() async {
    try {
      final account = _googleSignIn.currentUser;
      if (account == null) return null;
      final auth = await account.authentication;
      if (!kIsWeb && auth.idToken != null) {
        return (token: auth.idToken!, isAccessToken: false);
      }
      if (auth.accessToken != null) {
        return (token: auth.accessToken!, isAccessToken: true);
      }
      return null;
    } catch (error) {
      print('Error getting Google token: $error');
      return null;
    }
  }

  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
