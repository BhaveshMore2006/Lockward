import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/vault_item.dart';

class VaultService extends GetxService {
  static VaultService get to => Get.find();

  final RxList<VaultItem> items = <VaultItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialItems();
  }

  void _loadInitialItems() {
    items.assignAll([
      VaultItem(
        id: '1',
        name: 'Behance',
        username: 'design.steve@gmail.com',
        password: 'Czb6n1WFh8Qvia#M',
        category: 'Priority',
        link: 'behance.net',
        autofill: true,
        securityStatus: SecurityStatus.risk,
        brandColor: const Color(0xFF0057FF),
        iconLetter: 'Bē',
      ),
      VaultItem(
        id: '2',
        name: 'Adobe',
        username: 'work.steve@gmail.com',
        password: 'Czb6n1WFh8Qvia#M',
        category: 'Priority',
        link: 'adobe.com',
        autofill: true,
        securityStatus: SecurityStatus.safe,
        brandColor: const Color(0xFFED2224),
        iconLetter: 'A',
      ),
      VaultItem(
        id: '3',
        name: 'Netflix',
        username: 'chill.steve@gmail.com',
        password: 'Chill_Movie#2026',
        category: 'Entertainment',
        link: 'netflix.com',
        autofill: true,
        securityStatus: SecurityStatus.safe,
        brandColor: const Color(0xFF141414),
        iconLetter: 'N',
      ),
      VaultItem(
        id: '4',
        name: 'Spotify',
        username: 'chill.steve@gmail.com',
        password: 'Music_Vibes!99',
        category: 'Entertainment',
        link: 'spotify.com',
        autofill: true,
        securityStatus: SecurityStatus.safe,
        brandColor: const Color(0xFF1DB954),
        iconLetter: 'S',
      ),
      VaultItem(
        id: '5',
        name: 'Steam',
        username: 'chill.steve@gmail.com',
        password: 'SteamGaming#456',
        category: 'Entertainment',
        link: 'steampowered.com',
        autofill: true,
        securityStatus: SecurityStatus.weak,
        brandColor: const Color(0xFF171A21),
        iconLetter: 'St',
      ),
      VaultItem(
        id: '6',
        name: 'Medium',
        username: 'work.steve@gmail.com',
        password: 'ReadMedium@Daily1',
        category: 'Work',
        link: 'medium.com',
        autofill: true,
        securityStatus: SecurityStatus.safe,
        brandColor: const Color(0xFF242424),
        iconLetter: 'M',
      ),
      VaultItem(
        id: '7',
        name: 'Apple',
        username: 'robert.eau@icloud.com',
        password: 'robert_eau_pass',
        category: 'Work',
        link: 'apple.com',
        autofill: true,
        securityStatus: SecurityStatus.weak,
        brandColor: const Color(0xFF555555),
        iconLetter: '',
      ),
      VaultItem(
        id: '8',
        name: 'Codepen',
        username: 'steve@codepen.io',
        password: 'WebCode_Pen!404',
        category: 'Work',
        link: 'codepen.io',
        autofill: false,
        securityStatus: SecurityStatus.safe,
        brandColor: const Color(0xFF000000),
        iconLetter: 'CP',
      ),
      VaultItem(
        id: '9',
        name: 'Facebook',
        username: 'setto@rem.ru',
        password: 'Social_FB#Connect',
        category: 'Priority',
        link: 'facebook.com',
        autofill: true,
        securityStatus: SecurityStatus.safe,
        brandColor: const Color(0xFF1877F2),
        iconLetter: 'f',
      ),
      VaultItem(
        id: '10',
        name: 'Figma',
        username: 'steve@figma.com',
        password: 'UiUxDesignFigma#2',
        category: 'Work',
        link: 'figma.com',
        autofill: true,
        securityStatus: SecurityStatus.safe,
        brandColor: const Color(0xFFF24E1E),
        iconLetter: 'Fg',
      ),
    ]);
  }

  void addItem(VaultItem item) {
    items.insert(0, item);
  }

  void updateItem(VaultItem item) {
    final index = items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      items[index] = item;
    }
  }

  void deleteItem(String id) {
    items.removeWhere((element) => element.id == id);
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
