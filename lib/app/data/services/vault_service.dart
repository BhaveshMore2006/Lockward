import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../models/vault_item.dart';

class VaultService extends GetxService {
  static VaultService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<VaultItem> items = <VaultItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _listenToVaultItems(user.uid);
      } else {
        items.clear();
      }
    });
  }

  encrypt.Encrypter _getEncrypter(String uid) {
    // Basic key derivation from UID (padding or truncating to 32 chars)
    final keyString = uid.padRight(32, '0').substring(0, 32);
    final key = encrypt.Key.fromUtf8(keyString);
    return encrypt.Encrypter(encrypt.AES(key));
  }

  String _encryptPassword(String plainText, String uid) {
    final encrypter = _getEncrypter(uid);
    final iv = encrypt.IV.fromLength(16);
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String _decryptPassword(String encryptedText, String uid) {
    try {
      final parts = encryptedText.split(':');
      if (parts.length != 2) return encryptedText; // Not encrypted properly
      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      final encrypter = _getEncrypter(uid);
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      debugPrint('Error decrypting password: $e');
      return 'Error Decrypting';
    }
  }

  void _listenToVaultItems(String uid) {
    _firestore
        .collection('users')
        .doc(uid)
        .collection('vault_items')
        .snapshots()
        .listen((snapshot) {
      final List<VaultItem> newItems = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('password')) {
          data['password'] = _decryptPassword(data['password'], uid);
        }
        newItems.add(VaultItem.fromMap(data, doc.id));
      }
      items.assignAll(newItems);
    });
  }

  Future<void> addItem(VaultItem item) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final data = item.toMap();
    data['password'] = _encryptPassword(item.password, user.uid);
    data['createdAt'] = FieldValue.serverTimestamp();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('vault_items')
        .add(data);
  }

  Future<void> updateItem(VaultItem item) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final data = item.toMap();
    data['password'] = _encryptPassword(item.password, user.uid);
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('vault_items')
        .doc(item.id)
        .update(data);
  }

  Future<void> deleteItem(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('vault_items')
        .doc(id)
        .delete();
  }

  Future<void> toggleFavorite(VaultItem item) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('vault_items')
        .doc(item.id)
        .update({'isFavorite': !item.isFavorite});
  }

  void copyPassword(String password, {String title = 'Password'}) {
    Clipboard.setData(ClipboardData(text: password));
    Get.snackbar(
      'Copied to clipboard',
      '$title copied successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  int get safeCount => items.where((i) => i.securityStatus == SecurityStatus.safe).length;
  int get weakCount => items.where((i) => i.securityStatus == SecurityStatus.weak).length;
  int get riskCount => items.where((i) => i.securityStatus == SecurityStatus.risk).length;

  int get overallSecurityScore {
    if (items.isEmpty) return 100;
    // Weighted formula: safe=100%, weak=50%, risk=10%
    final score = ((safeCount * 100) + (weakCount * 50) + (riskCount * 10)) / items.length;
    return score.round();
  }

  // Password generation helper
  static String generatePassword({
    int length = 12,
    bool useNumbers = true,
    bool useSymbols = true,
    bool useLowercase = true,
    bool useUppercase = true,
  }) {
    String lower = 'abcdefghijklmnopqrstuvwxyz';
    String upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String numbers = '0123456789';
    String symbols = '!@#\$%^&*()-_+=<>?';

    String pool = '';
    if (useLowercase) pool += lower;
    if (useUppercase) pool += upper;
    if (useNumbers) pool += numbers;
    if (useSymbols) pool += symbols;

    if (pool.isEmpty) pool = lower + numbers;

    final random = Random.secure();
    return List.generate(length, (_) => pool[random.nextInt(pool.length)]).join();
  }
}
