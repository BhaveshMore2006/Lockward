import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VaultItem {
  final String id;
  final String title;
  final String username;
  final String password;
  final IconData icon;
  final Color color;

  VaultItem({
    required this.id,
    required this.title,
    required this.username,
    required this.password,
    required this.icon,
    required this.color,
  });
}

class HomeController extends GetxController {
  final RxList<VaultItem> vaultItems = <VaultItem>[].obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  void loadDummyData() {
    vaultItems.value = [
      VaultItem(
        id: '1',
        title: 'Google',
        username: 'user@gmail.com',
        password: 'password123',
        icon: Icons.g_mobiledata,
        color: Colors.redAccent,
      ),
      VaultItem(
        id: '2',
        title: 'Netflix',
        username: 'user@gmail.com',
        password: 'secure_password!',
        icon: Icons.movie,
        color: Colors.red,
      ),
      VaultItem(
        id: '3',
        title: 'Bank of America',
        username: 'john.doe',
        password: 'bank_password_456',
        icon: Icons.account_balance,
        color: Colors.blueAccent,
      ),
      VaultItem(
        id: '4',
        title: 'Spotify',
        username: 'music_lover',
        password: 'spotify_rocks',
        icon: Icons.music_note,
        color: Colors.green,
      ),
    ];
  }

  void search(String query) {
    searchQuery.value = query;
  }

  void copyPassword(String password) {
    // In a real app, use Clipboard.setData(ClipboardData(text: password))
    Get.snackbar(
      'Copied',
      'Password copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void addNewItem() {
    Get.snackbar(
      'New Item',
      'This feature is coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
    );
  }

  void logout() {
    Get.offAllNamed('/login');
  }

  List<VaultItem> get filteredItems {
    if (searchQuery.value.isEmpty) {
      return vaultItems;
    }
    return vaultItems
        .where((item) =>
            item.title.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }
}
