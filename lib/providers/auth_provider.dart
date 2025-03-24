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
    _setLoading(true);
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      User? currentUser = _authService.currentUser;

      if (currentUser != null) {
        await _fetchUserData(currentUser.uid);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _setError(e.toString());
      _status = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _setLoading(true);
    _clearError();
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      UserCredential userCredential = await _authService
          .signInWithEmailAndPassword(email, password);

      await _fetchUserData(userCredential.user!.uid);
      _status = AuthStatus.authenticated;
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
      print(
        "------Registering user with email: $email,$password,$displayName ------ ",
      );
      UserCredential userCredential = await _authService
          .registerWithEmailAndPassword(email, password, displayName);
      print(
        "------ User registered successfully---- ${userCredential.user!.uid}",
      );

      await _fetchUserData(userCredential.user!.uid);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getReadableErrorMessage(e));
      _status = AuthStatus.unauthenticated; // TODO: check
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
      await _fetchUserData(userCredential.user!.uid);
      _status = AuthStatus.authenticated;
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
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
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
    }
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData(String uid) async {
    try {
      UserModel? userModel = await _authService.getUserData(uid);

      if (userModel != null) {
        _userModel = userModel;
        _status = AuthStatus.authenticated;
        notifyListeners();
      } else {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
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
        case 'operation-not-allowed': // TODO: check
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
