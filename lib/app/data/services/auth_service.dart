import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable for tracking the current user state
  final Rx<User?> currentUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    // Bind the stream so it updates automatically when auth state changes
    currentUser.bindStream(_auth.authStateChanges());
  }

  // --- Registration Logic ---
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // 1. Create the user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Store additional user info in Firestore
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5), onTimeout: () {
          throw Exception("Firestore write timed out. Have you created the Firestore Database in the Firebase Console?");
        });
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.toString());
      return false;
    } catch (e) {
      _showErrorSnackbar('Unexpected: ${e.toString()}');
      return false;
    }
  }

  // --- Login Logic ---
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.message ?? 'Invalid email or password');
      return false;
    } catch (e) {
      _showErrorSnackbar('An unexpected error occurred');
      return false;
    }
  }

  // --- Logout Logic ---
  Future<void> logout() async {
    await _auth.signOut();
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
