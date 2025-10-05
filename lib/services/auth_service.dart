import 'package:cardmaker/app/features/profile/controller.dart';
import 'package:cardmaker/core/errors/firebase_error_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final Rxn<User> _user = Rxn<User>();
  User? get user => _user.value;

  final RxBool isLoading = false.obs;

  RxBool isSkipped = false.obs;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, (d) {
      if (d == null) {
        isSkipped.value = false;
      } else {
        isSkipped.value = true;
      }
    });
  }

  // Email & Password Sign Up
  Future<String?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;

      if (password != confirmPassword) {
        throw 'Passwords do not match';
      }

      if (password.length < 6) {
        throw 'Password must be at least 6 characters long';
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await result.user?.sendEmailVerification();

      isLoading.value = false;
      return null;
    } catch (e) {
      isLoading.value = false;
      throw FirebaseErrorHandler.handle(e).message;
    }
  }

  // Email & Password Sign In
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (!result.user!.emailVerified) {
        await _auth.signOut();
        throw 'Please verify your email before signing in';
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      throw FirebaseErrorHandler.handle(e).message;
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      isLoading.value = true;

      await GoogleSignIn.instance.initialize(
        serverClientId:
            "370527194012-p63ecinqsi57pdbjqvqljfnclggooh3e.apps.googleusercontent.com",
      );

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.idToken,
      );
      isLoading.value = false;

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      isLoading.value = false;
      throw FirebaseErrorHandler.handle(e).message;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email.trim());
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      throw FirebaseErrorHandler.handle(e).message;
    }
  }

  // Delete Account (Comprehensive Client-Side Cleanup)
  Future<void> deleteAccount({String? password}) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user is signed in';
      }
      final uid = user.uid;

      // Step 1: Re-authenticate
      final providerData = user.providerData;
      final isGoogleUser = providerData.any(
        (info) => info.providerId == 'google.com',
      );
      final isEmailUser = providerData.any(
        (info) => info.providerId == 'password',
      );

      if (isGoogleUser) {
        await GoogleSignIn.instance.initialize(
          serverClientId:
              "370527194012-p63ecinqsi57pdbjqvqljfnclggooh3e.apps.googleusercontent.com",
        );
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (isEmailUser && password != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      } else {
        throw 'Unable to determine sign-in method or missing password';
      }
      /*
      // Step 2: Clean up Firestore and Storage using FirestoreService
      final firestoreService = Get.find<FirestoreServices>(); // Lazy-load
      final draftsSnapshot = await firestoreService.getUserDraftsPaginated(
        limit: 1000,
      );
      for (final draftDoc in draftsSnapshot.docs) {
        await firestoreService.deleteDraft(draftDoc.id);
      }

      final favoritesSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .get();
      final batch = _firestore.batch();
      for (final favDoc in favoritesSnapshot.docs) {
        batch.delete(favDoc.reference);
        batch.update(_firestore.collection('templates').doc(favDoc.id), {
          'favoriteCount': FieldValue.increment(-1),
        });
      }
      await batch.commit();

      await _firestore.collection('users').doc(uid).delete();

      final storageRef = _storage.ref().child('user_drafts/$uid');
      try {
        final listResult = await storageRef.listAll();
        final deleteFutures = <Future>[];
        for (var prefix in listResult.prefixes) {
          deleteFutures.addAll(
            (await prefix.listAll()).items.map((item) => item.delete()),
          );
        }
        deleteFutures.addAll(listResult.items.map((item) => item.delete()));
        await Future.wait(deleteFutures);
      } catch (e) {}
*/
      // Step 3: Delete Firebase Auth account
      await user.delete();

      // Step 4: Clear local state
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().drafts.clear();
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      throw FirebaseErrorHandler.handle(e).message;
    }
  }
}
