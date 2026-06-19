// lib/services/google_auth_service.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  // ⚠️⚠️⚠️ TODO: استبدل القيمة التالية بـ Web Client ID الخاص بك من
  // Google Cloud Console (Credentials > OAuth 2.0 Client IDs > Web client)
  // بدون هذا، idToken سيكون null دائماً على أندرويد ولن يعمل تسجيل الدخول.
  static const String _webClientId =
      'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: _webClientId,
  );

  // ✅ تسجيل الدخول عبر Google
  static Future<AuthResponse?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('❌ Google Sign-In cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        debugPrint(
          '❌ Google Sign-In failed: No ID token. '
          'تأكد من ضبط serverClientId (Web Client ID) بشكل صحيح.',
        );
        return null;
      }

      final AuthResponse response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      debugPrint('✅ Google Sign-In successful: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      return null;
    }
  }

  // ✅ تسجيل الخروج من Google
  static Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ Google Sign-Out successful');
    } catch (e) {
      debugPrint('❌ Google Sign-Out error: $e');
    }
  }

  // ✅ التحقق من حالة تسجيل الدخول
  static Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  // ✅ الحصول على معلومات المستخدم
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return await _googleSignIn.currentUser;
    } catch (e) {
      return null;
    }
  }
}