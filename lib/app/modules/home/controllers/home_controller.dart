import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/vault_item.dart';
import '../../../data/services/vault_service.dart';
import '../../../data/services/screen_security_service.dart';
import '../../../data/services/session_security_service.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final VaultService vaultService = Get.find<VaultService>();

  SessionSecurityService get sessionService => SessionSecurityService.to;

  // Bottom Navigation Current Tab Index (0: Home, 1: Analysis, 2: Search, 3: Setting)
  final RxInt currentTabIndex = 0.obs;

  // Search input & results
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Settings toggles
  final RxBool syncEnabled = true.obs;
  final RxBool autofillEnabled = true.obs;
  final RxBool allowScreenshots = false.obs; // Default: Screenshots blocked (FLAG_SECURE ON)

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  void navigateToProfile() {
    Get.toNamed(Routes.PROFILE_PAGE);
  }

  void navigateToNewRecord() {
    Get.toNamed(Routes.NEW_RECORD);
  }

  void navigateToDetails(VaultItem item) {
    Get.toNamed(Routes.PASSWORD_DETAILS, arguments: item);
  }

  /// Manually lock the vault immediately
  void lockVaultNow() {
    sessionService.lockVault(reason: 'Vault locked manually by user.');
  }

  /// Toggle screenshot and screen recording protection (Option 2)
  Future<void> toggleAllowScreenshots(bool allow) async {
    allowScreenshots.value = allow;
    // When allow == true, disable FLAG_SECURE (secureMode = false)
    // When allow == false, enable FLAG_SECURE (secureMode = true)
    await ScreenSecurityService.setSecureMode(!allow);

    Get.snackbar(
      allow ? 'Screenshots Allowed' : 'Screenshots Blocked',
      allow
          ? 'Warning: Screenshots and screen recording are now permitted.'
          : 'Screen protection active: Screenshots and recording are blocked.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      icon: Icon(
        allow ? Icons.warning_amber_rounded : Icons.shield_rounded,
        color: allow ? Colors.amberAccent : Colors.greenAccent,
      ),
    );
  }

  // Filtered list for search tab
  List<VaultItem> get searchResults {
    if (searchQuery.value.isEmpty) {
      return vaultService.items;
    }
    final q = searchQuery.value.toLowerCase();
    return vaultService.items
        .where((item) =>
            item.name.toLowerCase().contains(q) ||
            item.username.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q))
        .toList();
  }
}
