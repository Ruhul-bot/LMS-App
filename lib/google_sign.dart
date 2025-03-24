import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper class for Google Sign-In configuration
///
/// This class provides a centralized way to initialize the GoogleSignIn instance
/// with the appropriate configuration for both web and mobile platforms.
class GoogleSignInHelper {
  // Initialize Google Sign In with the correct client ID for web
  static GoogleSignIn get instance {
    if (kIsWeb) {
      // For web platform, provide the client ID
      // You need to get this from Google Cloud Console:
      // 1. Go to https://console.cloud.google.com/
      // 2. Select your project
      // 3. Navigate to "APIs & Services" > "Credentials"
      // 4. Look for "Web client (auto created by Google Service)" or create a new OAuth client ID for Web application
      // 5. Copy the client ID
      return GoogleSignIn(
        clientId:
            '181705743814-smacbcspn69719fcfp3k3n9rcnq3i7r5.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else {
      // For mobile platforms, no need to specify client ID
      return GoogleSignIn(scopes: ['email', 'profile']);
    }
  }
}
