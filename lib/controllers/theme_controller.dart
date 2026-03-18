// lib/controllers/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final isDark = false.obs;
  static const _key = 'isDarkMode';

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_key);
      if (saved != null) {
        isDark.value = saved;
        Get.changeThemeMode(saved ? ThemeMode.dark : ThemeMode.light);
      } else {
        // Follow system
        final sysDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
        isDark.value = sysDark;
        Get.changeThemeMode(sysDark ? ThemeMode.dark : ThemeMode.light);
      }
    } catch (_) {}
  }

  Future<void> toggle() async {
    isDark.value = !isDark.value;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, isDark.value);
    } catch (_) {}
  }

  Future<void> setDark(bool value) async {
    if (isDark.value == value) return;
    await toggle();
  }
}
