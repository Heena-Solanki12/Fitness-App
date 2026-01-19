import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _handleAuthChanged);
    super.onInit();
  }

  void _handleAuthChanged(User? user) {
    isLoading.value = false;

    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      Get.offAllNamed('/dashboard');
    }
  }

  // SIGN UP
  Future<void> signUp(String email, String password) async {
    try {
      isLoading.value = true;

      UserCredential result =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'createdAt': DateTime.now(),
        'height': 0,
        'weight': 0,
        'goal': 'Fitness',
      });
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Signup Error", e.toString());
    }
  }

  // LOGIN
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Login Error", e.toString());
    }
  }

  Future<void> completeProfile({
    required String goal,
    required String height,
    required String weight,
    required String level,
  }) async {
    final uid = firebaseUser.value!.uid;

    await _firestore.collection('users').doc(uid).update({
      'goal': goal,
      'height': height,
      'weight': weight,
      'level': level,
      'profileCompleted': true,
    });
  }


  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
