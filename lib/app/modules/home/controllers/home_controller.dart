import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/vault_item.dart';
import '../../../data/services/vault_service.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final VaultService vaultService = Get.find<VaultService>();

  // Bottom Navigation Current Tab Index (0: Home, 1: Analysis, 2: Search, 3: Setting)
  final RxInt currentTabIndex = 0.obs;

  // Search input & results
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Settings toggles
  final RxBool syncEnabled = true.obs;
  final RxBool autofillEnabled = true.obs;

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
            item.link.toLowerCase().contains(q))
        .toList();
  }
}
