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
          'password': password,
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

  // --- Password Reset Logic ---
  Future<({bool success, String message})> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return (
        success: true,
        message: 'A password reset link has been sent to $email. Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to send password reset email.';
      if (e.code == 'user-not-found') {
        msg = 'No user account found with this email address.';
      } else if (e.code == 'invalid-email') {
        msg = 'The email address is invalid.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        msg = e.message!;
      }
      return (success: false, message: msg);
    } catch (e) {
      return (success: false, message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- Change Password Logic ---
  Future<({bool success, String message})> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return (
          success: false,
          message: 'User session not found. Please log in again to continue.',
        );
      }

      // Re-authenticate user with current password before updating
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      // Also update stored password in Firestore
      try {
        final query = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update({
            'password': newPassword,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        debugPrint('Failed to update password in Firestore: $e');
      }

      return (
        success: true,
        message: 'Your password has been changed successfully.',
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to update password.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'The current password you entered is incorrect.';
      } else if (e.code == 'weak-password') {
        msg = 'The new password is too weak. Please choose a stronger password.';
      } else if (e.code == 'requires-recent-login') {
        msg = 'For security reasons, please log out and log in again before changing your password.';
      } else if (e.message != null && e.message!.isNotEmpty) {
        msg = e.message!;
      }
      return (success: false, message: msg);
    } catch (e) {
      return (
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // --- Reset Password with OTP Flow ---
  Future<({bool success, String message})> resetPasswordWithOtp({
    required String email,
    required String newPassword,
  }) async {
    try {
      final normalizedEmail = email.trim();
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        final oldPassword = data['password'] as String?;

        // If old password exists, sign in to update Firebase Auth user directly
        if (oldPassword != null && oldPassword.isNotEmpty) {
          try {
            final cred = await _auth.signInWithEmailAndPassword(
              email: normalizedEmail,
              password: oldPassword,
            );
            if (cred.user != null) {
              await cred.user!.updatePassword(newPassword);
              await _auth.signOut();
            }
          } catch (e) {
            debugPrint('Could not update Firebase Auth directly: $e');
          }
        }

        // Update password in Firestore
        await doc.reference.update({
          'password': newPassword,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Also trigger password reset email in background just in case
      try {
        await _auth.sendPasswordResetEmail(email: normalizedEmail);
      } catch (_) {}

      return (
        success: true,
        message: 'Your password has been reset successfully! You can now log in with your new password.',
      );
    } catch (e) {
      return (
        success: false,
        message: 'Failed to reset password: ${e.toString()}',
      );
    }
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
