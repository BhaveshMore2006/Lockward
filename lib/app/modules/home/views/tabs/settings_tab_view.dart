import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../../../data/services/session_security_service.dart';

class SettingsTabView extends GetView<HomeController> {
  const SettingsTabView({super.key});

  void _showTimeoutSelectionDialog() {
    final sessionService = SessionSecurityService.to;
    final options = [
      {'label': '30 Seconds (Default)', 'seconds': 30},
      {'label': '1 Minute', 'seconds': 60},
      {'label': '5 Minutes', 'seconds': 300},
      {'label': 'Immediate (5 Seconds)', 'seconds': 5},
    ];

    Get.defaultDialog(
      title: 'Auto-Lock Timeout',
      titleStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final s = opt['seconds'] as int;
          return Obx(() {
            final isSelected = sessionService.autoLockTimeoutSeconds.value == s;
            return ListTile(
              title: Text(
                opt['label'] as String,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF0057FF) : Colors.black87,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF0057FF)) : null,
              onTap: () {
                sessionService.setAutoLockTimeout(s);
                Get.back();
              },
            );
          });
        }).toList(),
      ),
      textCancel: 'Close',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
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
              Get.defaultDialog(
                title: 'Security & Permissions',
                titleStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPermissionRow(
                        icon: Icons.shield_rounded,
                        color: Colors.green,
                        title: 'Screen Protection (FLAG_SECURE)',
                        desc: 'Screenshots & screen recordings are blocked to protect credentials.',
                      ),
                      const SizedBox(height: 12),
                      _buildPermissionRow(
                        icon: Icons.timer_outlined,
                        color: Colors.orangeAccent,
                        title: 'Inactivity & Background Lock',
                        desc: 'Vault automatically locks after 30 seconds of inactivity or minimization.',
                      ),
                      const SizedBox(height: 12),
                      _buildPermissionRow(
                        icon: Icons.lock_outline_rounded,
                        color: Colors.blueAccent,
                        title: 'Zero-Knowledge Storage',
                        desc: 'Secrets are encrypted on-device before transmission.',
                      ),
                      const SizedBox(height: 12),
                      _buildPermissionRow(
                        icon: Icons.block_rounded,
                        color: Colors.grey,
                        title: 'Least Privilege Guarantee',
                        desc: 'No access to Camera, Contacts, or Location.',
                      ),
                    ],
                  ),
                ),
                textConfirm: 'Understood',
                confirmTextColor: Colors.white,
                buttonColor: Colors.black87,
                onConfirm: () => Get.back(),
              );
            },
          ),
          _buildDivider(),
          Obx(
            () => _buildSwitchTile(
              title: 'Auto-Lock Vault',
              value: SessionSecurityService.to.autoLockEnabled.value,
              onChanged: (val) => SessionSecurityService.to.setAutoLockEnabled(val),
            ),
          ),
          _buildDivider(),
          Obx(
            () => _buildNavTile(
              title: 'Auto-Lock Timeout',
              trailingWidget: Text(
                '${SessionSecurityService.to.autoLockTimeoutSeconds.value}s',
                style: const TextStyle(
                  color: Color(0xFF0057FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _showTimeoutSelectionDialog,
            ),
          ),
          _buildDivider(),
          _buildNavTile(
            title: 'Lock Vault Now',
            leadingIcon: Icons.lock_outline_rounded,
            iconColor: Colors.blueAccent,
            titleColor: const Color(0xFF0057FF),
            onTap: controller.lockVaultNow,
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
          Obx(
            () => _buildSwitchTile(
              title: 'Allow Screenshots',
              value: controller.allowScreenshots.value,
              onChanged: (val) => controller.toggleAllowScreenshots(val),
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

  Widget _buildPermissionRow({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavTile({
    required String title,
    required VoidCallback onTap,
    Widget? trailingWidget,
    Color? titleColor,
    IconData? leadingIcon,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 20, color: iconColor ?? Colors.black87),
                  const SizedBox(width: 10),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
            trailingWidget ??
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
