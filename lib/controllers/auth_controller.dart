// lib/controllers/auth_controller.dart - COMPLETE FIX
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxBool isFirstTime = true.obs;

  @override
  void onReady() {
    super.onReady();
    print('🔥 AuthController onReady');

    // Bind user state
    firebaseUser.bindStream(_auth.authStateChanges());

    // Check first time and handle auth state
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Check if first time opening app
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      print('📱 Has seen onboarding: $hasSeenOnboarding');

      // Check current user
      final currentUser = _auth.currentUser;
      print('👤 Current user: ${currentUser?.email ?? 'None'}');

      if (currentUser != null) {
        // User is logged in
        print('✅ User is logged in, going to dashboard');
        await Future.delayed(Duration(seconds: 2)); // Wait for splash
        Get.offAllNamed('/dashboard');
      } else {
        // User not logged in
        if (hasSeenOnboarding) {
          print('📱 Returning user, going to login');
          await Future.delayed(Duration(seconds: 2)); // Wait for splash
          Get.offAllNamed('/login');
        } else {
          print('🆕 First time user, going to onboarding');
          await Future.delayed(Duration(seconds: 2)); // Wait for splash
          Get.offAllNamed('/onboarding');
        }
      }
    } catch (e) {
      print('❌ Initialization error: $e');
      await Future.delayed(Duration(seconds: 2));
      Get.offAllNamed('/onboarding');
    }
  }

  // Mark onboarding as seen
  Future<void> markOnboardingAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
      print('✅ Onboarding marked as seen');
    } catch (e) {
      print('❌ Error marking onboarding: $e');
    }
  }

  // SIGN UP
  Future<void> signUp(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      isLoading.value = true;
      print('📝 Starting signup for: $email');

      // Create user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('✅ User created: ${result.user?.uid}');

      // Create user document in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'height': '0',
        'weight': '0',
        'goal': 'Get Fit',
        'level': 'Beginner',
        'profileCompleted': false,
      });

      print('✅ User document created in Firestore');

      Get.snackbar(
        "Success",
        "Account created successfully!",
        backgroundColor: Color(0xFF00B894).withOpacity(0.1),
        colorText: Color(0xFF00B894),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );

      isLoading.value = false;

      // Navigate to dashboard
      Get.offAllNamed('/dashboard');

    } catch (e) {
      isLoading.value = false;
      print('❌ Signup error: $e');

      String errorMessage = 'An error occurred';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'Password is too weak (min 6 characters)';
            break;
          case 'email-already-in-use':
            errorMessage = 'Email already registered';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
          default:
            errorMessage = e.message ?? 'Authentication failed';
        }
      }

      Get.snackbar(
        "Signup Error",
        errorMessage,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        duration: Duration(seconds: 4),
      );
    }
  }

  // LOGIN
  Future<void> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields",
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    try {
      isLoading.value = true;
      print('🔐 Starting login for: $email');

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('✅ Login successful');

      Get.snackbar(
        "Success",
        "Welcome back!",
        backgroundColor: Color(0xFF00B894).withOpacity(0.1),
        colorText: Color(0xFF00B894),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        duration: Duration(seconds: 2),
      );

      isLoading.value = false;

      // Navigate to dashboard
      Get.offAllNamed('/dashboard');

    } catch (e) {
      isLoading.value = false;
      print('❌ Login error: $e');

      String errorMessage = 'Login failed';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No account found with this email';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many attempts. Try again later';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid email or password';
            break;
          default:
            errorMessage = e.message ?? 'Authentication failed';
        }
      }

      Get.snackbar(
        "Login Error",
        errorMessage,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        duration: Duration(seconds: 4),
      );
    }
  }

  // COMPLETE PROFILE
  Future<void> completeProfile({
    required String goal,
    required String height,
    required String weight,
    required String level,
  }) async {
    try {
      final uid = firebaseUser.value?.uid;

      if (uid == null) {
        print('❌ No user logged in');
        return;
      }

      print('📝 Completing profile for: $uid');

      await _firestore.collection('users').doc(uid).update({
        'goal': goal,
        'height': height,
        'weight': weight,
        'level': level,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Profile completed');

      Get.snackbar(
        "Success",
        "Profile updated!",
        backgroundColor: Color(0xFF00B894).withOpacity(0.1),
        colorText: Color(0xFF00B894),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );

      Get.offAllNamed('/dashboard');

    } catch (e) {
      print('❌ Profile completion error: $e');
      Get.snackbar(
        "Error",
        "Failed to update profile",
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      print('📤 Logging out user');
      await _auth.signOut();
      print('✅ Logout successful');

      Get.snackbar(
        "Logged Out",
        "See you soon!",
        backgroundColor: AppColors.primary.withOpacity(0.1),
        colorText: AppColors.primary,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        duration: Duration(seconds: 2),
      );

      // Go to login
      Get.offAllNamed('/login');

    } catch (e) {
      print('❌ Logout error: $e');
      Get.snackbar(
        "Error",
        "Failed to logout",
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => firebaseUser.value != null;

  // Get current user
  User? get currentUser => firebaseUser.value;

  // Get user email
  String? get userEmail => firebaseUser.value?.email;
}