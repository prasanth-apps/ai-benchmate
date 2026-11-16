
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise local storage.
  await GetStorage.init();

  // Initialise Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate Firebase App Check.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidDebugProvider(),
  );

  runApp(const BenchMateApp());
}

class BenchMateApp extends StatelessWidget {
  const BenchMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI BenchMate',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF673AB7),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
      ),
      initialRoute: AppRoutes.welcome,
      getPages: AppPages.pages,
    );
  }
}
