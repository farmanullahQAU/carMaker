// import 'package:cardmaker/core/errors/firebase_error_handler.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// abstract class AuthRepository {
//   Stream<User?> get authStateChanges;
//   User? get currentUser;

//   Future<String?> signUpWithEmailAndPassword({
//     required String email,
//     required String password,
//     required String confirmPassword,
//   });

//   Future<String?> signInWithEmailAndPassword({
//     required String email,
//     required String password,
//   });

//   Future<String?> signInWithGoogle();
//   Future<void> signOut();
//   Future<String?> sendPasswordResetEmail(String email);
// }

// class AuthRepositoryImpl implements AuthRepository {
//   final FirebaseAuth _auth;
//   final GoogleSignIn _googleSignIn;

//   AuthRepositoryImpl({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
//     : _auth = auth ?? FirebaseAuth.instance,
//       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

//   @override
//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   @override
//   User? get currentUser => _auth.currentUser;

//   @override
//   Future<String?> signUpWithEmailAndPassword({
//     required String email,
//     required String password,
//     required String confirmPassword,
//   }) async {
//     try {
//       if (password != confirmPassword) {
//         throw 'Passwords do not match';
//       }

//       if (password.length < 6) {
//         throw 'Password must be at least 6 characters long';
//       }

//       final UserCredential result = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );

//       await result.user?.sendEmailVerification();
//       return null;
//     } catch (e) {
//       final failure = FirebaseErrorHandler.handle(e);
//       return failure.message;
//     }
//   }

//   @override
//   Future<String?> signInWithEmailAndPassword({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final UserCredential result = await _auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );

//       if (!result.user!.emailVerified) {
//         await _auth.signOut();
//         return 'Please verify your email before signing in';
//       }

//       return null;
//     } catch (e) {
//       final failure = FirebaseErrorHandler.handle(e);
//       return failure.message;
//     }
//   }

//   @override
//   Future<String?> signInWithGoogle() async {
//     try {
//       await _googleSignIn.initialize(
//         serverClientId:
//             "370527194012-p63ecinqsi57pdbjqvqljfnclggooh3e.apps.googleusercontent.com",
//       );

//       final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
//       final googleAuth = googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//         accessToken: googleAuth.idToken,
//       );

//       await _auth.signInWithCredential(credential);
//       return null;
//     } catch (e) {
//       final failure = FirebaseErrorHandler.handle(e);
//       return failure.message;
//     }
//   }

//   @override
//   Future<void> signOut() async {
//     try {
//       await _auth.signOut();
//       await _googleSignIn.signOut();
//     } catch (e) {
//       print('Error signing out: $e');
//     }
//   }

//   @override
//   Future<String?> sendPasswordResetEmail(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email.trim());
//       return null;
//     } catch (e) {
//       final failure = FirebaseErrorHandler.handle(e);
//       return failure.message;
//     }
//   }
// }
