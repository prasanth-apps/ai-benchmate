import 'package:get/get.dart';

import '../../modules/authentication/views/welcome_screen.dart';
import '../../modules/authentication/views/register_screen.dart';
import '../../modules/authentication/views/login_screen.dart';
import '../../modules/authentication/views/forgot_password_screen.dart';
import '../../modules/home/views/home_screen.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: AppRoutes.register, page: () => RegisterScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
  ];
}
