// import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/user_model.dart';
// import '../services/auth_service.dart';

// // Define AuthStatus enum
// enum AuthStatus { authenticated, unauthenticated, authenticating }

// class AuthProvider with ChangeNotifier {
//   final AuthService _authService = AuthService();

//   UserModel? _userModel;
//   bool _isLoading = false;
//   String? _errorMessage;
//   AuthStatus _status = AuthStatus.unauthenticated;

//   // Getters
//   UserModel? get userModel => _userModel;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   bool get isAuthenticated => _userModel != null;
//   AuthStatus get status => _status;

//   // Initialize auth state
//   Future<void> initializeAuthState() async {
//     _setLoading(true);
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       User? currentUser = _authService.currentUser;

//       if (currentUser != null) {
//         await _fetchUserData(currentUser.uid);
//         _status = AuthStatus.authenticated;
//       } else {
//         _status = AuthStatus.unauthenticated;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       _status = AuthStatus.unauthenticated;

//     } finally {
//       _setLoading(false);
//       notifyListeners();
//     }
//   }

//   // Sign in with email and password
//   Future<bool> signInWithEmailAndPassword(String email, String password) async {
//     _setLoading(true);
//     _clearError();
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       UserCredential userCredential = await _authService.signInWithEmailAndPassword(email, password);

//       await _fetchUserData(userCredential.user!.uid);
//       _status = AuthStatus.authenticated;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError(_getReadableErrorMessage(e));
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Register with email and password
//   Future<bool> registerWithEmailAndPassword(
//     String email,
//     String password,
//     String displayName,
//   ) async {
//     _setLoading(true);
//     _clearError();
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       print(
//         "------Registering user with email: $email,$password,$displayName ------ ",
//       );
//       UserCredential userCredential = await _authService.registerWithEmailAndPassword(email, password, displayName); //TODO: check
//       print(
//         "------ User registered successfully---- ${userCredential.user!.uid}",
//       );

//       await _fetchUserData(userCredential.user!.uid);
//       _status = AuthStatus.authenticated;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError(_getReadableErrorMessage(e));
//       _status = AuthStatus.unauthenticated; // TODO: check
//       notifyListeners();
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Sign in with Google
//   Future<bool> signInWithGoogle() async {
//     _setLoading(true);
//     _clearError();
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       UserCredential userCredential = await _authService.signInWithGoogle();
//       await _fetchUserData(userCredential.user!.uid);
//       _status = AuthStatus.authenticated;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       if (e is FirebaseAuthException && e.code == 'ERROR_ABORTED_BY_USER') {
//         // User cancelled the sign-in flow, don't show error
//         _clearError();
//       } else {
//         _setError(_getReadableErrorMessage(e));
//       }
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     _setLoading(true);

//     try {
//       await _authService.signOut();
//       _userModel = null;
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//     } catch (e) {
//       _setError(e.toString());
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Reset password
//   Future<bool> resetPassword(String email) async {
//     _setLoading(true);
//     _clearError();

//     try {
//       await _authService.resetPassword(email);
//       return true;
//     } catch (e) {
//       _setError(_getReadableErrorMessage(e));
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Fetch user data from Firestore
//   Future<void> _fetchUserData(String uid) async {
//     try {
//       UserModel? userModel = await _authService.getUserData(uid);
//       print('User document not found for UID: $uid');
//       if (userModel != null) {
//         _userModel = userModel;
//         _status = AuthStatus.authenticated;
//         notifyListeners();
//       } else {
//         _status = AuthStatus.unauthenticated;
//         notifyListeners();
//       }
//     } catch (e) {
//       _setError(e.toString());
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//     }
//   }

//   // Helper methods
//   void _setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   void _setError(String message) {
//     _errorMessage = message;
//     notifyListeners();
//   }

//   void _clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }

//   String _getReadableErrorMessage(dynamic error) {
//     if (error is FirebaseAuthException) {
//       switch (error.code) {
//         case 'user-not-found':
//           return 'No user found with this email.';
//         case 'wrong-password':
//           return 'Wrong password provided.';
//         case 'email-already-in-use':
//           return 'The email address is already in use.';
//         case 'weak-password':
//           return 'The password provided is too weak.';
//         case 'invalid-email':
//           return 'The email address is invalid.';
//         case 'operation-not-allowed': // TODO: check
//           return 'This operation is not allowed.';
//         case 'user-disabled':
//           return 'This user account has been disabled.';
//         case 'too-many-requests':
//           return 'Too many unsuccessful login attempts. Please try again later.';
//         case 'network-request-failed':
//           return 'Network error. Please check your internet connection.';
//         default:
//           return error.message ?? 'An unknown error occurred.';
//       }
//     }

//     return error.toString();
//   }
// }

// import 'package:flutter/foundation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/user_model.dart';
// import '../services/auth_service.dart';

// // Define AuthStatus enum
// enum AuthStatus { authenticated, unauthenticated, authenticating }

// class AuthProvider with ChangeNotifier {
//   final AuthService _authService = AuthService();

//   UserModel? _userModel;
//   bool _isLoading = false;
//   String? _errorMessage;
//   AuthStatus _status = AuthStatus.unauthenticated;

//   // Getters
//   UserModel? get userModel => _userModel;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   bool get isAuthenticated => _userModel != null;
//   AuthStatus get status => _status;

//   // Initialize auth state
//   Future<void> initializeAuthState() async {
//     _setLoading(true);
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       User? currentUser = _authService.currentUser;

//       if (currentUser != null) {
//         // Try to fetch user data
//         UserModel? userData = await _authService.getUserData(currentUser.uid);
//         if (userData != null) {
//           _userModel = userData;
//           _status = AuthStatus.authenticated;
//         } else {
//           // User exists in Firebase Auth but not in Firestore
//           _userModel = null;
//           _status = AuthStatus.unauthenticated;
//         }
//       } else {
//         _userModel = null;
//         _status = AuthStatus.unauthenticated;
//       }
//     } catch (e) {
//       _setError(e.toString());
//       _status = AuthStatus.unauthenticated;
//     } finally {
//       _setLoading(false);
//       notifyListeners();  // Only notify listeners once at the end
//     }
//   }

//   // Sign in with email and password
//   Future<bool> signInWithEmailAndPassword(String email, String password) async {
//     _setLoading(true);
//     _clearError();
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       UserCredential userCredential = await _authService.signInWithEmailAndPassword(email, password);

//       // Get user data after successful authentication
//       UserModel? userData = await _authService.getUserData(userCredential.user!.uid);
//       if (userData != null) {
//         _userModel = userData;
//         _status = AuthStatus.authenticated;
//       } else {
//         // Handle case where user exists in Auth but not in Firestore
//         _status = AuthStatus.unauthenticated;
//         _setError('User profile not found. Please contact support.');
//         return false;
//       }

//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError(_getReadableErrorMessage(e));
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Register with email and password
//   Future<bool> registerWithEmailAndPassword(
//     String email,
//     String password,
//     String displayName,
//   ) async {
//     _setLoading(true);
//     _clearError();
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       UserCredential userCredential = await _authService.registerWithEmailAndPassword(email, password, displayName);

//       // Get user data after successful registration
//       UserModel? userData = await _authService.getUserData(userCredential.user!.uid);
//       if (userData != null) {
//         _userModel = userData;
//         _status = AuthStatus.authenticated;
//       } else {
//         // This is unusual for registration, as we should create user data during registration
//         _status = AuthStatus.unauthenticated;
//         _setError('Failed to create user profile. Please try again.');
//         return false;
//       }

//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError(_getReadableErrorMessage(e));
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Sign in with Google
//   Future<bool> signInWithGoogle() async {
//     _setLoading(true);
//     _clearError();
//     _status = AuthStatus.authenticating;
//     notifyListeners();

//     try {
//       UserCredential userCredential = await _authService.signInWithGoogle();

//       // Get user data after successful Google sign-in
//       UserModel? userData = await _authService.getUserData(userCredential.user!.uid);
//       if (userData != null) {
//         _userModel = userData;
//         _status = AuthStatus.authenticated;
//       } else {
//         // For Google sign-in, we might need to create a new user profile if it's their first time
//         // This logic should be handled in the AuthService.signInWithGoogle method
//         _userModel = null;
//         _status = AuthStatus.unauthenticated;
//         _setError('Failed to retrieve or create user profile.');
//         return false;
//       }

//       notifyListeners();
//       return true;
//     } catch (e) {
//       if (e is FirebaseAuthException && e.code == 'ERROR_ABORTED_BY_USER') {
//         // User cancelled the sign-in flow, don't show error
//         _clearError();
//       } else {
//         _setError(_getReadableErrorMessage(e));
//       }
//       _status = AuthStatus.unauthenticated;
//       notifyListeners();
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     _setLoading(true);

//     try {
//       await _authService.signOut();
//       _userModel = null;
//       _status = AuthStatus.unauthenticated;
//     } catch (e) {
//       _setError(e.toString());
//     } finally {
//       _setLoading(false);
//       notifyListeners();
//     }
//   }

//   // Reset password
//   Future<bool> resetPassword(String email) async {
//     _setLoading(true);
//     _clearError();

//     try {
//       await _authService.resetPassword(email);
//       return true;
//     } catch (e) {
//       _setError(_getReadableErrorMessage(e));
//       return false;
//     } finally {
//       _setLoading(false);
//       notifyListeners();
//     }
//   }

//   // Helper methods
//   void _setLoading(bool value) {
//     _isLoading = value;
//   }

//   void _setError(String message) {
//     _errorMessage = message;
//   }

//   void _clearError() {
//     _errorMessage = null;
//   }

//   String _getReadableErrorMessage(dynamic error) {
//     if (error is FirebaseAuthException) {
//       switch (error.code) {
//         case 'user-not-found':
//           return 'No user found with this email.';
//         case 'wrong-password':
//           return 'Wrong password provided.';
//         case 'email-already-in-use':
//           return 'The email address is already in use.';
//         case 'weak-password':
//           return 'The password provided is too weak.';
//         case 'invalid-email':
//           return 'The email address is invalid.';
//         case 'operation-not-allowed':
//           return 'This operation is not allowed.';
//         case 'user-disabled':
//           return 'This user account has been disabled.';
//         case 'too-many-requests':
//           return 'Too many unsuccessful login attempts. Please try again later.';
//         case 'network-request-failed':
//           return 'Network error. Please check your internet connection.';
//         default:
//           return error.message ?? 'An unknown error occurred.';
//       }
//     }

//     return error.toString();
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Define AuthStatus enum
enum AuthStatus { authenticated, unauthenticated, authenticating }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  AuthStatus _status = AuthStatus.unauthenticated;

  // Getters
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userModel != null;
  AuthStatus get status => _status;

  // Initialize auth state
  Future<void> initializeAuthState() async {
    // Don't set status to authenticating if we're already authenticated
    // This helps prevent unnecessary state changes
    if (_status == AuthStatus.authenticated) return;

    _setLoading(true);
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      User? currentUser = _authService.currentUser;

      if (currentUser != null) {
        // Try to fetch user data
        UserModel? userData = await _authService.getUserData(currentUser.uid);
        if (userData != null) {
          _userModel = userData;
          _status = AuthStatus.authenticated;
        } else {
          // User exists in Firebase Auth but not in Firestore
          _userModel = null;
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _userModel = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _setError(e.toString());
      _status = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
      notifyListeners(); // Only notify listeners once at the end
    }
  }

  // Rest of your AuthProvider class as in the previous fix...

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _clearError();
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      UserCredential userCredential = await _authService
          .signInWithEmailAndPassword(email, password);

      // Get user data after successful authentication
      UserModel? userData = await _authService.getUserData(
        userCredential.user!.uid,
      );
      if (userData != null) {
        _userModel = userData;
        _status = AuthStatus.authenticated;
      } else {
        // Handle case where user exists in Auth but not in Firestore
        _status = AuthStatus.unauthenticated;
        _setError('User profile not found. Please contact support.');
        return false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getReadableErrorMessage(e));
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    _setLoading(true);
    _clearError();
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      UserCredential userCredential = await _authService
          .registerWithEmailAndPassword(email, password, displayName);

      // Get user data after successful registration
      UserModel? userData = await _authService.getUserData(
        userCredential.user!.uid,
      );
      if (userData != null) {
        _userModel = userData;
        _status = AuthStatus.authenticated;
      } else {
        // This is unusual for registration, as we should create user data during registration
        _status = AuthStatus.unauthenticated;
        _setError('Failed to create user profile. Please try again.');
        return false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getReadableErrorMessage(e));
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      UserCredential userCredential = await _authService.signInWithGoogle();

      // Get user data after successful Google sign-in
      UserModel? userData = await _authService.getUserData(
        userCredential.user!.uid,
      );
      if (userData != null) {
        _userModel = userData;
        _status = AuthStatus.authenticated;
      } else {
        // For Google sign-in, we might need to create a new user profile if it's their first time
        // This logic should be handled in the AuthService.signInWithGoogle method
        _userModel = null;
        _status = AuthStatus.unauthenticated;
        _setError('Failed to retrieve or create user profile.');
        return false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'ERROR_ABORTED_BY_USER') {
        // User cancelled the sign-in flow, don't show error
        _clearError();
      } else {
        _setError(_getReadableErrorMessage(e));
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _userModel = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(_getReadableErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _getReadableErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many unsuccessful login attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return error.message ?? 'An unknown error occurred.';
      }
    }

    return error.toString();
  }
}
