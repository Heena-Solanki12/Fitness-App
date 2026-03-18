// lib/views/signup_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../core/theme/app_colors.dart';

class SignupView extends StatelessWidget {
  SignupView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final RxBool _obscure = true.obs;
  final RxBool _obscureConfirm = true.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = ThemeController.to.isDark.value;
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.backgroundDark, const Color(0xFF1C2128)]
                  : [AppColors.backgroundLight, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.2), AppColors.secondary.withOpacity(0.2)]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.fitness_center, size: 60, color: AppColors.primary),
                    ),
                    const SizedBox(height: 30),
                    Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
                    const SizedBox(height: 8),
                    const Text('Start your fitness journey today', style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
                            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                          ),
                          const SizedBox(height: 20),
                          Obx(() => TextField(
                            controller: passwordController,
                            obscureText: _obscure.value,
                            style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => _obscure.value = !_obscure.value,
                              ),
                            ),
                          )),
                          const SizedBox(height: 20),
                          Obx(() => TextField(
                            controller: confirmPasswordController,
                            obscureText: _obscureConfirm.value,
                            style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => _obscureConfirm.value = !_obscureConfirm.value,
                              ),
                            ),
                          )),
                          const SizedBox(height: 30),
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                              ),
                              child: ElevatedButton(
                                onPressed: authController.isLoading.value
                                    ? null
                                    : () {
                                        if (passwordController.text != confirmPasswordController.text) {
                                          Get.snackbar('Error', 'Passwords do not match',
                                              backgroundColor: AppColors.error.withOpacity(0.1),
                                              colorText: AppColors.error,
                                              snackPosition: SnackPosition.BOTTOM,
                                              margin: const EdgeInsets.all(16),
                                              borderRadius: 12);
                                          return;
                                        }
                                        authController.signUp(emailController.text.trim(), passwordController.text.trim());
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: authController.isLoading.value
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                    : const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text('Login', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
