import 'package:get/get.dart';

import '../../modules/authentication/views/welcome_screen.dart';
import '../../modules/authentication/views/register_screen.dart';
import '../../modules/authentication/views/login_screen.dart';
import '../../modules/authentication/views/forgot_password_screen.dart';

import '../../modules/home/views/home_screen.dart';
import '../../modules/document_vault/views/document_vault_screen.dart';
import '../../modules/homework_help/views/homework_screen.dart';
import '../../modules/assignments/views/assignments_screen.dart';
import '../../modules/profile/views/profile_screen.dart';

import 'app_routes.dart';
import 'auth_middleware.dart';

class AppPages {
  static final pages = [
    // Public routes
    GetPage(name: AppRoutes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: AppRoutes.register, page: () => RegisterScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordScreen()),

    // Protected routes
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.homework,
      page: () => HomeworkScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.documentVault,
      page: () => const DocumentVaultScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.assignments,
      page: () => const AssignmentsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => ProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
