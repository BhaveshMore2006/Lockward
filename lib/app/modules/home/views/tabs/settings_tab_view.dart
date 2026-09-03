import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class SettingsTabView extends GetView<HomeController> {
  const SettingsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12, width: 1.2),
            ),
            child: const Icon(Icons.person_outline_rounded, color: Colors.black87, size: 22),
          ),
          onPressed: controller.navigateToProfile,
        ),
        centerTitle: true,
        title: const Text(
          'Setting',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.black, size: 30),
            onPressed: controller.navigateToNewRecord,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildNavTile(
            title: 'Profile',
            onTap: controller.navigateToProfile,
          ),
          _buildDivider(),
          _buildNavTile(
            title: 'Permissions',
            onTap: () {
              Get.snackbar('Permissions', 'Biometric and storage permissions are active',
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),
          _buildDivider(),
          Obx(
            () => _buildSwitchTile(
              title: 'Sync',
              value: controller.syncEnabled.value,
              onChanged: (val) => controller.syncEnabled.value = val,
            ),
          ),
          _buildDivider(),
          Obx(
            () => _buildSwitchTile(
              title: 'Autofill',
              value: controller.autofillEnabled.value,
              onChanged: (val) => controller.autofillEnabled.value = val,
            ),
          ),
          _buildDivider(),
          _buildNavTile(
            title: 'About',
            onTap: () {
              Get.defaultDialog(
                title: 'Lockward',
                middleText: 'Lockward is a modern, high-security vault application for storing all your passwords safely.',
                textConfirm: 'Got it',
                confirmTextColor: Colors.white,
                buttonColor: Colors.black87,
                onConfirm: () => Get.back(),
              );
            },
          ),
          _buildDivider(),
          _buildNavTile(
            title: 'Help',
            onTap: () {
              Get.snackbar('Help & Support', 'Reach out to support@lockward.app for assistance.',
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),
          _buildDivider(),
          _buildInfoTile(
            title: 'Version',
            info: '1.2.2',
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildNavTile({required String title, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black26,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF0057FF),
              activeTrackColor: const Color(0xFF0057FF).withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({required String title, required String info}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            info,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: Colors.black12);
  }
}
