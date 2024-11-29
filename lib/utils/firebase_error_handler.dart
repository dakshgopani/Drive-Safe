import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Please provide a valid email address.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return error.toString();
  }

  static String getFirestoreErrorMessage(dynamic error) {
    // Add specific Firestore error handling here
    return 'Database error: ${error.toString()}';
  }

  static String getStorageErrorMessage(dynamic error) {
    // Add specific Storage error handling here
    return 'Storage error: ${error.toString()}';
  }
}