import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
import 'routes/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized');
  } catch (e) {
    print('⚠️ Firebase initialization error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FitFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      debugShowCheckedModeBanner: false,
    );
  }
}