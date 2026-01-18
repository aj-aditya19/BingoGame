// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// final FirebaseAuth _auth = FirebaseAuth.instance;

// Future<UserCredential?> signInWithGoogle() async {
//   try {
//     // Trigger Google Sign-In
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//     if (googleUser == null) return null; // User canceled the login

//     // Get authentication object
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser.authentication;

//     // Create Firebase credential
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken, // ✅ This is the token your backend expects
//     );

//     // Sign in with Firebase
//     final userCredential = await FirebaseAuth.instance.signInWithCredential(
//       credential,
//     );
//     return userCredential;
//   } catch (e) {
//     print("Google Sign-In error: $e");
//     return null;
//   }
// }

// class FirebaseService {
//   static Future<UserCredential?> signInWithGoogle() async {
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     if (googleUser == null) return null;

//     final GoogleSignInAuthentication googleAuth =
//         await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     return await _auth.signInWithCredential(credential);
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Google Sign-In
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("Google Sign-In error: $e");
      return null;
    }
  }

  /// Optional: Get Firebase ID token to send to backend
  static Future<String?> getFirebaseToken(User user) async {
    return await user.getIdToken();
  }
}
