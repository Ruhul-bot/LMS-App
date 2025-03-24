// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../models/user_model.dart';
// import '../google_sign.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignInHelper.instance;

//   // Get current user
//   User? get currentUser => _auth.currentUser;

//   // Auth state changes stream
//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   // Sign in with email and password
//   Future<UserCredential> signInWithEmailAndPassword(
//     String email,
//     String password,
//   ) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Update last login timestamp
//       await _firestore.collection('users').doc(userCredential.user!.uid).update(
//         {'lastLogin': FieldValue.serverTimestamp()},
//       );

//       return userCredential;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Register with email and password
//   Future<UserCredential> registerWithEmailAndPassword(
//     String email,
//     String password,
//     String displayName,
//   ) async {
//     try {
//       UserCredential userCredential = await _auth
//           .createUserWithEmailAndPassword(email: email, password: password);

//       // Update user profile
//       await userCredential.user!.updateDisplayName(displayName);

//       // Create user document in Firestore
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'uid': userCredential.user!.uid,
//         'email': email,
//         'displayName': displayName,
//         'photoUrl': null,
//         'enrolledCourses': [],
//         'createdAt': FieldValue.serverTimestamp(),
//         'lastLogin': FieldValue.serverTimestamp(),
//       });

//       return userCredential;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Sign in with Google
//   Future<UserCredential> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       if (googleUser == null) {
//         throw FirebaseAuthException(
//           code: 'ERROR_ABORTED_BY_USER',
//           message: 'Sign in aborted by user',
//         );
//       }

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       UserCredential userCredential = await _auth.signInWithCredential(
//         credential,
//       );

//       // Check if this is a new user
//       bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

//       if (isNewUser) {
//         // Create user document in Firestore for new users
//         await _firestore.collection('users').doc(userCredential.user!.uid).set({
//           'uid': userCredential.user!.uid,
//           'email': userCredential.user!.email,
//           'displayName': userCredential.user!.displayName,
//           'photoUrl': userCredential.user!.photoURL,
//           'enrolledCourses': [],
//           'createdAt': FieldValue.serverTimestamp(),
//           'lastLogin': FieldValue.serverTimestamp(),
//         });
//       } else {
//         // Update last login timestamp for existing users
//         await _firestore
//             .collection('users')
//             .doc(userCredential.user!.uid)
//             .update({'lastLogin': FieldValue.serverTimestamp()});
//       }

//       return userCredential;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }

//   // Get user data from Firestore
//   Future<UserModel?> getUserData(String uid) async {
//     try {
//       DocumentSnapshot doc =
//           await _firestore.collection('users').doc(uid).get();

// print('User document not found for UID: $uid');
//       if (doc.exists) {
//         return UserModel.fromMap(doc.data() as Map<String, dynamic>);
//       }

//       return null;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Reset password
//   Future<void> resetPassword(String email) async {
//     await _auth.sendPasswordResetEmail(email: email);
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../google_sign.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignInHelper.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login timestamp
      await _firestore.collection('users').doc(userCredential.user!.uid).update(
        {'lastLogin': FieldValue.serverTimestamp()},
      );

      return userCredential;
    } catch (e) {
      print("Error in signInWithEmailAndPassword: $e");
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update user profile
      await userCredential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': null,
        'enrolledCourses': [],
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      print("Error in registerWithEmailAndPassword: $e");
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Check if this is a new user
      bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Create user document in Firestore for new users
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoUrl': userCredential.user!.photoURL,
          'enrolledCourses': [],
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // Update last login timestamp for existing users
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLogin': FieldValue.serverTimestamp()});
      }

      return userCredential;
    } catch (e) {
      print("Error in signInWithGoogle: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Error in signOut: $e");
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      print("Fetching user data for UID1: $uid");
      print("mind blown");
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      print(
        "doc.exists:--------------------- ${doc.exists}----------------------------",
      );
      if (doc.exists) {
        print("Document exists for user: $uid");
        if (doc.data() != null) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          print("Document exists but data is null for user: $uid");
          return null;
        }
      } else {
        print("User document not found for UID: $uid");
        return null;
      }
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        print('You are offline. Please check your internet connection.');
        // Optionally, show a user-friendly message in the UI
      }
    } catch (e) {
      print("Error getting user data: $e");
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("Error in resetPassword: $e");
      rethrow;
    }
  }
}
