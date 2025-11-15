import 'package:cardmaker/models/user_model.dart';
import 'package:cardmaker/services/auth_service.dart';
import 'package:cardmaker/services/firestore_service.dart';
import 'package:get/get.dart';

class AdminUtils {
  static final AuthService _authService = Get.find<AuthService>();
  static final FirestoreServices _firestoreService = FirestoreServices();

  // Check if current user is admin
  static Future<bool> isAdmin() async {
    final user = _authService.user;
    if (user == null) return false;

    try {
      final userModel = await _firestoreService.getUserById(user.uid);
      return userModel?.role == UserRole.admin;
    } catch (e) {
      return false;
    }
  }

  // Get current user model
  static Future<UserModel?> getCurrentUser() async {
    final user = _authService.user;
    if (user == null) return null;

    try {
      return await _firestoreService.getUserById(user.uid);
    } catch (e) {
      return null;
    }
  }

  // Check if user has admin access (synchronous check using cached UID)
  static bool isOwner() {
    final user = _authService.user;
    if (user == null) return false;

    // Check against known admin UIDs
    return user.uid == "LTRhJmbufLQP0hrJj5xNKwOfDc53" ||
        user.uid == "aP3FVBY7kWgBnJorqVrYha3lFaa2";
  }
}
