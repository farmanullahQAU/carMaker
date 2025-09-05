import 'package:cardmaker/core/errors/error_maps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'failure.dart';

class FirebaseErrorHandler {
  static Failure _mapError(
    String code,
    String? message,
    Map<String, String> errorMap,
    String fallback,
  ) {
    return Failure(code, errorMap[code] ?? message ?? fallback);
  }

  /// ✅ Universal handler
  static Failure handle(Object e) {
    if (e is FirebaseAuthException) {
      return _mapError(
        e.code,
        e.message,
        authErrors,
        'Authentication error occurred.',
      );
    } else if (e is FirebaseException && e.plugin == 'cloud_firestore') {
      return _mapError(
        e.code,
        e.message,
        firestoreErrors,
        'Firestore error occurred.',
      );
    } else if (e is FirebaseException && e.plugin == 'firebase_storage') {
      return _mapError(
        e.code,
        e.message,
        storageErrors,
        'Storage error occurred.',
      );
    } else if (e is GoogleSignInException) {
      return _mapError(
        e.code.name,
        e.description,
        googleSignInErrors,
        'Google sign-in error occurred.',
      );
    } else {
      return Failure('unknown', e.toString());
    }
  }
}
