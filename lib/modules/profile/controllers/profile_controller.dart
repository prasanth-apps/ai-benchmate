import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../app/routes/app_routes.dart';
import '../../authentication/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;

  String get studentName => currentUser?.displayName?.trim().isNotEmpty == true
      ? currentUser!.displayName!
      : 'Student';

  String get email => currentUser?.email ?? 'No email available';

  Future<void> logout() async {
    try {
      await _authService.logout();

      Get.offAllNamed(AppRoutes.login);

      Get.snackbar(
        'Logged Out',
        'You have successfully logged out.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        'Unable to log out. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
