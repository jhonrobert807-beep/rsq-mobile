import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
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

  static Future<String?> getIdToken() async {
    try {
      final account = _googleSignIn.currentUser;
      if (account == null) {
        return null;
      }
      final auth = await account.authentication;
      return auth.idToken;
    } catch (error) {
      print('Error getting ID token: $error');
      return null;
    }
  }

  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
}
